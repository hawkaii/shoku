import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../mock/journal_data.dart';
import 'app_database.dart';

const _uuid = Uuid();

/// Reads and writes the journal.
///
/// The UI never touches rows: everything comes back as the domain model in
/// `journal_data.dart`, so swapping the storage later doesn't reach the widgets.
class JournalRepository {
  JournalRepository(this._db);

  final AppDatabase _db;

  Future<int> countDishes() async {
    final query = _db.selectOnly(_db.dishRows)..addColumns([_db.dishRows.id.count()]);
    final row = await query.getSingle();
    return row.read(_db.dishRows.id.count()) ?? 0;
  }

  /// Every live dish, newest cook first, assembled from its versions and cooks.
  Future<List<Dish>> loadDishes() async {
    final dishRows = await (_db.select(_db.dishRows)
          ..where((d) => d.deletedAt.isNull()))
        .get();
    if (dishRows.isEmpty) return [];

    final versionRows = await _db.select(_db.versionRows).get();
    final cookRows = await (_db.select(_db.cookLogRows)
          ..orderBy([
            (c) => OrderingTerm.desc(c.cookedAt),
            // Two cooks in the same millisecond must still come back in order.
            (c) => OrderingTerm.desc(c.versionNumber),
          ]))
        .get();

    final versionsByDish = <String, List<RecipeVersion>>{};
    for (final row in versionRows) {
      versionsByDish.putIfAbsent(row.dishId, () => []).add(_toVersion(row));
    }
    for (final list in versionsByDish.values) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    final cooksByDish = <String, List<CookLog>>{};
    for (final row in cookRows) {
      cooksByDish.putIfAbsent(row.dishId, () => []).add(_toCook(row));
    }

    return [
      for (final row in dishRows)
        _toDish(
          row,
          versionsByDish[row.id] ?? const [],
          cooksByDish[row.id] ?? const [],
        ),
    ];
  }

