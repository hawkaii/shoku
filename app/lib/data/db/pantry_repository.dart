import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/failure_log.dart';
import '../models/pantry_item.dart';
import 'app_database.dart';

const _uuid = Uuid();

/// The pantry on disk.
///
/// Mutable, unlike versions and cooks: an item is edited, and a delete is a
/// tombstone so a pull cannot resurrect it.
class PantryRepository {
  PantryRepository(this._db);

  final AppDatabase _db;

  Future<List<PantryItem>> load({bool includeDeleted = false}) async {
    final query = _db.select(_db.pantryRows);
    if (!includeDeleted) {
      query.where((p) => p.deletedAt.isNull());
    }
    final rows = await query.get();
    final items = [for (final row in rows) _toModel(row)];
    items.sort((a, b) {
      // Wanted first (shopping), then by name.
      if (a.wanted != b.wanted) return a.wanted ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return items;
  }

  Future<PantryItem?> byId(String id) async {
    final row = await (_db.select(_db.pantryRows)
          ..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  Future<PantryItem> add({
    required String name,
    double? quantity,
    PantryUnit? unit,
    List<String> aliases = const [],
    bool wanted = false,
    String source = 'manual',
    DateTime? now,
  }) async {
    final stamp = now ?? DateTime.now();
    final item = PantryItem(
      id: _uuid.v4(),
      name: name.trim(),
      quantity: quantity,
      unit: unit,
      aliases: aliases,
      wanted: wanted,
      source: source,
      createdAt: stamp,
      updatedAt: stamp,
    );
    await _db.into(_db.pantryRows).insert(_companion(item, dirty: 1));
    return item;
  }

  /// Last-write-wins on `updatedAt`, and always dirty so it reaches the server.
  Future<void> save(PantryItem item) async {
    final stamped = item.copyWith(updatedAt: DateTime.now(), dirty: 1);
    await _db
        .into(_db.pantryRows)
        .insertOnConflictUpdate(_companion(stamped, dirty: 1));
  }

  Future<void> remove(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.pantryRows)..where((p) => p.id.equals(id))).write(
      PantryRowsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(1),
      ),
    );
  }

  /// Applies rows from the server. Newer `updated_at` wins; a tombstone hides.
  Future<void> applyPull(List<dynamic> rows) async {
    for (final raw in rows) {
      if (raw is! Map) continue;
      final id = raw['id'];
      if (id is! String || id.isEmpty) continue;
      final incoming = DateTime.tryParse('${raw['updated_at']}');
      if (incoming == null) continue;

      final existing = await byId(id);
      if (existing != null && existing.updatedAt.isAfter(incoming)) continue;

      await _db.into(_db.pantryRows).insertOnConflictUpdate(
            PantryRowsCompanion.insert(
              id: id,
              name: (raw['name'] as String?) ?? existing?.name ?? '',
              quantity: Value((raw['quantity'] as num?)?.toDouble()),
              unit: Value((raw['unit'] as String?)),
              aliases: Value(jsonEncode(raw['aliases'] ?? const [])),
              wanted: Value(raw['wanted'] == true ? 1 : 0),
              source: Value((raw['source'] as String?) ?? 'manual'),
              createdAt: DateTime.tryParse('${raw['created_at']}') ??
                  existing?.createdAt ??
                  incoming,
              updatedAt: incoming,
              deletedAt: Value(DateTime.tryParse('${raw['deleted_at']}')),
              dirty: const Value(0),
            ),
          );
    }
  }

  PantryRowsCompanion _companion(PantryItem item, {required int dirty}) =>
      PantryRowsCompanion.insert(
        id: item.id,
        name: item.name,
        quantity: Value(item.quantity),
        unit: Value(item.unit?.label),
        aliases: Value(jsonEncode(item.aliases)),
        wanted: Value(item.wanted ? 1 : 0),
        source: Value(item.source),
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        deletedAt: Value(item.deletedAt),
        dirty: Value(dirty),
      );

  static PantryItem _toModel(PantryRow row) => PantryItem(
        id: row.id,
        name: row.name,
        quantity: row.quantity,
        unit: PantryUnit.parse(row.unit),
        aliases: _decode(row.aliases),
        wanted: row.wanted == 1,
        source: row.source,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
        dirty: row.dirty,
      );

  static List<String> _decode(String raw) {
    if (raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.map((e) => e.toString()).toList();
    } catch (error, stack) {
      // A corrupt column is already wrong on disk; the shelf renders without it
      // rather than crashing, and the row is named in the log.
      logFailure('pantry column decode', error, stack);
      return const [];
    }
  }
}
