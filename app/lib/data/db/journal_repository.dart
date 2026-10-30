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
///
/// Invariants (they mirror what sync will assume):
///   * versions and cooks are append-only — inserts only, never updates
///   * ids are stable, so a retry can't duplicate a row
///   * deletes are tombstones, and a tombstoned dish accepts no new cooks
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
    final cookRows = await _db.select(_db.cookLogRows).get();

    final versionsByDish = <String, List<RecipeVersion>>{};
    for (final row in versionRows) {
      versionsByDish.putIfAbsent(row.dishId, () => []).add(_toVersion(row));
    }
    for (final list in versionsByDish.values) {
      list.sort(_byLineage);
    }

    final cooksByDish = <String, List<CookLog>>{};
    for (final row in cookRows) {
      cooksByDish.putIfAbsent(row.dishId, () => []).add(_toCook(row));
    }
    for (final list in cooksByDish.values) {
      // Newest first, with version number and id breaking same-second ties so
      // two devices render the same order from the same rows.
      list.sort((a, b) {
        final byTime = b.cookedAt.compareTo(a.cookedAt);
        if (byTime != 0) return byTime;
        final byVersion = b.versionNumber.compareTo(a.versionNumber);
        return byVersion != 0 ? byVersion : b.id.compareTo(a.id);
      });
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
    final row = await (_db.select(_db.dishRows)
          ..where((d) => d.id.equals(id) & d.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return null;
    final versions = await (_db.select(_db.versionRows)
          ..where((v) => v.dishId.equals(id)))
        .get();
    final cooks = await (_db.select(_db.cookLogRows)
          ..where((c) => c.dishId.equals(id)))
        .get();
    final versionList = versions.map(_toVersion).toList()..sort(_byLineage);
    final cookList = cooks.map(_toCook).toList()
      ..sort((a, b) {
        final byTime = b.cookedAt.compareTo(a.cookedAt);
        if (byTime != 0) return byTime;
        final byVersion = b.versionNumber.compareTo(a.versionNumber);
        return byVersion != 0 ? byVersion : b.id.compareTo(a.id);
      });
    return _toDish(row, versionList, cookList);
  }

  /// Whether the demo kitchen has ever been written. Stored in the database so
  /// a wiped database reseeds and a user who deletes every dish does not.
  Future<bool> isSeeded() async {
    final row = await (_db.select(_db.metaRows)
          ..where((m) => m.key.equals('seeded')))
        .getSingleOrNull();
    return row?.value == '1';
  }

  /// First run: the demo kitchen. Written as *local* rows (`dirty = 0`) so it is
  /// never uploaded as the user's own journal.
  Future<void> seed(List<Dish> dishes) async {
    // One transaction: a partial seed would look like a real journal.
    await _db.transaction(() async {
      for (final dish in dishes) {
        await _writeDish(dish, dirty: false, insertOnly: true);
      }
      await _db.into(_db.metaRows).insertOnConflictUpdate(
            MetaRowsCompanion.insert(key: 'seeded', value: '1'),
          );
    });
  }

  /// Inserts or updates a dish and appends any versions/cooks it doesn't have.
  Future<void> upsertDish(Dish dish, {bool dirty = true}) async {
    await _db.transaction(() async {
      await _writeDish(dish, dirty: dirty, insertOnly: false);
    });
  }

  /// Committing a cook appends a version and a log, and moves the dish's
  /// status. The read and the write share one transaction, so two rapid saves
  /// can't both claim version 4.
  Future<int?> commitCook({
    required String dishId,
    required CookMood mood,
    required int rating,
    required String note,
    required List<String> changes,
    String? photoUrl,
  }) async {
    return _db.transaction(() async {
      final dish = await loadDish(dishId);
      if (dish == null) return null; // tombstoned or missing: write nothing

      final now = DateTime.now();
      final previous = dish.versions.isEmpty ? null : dish.versions.last;
      final nextNumber = (previous?.number ?? 0) + 1;

      final version = RecipeVersion(
        id: _uuid.v4(),
        number: nextNumber,
        changes: changes.isEmpty ? const ['No changes'] : changes,
        ingredients: previous?.ingredients ?? const [],
        createdAt: now,
        steps: (previous != null && previous.steps.isNotEmpty)
            ? previous.steps
            : dish.steps,
        kcal: dish.baselineKcal + (changes.length * 18),
        protein: dish.baselineProtein + (changes.length * 2),
        parentVersionId: (previous != null && previous.id.isNotEmpty) ? previous.id : null,
      );

      final log = CookLog(
        id: _uuid.v4(),
        cookedAt: now,
        versionNumber: nextNumber,
        versionId: version.id,
        photoUrl: photoUrl ?? dish.coverUrl,
        photoState: _photoState(photoUrl ?? dish.coverUrl),
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
      return nextNumber;
    });
  }

  Future<void> setStatus(String dishId, DishStatus status) async {
    await (_db.update(_db.dishRows)
          ..where((d) => d.id.equals(dishId) & d.deletedAt.isNull()))
        .write(
      DishRowsCompanion(
        status: Value(status.name),
        updatedAt: Value(DateTime.now()),
        dirty: const Value(1),
      ),
    );
  }

  /// Soft delete: a tombstone, so an offline device can't resurrect the dish.
  /// Versions and cooks survive it — the history of a deleted dish is still the
  /// user's history, and the dish tombstone is what hides it.
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

  // ---- writing ---------------------------------------------------------

  Future<void> _writeDish(
    Dish dish, {
    required bool dirty,
    required bool insertOnly,
  }) async {
    final now = DateTime.now();
    final existing = await (_db.select(_db.dishRows)
          ..where((d) => d.id.equals(dish.id)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.dishRows).insert(
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
              dirty: Value(dirty ? 1 : 0),
            ),
          );
    } else if (!insertOnly) {
      await (_db.update(_db.dishRows)..where((d) => d.id.equals(dish.id))).write(
        DishRowsCompanion(
          title: Value(dish.title),
          subtitle: Value(dish.subtitle),
          coverUrl: Value(dish.coverUrl),
          sourceHandle: Value(dish.sourceHandle),
          status: Value(dish.status.name),
          minutes: Value(dish.minutes),
          baselineKcal: Value(dish.baselineKcal),
          baselineProtein: Value(dish.baselineProtein),
          steps: Value(jsonEncode(dish.steps)),
          updatedAt: Value(now),
          dirty: Value(dirty ? 1 : existing.dirty),
        ),
      );
    }

    // Append-only: an existing version is never rewritten, and ids are stable
    // so a retry inserts nothing.
    for (final version in dish.versions) {
      await _db.into(_db.versionRows).insert(
            _versionCompanion(dish.id, version, dirty: dirty ? 1 : 0),
            mode: InsertMode.insertOrIgnore,
          );
    }
    for (final cook in dish.cooks) {
      await _db.into(_db.cookLogRows).insert(
            _cookCompanion(dish.id, cook, dirty: dirty ? 1 : 0),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  // ---- mapping ---------------------------------------------------------

  /// Oldest first, and a total order: two versions created in the same second
  /// must not swap places between reads.
  static int _byLineage(RecipeVersion a, RecipeVersion b) {
    final byTime = a.createdAt.compareTo(b.createdAt);
    if (byTime != 0) return byTime;
    final byNumber = a.number.compareTo(b.number);
    return byNumber != 0 ? byNumber : a.id.compareTo(b.id);
  }

  static String _photoState(String path) {
    if (path.isEmpty) return 'none';
    return path.startsWith('http') ? 'synced' : 'local';
  }

  /// Seed versions arrive without ids; derive one so seeding twice is a no-op.
  static String _versionId(String dishId, RecipeVersion v) =>
      v.id.isNotEmpty ? v.id : '$dishId-v${v.number}';

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
        versionId: row.versionId,
        photoUrl: row.photoUrl,
        photoState: row.photoState,
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
    int dirty = 1,
  }) =>
      VersionRowsCompanion.insert(
        id: _versionId(dishId, v),
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
        dirty: Value(dirty),
      );

  CookLogRowsCompanion _cookCompanion(String dishId, CookLog c, {int dirty = 1}) =>
      CookLogRowsCompanion.insert(
        id: c.id.isEmpty ? _uuid.v4() : c.id,
        dishId: dishId,
        versionId: Value(c.versionId),
        versionNumber: c.versionNumber,
        cookedAt: c.cookedAt,
        photoUrl: Value(c.photoUrl),
        photoState: Value(c.photoState.isEmpty ? _photoState(c.photoUrl) : c.photoState),
        outcome: c.outcome.name,
        mood: c.mood.name,
        note: Value(c.note),
        changes: Value(jsonEncode(c.changes)),
        rating: Value(c.rating),
        dirty: Value(dirty),
      );

  static List<String> _decodeList(String raw) {
    if (raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.map((e) => e.toString()).toList();
  }
}
