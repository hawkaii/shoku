import 'dart:convert';

import 'package:drift/drift.dart';

import '../mock/journal_data.dart';
import '../db/app_database.dart';
import '../db/journal_repository.dart';

/// The half of the journal that talks to the server.
///
/// Kept apart from [JournalRepository] so the local read/write path stays
/// simple: this one only knows how to turn dirty rows into the wire format, and
/// how to apply what comes back without ever losing a cook.
///
/// Merge rules, agreed once and enforced here:
///   * versions and cooks are append-only → union by id, duplicates ignored
///   * dishes are mutable → last write wins on `updatedAt`
///   * deletes are tombstones → applied, never removed
class SyncRepository {
  SyncRepository(this._db, this._local);

  final AppDatabase _db;
  final JournalRepository _local;

  static const _cursorKey = 'sync_cursor';

  Future<String?> readCursor() async {
    final row = await (_db.select(_db.metaRows)
          ..where((m) => m.key.equals(_cursorKey)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> writeCursor(String? cursor) async {
    if (cursor == null || cursor.isEmpty) return;
    await _db.into(_db.metaRows).insertOnConflictUpdate(
          MetaRowsCompanion.insert(key: _cursorKey, value: cursor),
        );
  }

  /// Rows this device has changed and the server has not seen.
  Future<Map<String, List<Map<String, dynamic>>>> dirtyPayload() async {
    final dishes = await (_db.select(_db.dishRows)..where((d) => d.dirty.equals(1))).get();
    final versions =
        await (_db.select(_db.versionRows)..where((v) => v.dirty.equals(1))).get();
    final cooks =
        await (_db.select(_db.cookLogRows)..where((c) => c.dirty.equals(1))).get();

    return {
      'dishes': [for (final row in dishes) _dishWire(row)],
      'versions': [for (final row in versions) _versionWire(row)],
      'cook_logs': [for (final row in cooks) _cookWire(row)],
    };
  }

  Future<int> dirtyCount() async {
    final payload = await dirtyPayload();
    return payload.values.fold<int>(0, (sum, rows) => sum + rows.length);
  }

  /// Marks rows the server confirmed. Anything it rejected stays dirty so the
  /// next attempt retries it instead of pretending it was saved.
  Future<void> markClean(Map<String, dynamic> pushResponse) async {
    final accepted = <String, Set<String>>{};
    for (final table in ['dishes', 'versions', 'cook_logs']) {
      final rows = pushResponse[table];
      if (rows is! List) continue;
      accepted[table] = {
        for (final row in rows)
          if (row is Map && row['result'] == 'accepted') row['id'] as String,
      };
    }

    await _db.transaction(() async {
      for (final id in accepted['dishes'] ?? const <String>{}) {
        await (_db.update(_db.dishRows)..where((d) => d.id.equals(id)))
            .write(const DishRowsCompanion(dirty: Value(0)));
      }
      for (final id in accepted['versions'] ?? const <String>{}) {
        await (_db.update(_db.versionRows)..where((v) => v.id.equals(id)))
            .write(const VersionRowsCompanion(dirty: Value(0)));
      }
      for (final id in accepted['cook_logs'] ?? const <String>{}) {
        await (_db.update(_db.cookLogRows)..where((c) => c.id.equals(id)))
            .write(const CookLogRowsCompanion(dirty: Value(0)));
      }
    });
  }

  /// Applies a pull response. Never deletes anything, never overwrites a local
  /// row that is newer, and never lets a server row clobber an unsynced edit.
  Future<void> applyPull(Map<String, dynamic> pull) async {
    await _db.transaction(() async {
      for (final raw in (pull['dishes'] as List? ?? const [])) {
        final row = raw as Map<String, dynamic>;
        final id = row['id'] as String;
        final existing =
            await (_db.select(_db.dishRows)..where((d) => d.id.equals(id)))
                .getSingleOrNull();
        final incomingUpdated = DateTime.parse(row['updated_at'] as String);

        if (existing == null) {
          await _db.into(_db.dishRows).insert(
                DishRowsCompanion.insert(
                  id: id,
                  title: row['title'] as String,
                  subtitle: Value(row['subtitle'] as String? ?? ''),
                  coverUrl: Value(row['cover_url'] as String? ?? ''),
                  sourceHandle: Value(row['source_handle'] as String? ?? ''),
                  status: row['status'] as String,
                  minutes: Value((row['minutes'] as num?)?.toInt() ?? 0),
                  baselineKcal: Value((row['baseline_kcal'] as num?)?.toInt() ?? 0),
                  baselineProtein:
                      Value((row['baseline_protein'] as num?)?.toInt() ?? 0),
                  steps: Value(_encode(row['steps'])),
                  createdAt: DateTime.parse(row['created_at'] as String),
                  updatedAt: incomingUpdated,
                  deletedAt: row['deleted_at'] == null
                      ? const Value.absent()
                      : Value(DateTime.parse(row['deleted_at'] as String)),
                  dirty: const Value(0),
                ),
                mode: InsertMode.insertOrIgnore,
              );
          continue;
        }

        // A local row that is still dirty is the user's own edit; the server
        // copy is older by definition, so leave it alone.
        if (existing.dirty == 1) continue;
        if (!incomingUpdated.isAfter(existing.updatedAt)) continue;

        await (_db.update(_db.dishRows)..where((d) => d.id.equals(id))).write(
          DishRowsCompanion(
            title: Value(row['title'] as String),
            subtitle: Value(row['subtitle'] as String? ?? ''),
            coverUrl: Value(row['cover_url'] as String? ?? ''),
            sourceHandle: Value(row['source_handle'] as String? ?? ''),
            status: Value(row['status'] as String),
            minutes: Value((row['minutes'] as num?)?.toInt() ?? 0),
            baselineKcal: Value((row['baseline_kcal'] as num?)?.toInt() ?? 0),
            baselineProtein: Value((row['baseline_protein'] as num?)?.toInt() ?? 0),
            steps: Value(_encode(row['steps'])),
            updatedAt: Value(incomingUpdated),
            deletedAt: Value(row['deleted_at'] == null
                ? null
                : DateTime.parse(row['deleted_at'] as String)),
            dirty: const Value(0),
          ),
        );
      }

      // Append-only tables: union by id, never update.
      for (final raw in (pull['versions'] as List? ?? const [])) {
        final row = raw as Map<String, dynamic>;
        await _db.into(_db.versionRows).insert(
              VersionRowsCompanion.insert(
                id: row['id'] as String,
                dishId: row['dish_id'] as String,
                number: Value((row['number'] as num?)?.toInt() ?? 0),
                changes: Value(_encode(row['changes'])),
                ingredients: Value(_encode(row['ingredients'])),
                steps: Value(_encode(row['steps'])),
                kcal: Value((row['kcal'] as num?)?.toInt() ?? 0),
                protein: Value((row['protein'] as num?)?.toInt() ?? 0),
                originKind: Value(row['origin_kind'] as String? ?? 'mine'),
                originCreator: Value(row['origin_creator'] as String?),
                originUrl: Value(row['origin_url'] as String?),
                originShortcode: Value(row['origin_shortcode'] as String?),
                parentVersionId: Value(row['parent_version_id'] as String?),
                extractionVersion:
                    Value((row['extraction_version'] as num?)?.toInt() ?? 0),
                createdAt: DateTime.parse(row['created_at'] as String),
                dirty: const Value(0),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }

      for (final raw in (pull['cook_logs'] as List? ?? const [])) {
        final row = raw as Map<String, dynamic>;
        await _db.into(_db.cookLogRows).insert(
              CookLogRowsCompanion.insert(
                id: row['id'] as String,
                dishId: row['dish_id'] as String,
                versionId: Value(row['version_id'] as String?),
                versionNumber: (row['version_number'] as num?)?.toInt() ?? 0,
                cookedAt: DateTime.parse(row['cooked_at'] as String),
                photoUrl: Value(row['photo_url'] as String? ?? ''),
                photoState: Value(row['photo_state'] as String? ?? 'none'),
                outcome: row['outcome'] as String,
                mood: row['mood'] as String,
                note: Value(row['note'] as String? ?? ''),
                changes: Value(_encode(row['changes'])),
                rating: Value((row['rating'] as num?)?.toInt() ?? 3),
                dirty: const Value(0),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  // ---- wire format -----------------------------------------------------

  Map<String, dynamic> _dishWire(DishRow row) => {
        'id': row.id,
        'title': row.title,
        'subtitle': row.subtitle,
        'cover_url': row.coverUrl,
        'source_handle': row.sourceHandle,
        'status': row.status,
        'minutes': row.minutes,
        'baseline_kcal': row.baselineKcal,
        'baseline_protein': row.baselineProtein,
        'steps': _decode(row.steps),
        'created_at': _iso(row.createdAt),
        'updated_at': _iso(row.updatedAt),
        if (row.deletedAt != null) 'deleted_at': _iso(row.deletedAt!),
      };

  Map<String, dynamic> _versionWire(VersionRow row) => {
        'id': row.id,
        'dish_id': row.dishId,
        'number': row.number,
        'changes': _decode(row.changes),
        'ingredients': _decode(row.ingredients),
        'steps': _decode(row.steps),
        'kcal': row.kcal,
        'protein': row.protein,
        'origin_kind': row.originKind,
        if (row.originCreator != null) 'origin_creator': row.originCreator,
        if (row.originUrl != null) 'origin_url': row.originUrl,
        if (row.originShortcode != null) 'origin_shortcode': row.originShortcode,
        if (row.parentVersionId != null) 'parent_version_id': row.parentVersionId,
        'extraction_version': row.extractionVersion,
        'created_at': _iso(row.createdAt),
      };

  Map<String, dynamic> _cookWire(CookLogRow row) => {
        'id': row.id,
        'dish_id': row.dishId,
        if (row.versionId != null) 'version_id': row.versionId,
        'version_number': row.versionNumber,
        'cooked_at': _iso(row.cookedAt),
        'photo_url': row.photoUrl,
        'photo_state': row.photoState,
        'outcome': row.outcome,
        'mood': row.mood,
        'note': row.note,
        'changes': _decode(row.changes),
        'rating': row.rating,
      };

  static String _iso(DateTime value) => value.toUtc().toIso8601String();

  /// JSON columns are stored as JSON text, never as a list's `toString()`.
  static String _encode(Object? value) => jsonEncode(value ?? const <String>[]);

  static List<String> _decode(String raw) {
    if (raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.map((e) => e.toString()).toList();
  }
}