  Future<Dish?> loadDish(String id) async {
    final row = await (_db.select(_db.dishRows)..where((d) => d.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    final versions = await (_db.select(_db.versionRows)
          ..where((v) => v.dishId.equals(id)))
        .get();
    final cooks = await (_db.select(_db.cookLogRows)
          ..where((c) => c.dishId.equals(id))
          ..orderBy([
            (c) => OrderingTerm.desc(c.cookedAt),
            (c) => OrderingTerm.desc(c.versionNumber),
          ]))
        .get();
    return _toDish(row, versions.map(_toVersion).toList(), cooks.map(_toCook).toList());
  }

  /// Used on first run so the app doesn't open empty.
  Future<void> seed(List<Dish> dishes) async {
    for (final dish in dishes) {
      await upsertDish(dish);
    }
  }

  /// Inserts or replaces a dish with all of its versions and cooks.
  Future<void> upsertDish(Dish dish) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await _db.into(_db.dishRows).insertOnConflictUpdate(
            DishRowsCompanion.insert(
              id: dish.id,
              title: dish.title,
              subtitle: Value(dish.subtitle),
              coverUrl: Value(dish.coverUrl),
              sourceHandle: Value(dish.sourceHandle),
              status: dish.status.name,
              minutes: Value(dish.minutes),
              baselineKcal: Value(dish.baselineKcal),
              baselineProtein: Value(dish.baselineProtein),
              steps: Value(jsonEncode(dish.steps)),
              createdAt: now,
              updatedAt: now,
            ),
          );

      for (var i = 0; i < dish.versions.length; i++) {
        final v = dish.versions[i];
        await _db.into(_db.versionRows).insertOnConflictUpdate(
              _versionCompanion(dish.id, v, number: v.number == 0 ? i + 1 : v.number),
            );
      }

      for (final c in dish.cooks) {
        await _db.into(_db.cookLogRows).insertOnConflictUpdate(_cookCompanion(dish.id, c));
      }
    });
  }

  /// Committing a cook appends a version and a log, and moves the dish's
  /// status. Append-only, so nothing here ever edits an existing version.
  Future<void> commitCook({
    required String dishId,
    required CookMood mood,
    required int rating,
    required String note,
    required List<String> changes,
    String? photoUrl,
  }) async {
    final dish = await loadDish(dishId);
    if (dish == null) return;

    final now = DateTime.now();
    final previous = dish.versions.isEmpty ? null : dish.versions.last;
    final nextNumber = (previous?.number ?? 0) + 1;

    final version = RecipeVersion(
      id: _uuid.v4(),
      number: nextNumber,
      changes: changes.isEmpty ? const ['No changes'] : changes,
      ingredients: previous?.ingredients ?? const [],
      createdAt: now,
      steps: previous?.steps ?? dish.steps,
      kcal: dish.baselineKcal + (changes.length * 18),
      protein: dish.baselineProtein + (changes.length * 2),
      parentVersionId: (previous != null && previous.id.isNotEmpty) ? previous.id : null,
    );

    final log = CookLog(
      id: _uuid.v4(),
      cookedAt: now,
      versionNumber: nextNumber,
      photoUrl: photoUrl ?? dish.coverUrl,
      outcome: rating >= 5
          ? CookOutcome.nailedIt
          : rating >= 3
              ? CookOutcome.good
              : CookOutcome.needsWork,
      note: note,
      changes: changes,
      mood: mood,
      rating: rating,
    );

    final cookCount = dish.cooks.length + 1;

    await _db.transaction(() async {
      await _db.into(_db.versionRows).insert(_versionCompanion(dishId, version));
      await _db.into(_db.cookLogRows).insert(_cookCompanion(dishId, log));
      await (_db.update(_db.dishRows)..where((d) => d.id.equals(dishId))).write(
        DishRowsCompanion(
          coverUrl: Value(photoUrl ?? dish.coverUrl),
          status: Value(
            cookCount >= 3 ? DishStatus.signature.name : DishStatus.cooked.name,
          ),
          updatedAt: Value(now),
          dirty: const Value(1),
        ),
      );
    });
  }

  Future<void> setStatus(String dishId, DishStatus status) async {
    await (_db.update(_db.dishRows)..where((d) => d.id.equals(dishId))).write(
      DishRowsCompanion(
        status: Value(status.name),
        updatedAt: Value(DateTime.now()),
        dirty: const Value(1),
      ),
    );
  }

  /// Soft delete: a tombstone, so an offline device can't resurrect the dish.
  Future<void> deleteDish(String dishId) async {
    final now = DateTime.now();
    await (_db.update(_db.dishRows)..where((d) => d.id.equals(dishId))).write(
      DishRowsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(1),
      ),
    );
  }

  // ---- mapping ---------------------------------------------------------

  Dish _toDish(DishRow row, List<RecipeVersion> versions, List<CookLog> cooks) {
    return Dish(
      id: row.id,
      title: row.title,
      subtitle: row.subtitle,
      coverUrl: row.coverUrl,
      sourceHandle: row.sourceHandle,
      status: DishStatus.values.firstWhere(
        (s) => s.name == row.status,
        orElse: () => DishStatus.toCook,
      ),
      versions: versions,
      cooks: cooks,
      minutes: row.minutes,
      baselineKcal: row.baselineKcal,
      baselineProtein: row.baselineProtein,
      steps: _decodeList(row.steps),
    );
  }

  RecipeVersion _toVersion(VersionRow row) => RecipeVersion(
        id: row.id,
        number: row.number,
        changes: _decodeList(row.changes),
        ingredients: _decodeList(row.ingredients),
        createdAt: row.createdAt,
        steps: _decodeList(row.steps),
        kcal: row.kcal,
        protein: row.protein,
        originKind: row.originKind,
        originCreator: row.originCreator,
        originUrl: row.originUrl,
        originShortcode: row.originShortcode,
        parentVersionId: row.parentVersionId,
      );

  CookLog _toCook(CookLogRow row) => CookLog(
        id: row.id,
        cookedAt: row.cookedAt,
        versionNumber: row.versionNumber,
        photoUrl: row.photoUrl,
        outcome: CookOutcome.values.firstWhere(
          (o) => o.name == row.outcome,
          orElse: () => CookOutcome.good,
        ),
        note: row.note,
        changes: _decodeList(row.changes),
        mood: CookMood.values.firstWhere(
          (m) => m.name == row.mood,
          orElse: () => CookMood.comfort,
        ),
        rating: row.rating,
      );

  VersionRowsCompanion _versionCompanion(
    String dishId,
    RecipeVersion v, {
    int? number,
  }) =>
      VersionRowsCompanion.insert(
        id: v.id.isEmpty ? _uuid.v4() : v.id,
        dishId: dishId,
        number: Value(number ?? v.number),
        changes: Value(jsonEncode(v.changes)),
        ingredients: Value(jsonEncode(v.ingredients)),
        steps: Value(jsonEncode(v.steps)),
        kcal: Value(v.kcal),
        protein: Value(v.protein),
        originKind: Value(v.originKind),
        originCreator: Value(v.originCreator),
        originUrl: Value(v.originUrl),
        originShortcode: Value(v.originShortcode),
        parentVersionId: Value(v.parentVersionId),
        createdAt: v.createdAt,
      );

  CookLogRowsCompanion _cookCompanion(String dishId, CookLog c) =>
      CookLogRowsCompanion.insert(
        id: c.id.isEmpty ? _uuid.v4() : c.id,
        dishId: dishId,
        versionNumber: c.versionNumber,
        cookedAt: c.cookedAt,
        photoUrl: Value(c.photoUrl),
        outcome: c.outcome.name,
        mood: c.mood.name,
        note: Value(c.note),
        changes: Value(jsonEncode(c.changes)),
        rating: Value(c.rating),
      );

  static List<String> _decodeList(String raw) {
    if (raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.map((e) => e.toString()).toList();
  }
}
