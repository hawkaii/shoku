import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';

const _uuid = Uuid();

/// One thing that was said in a recipe's chat.
///
/// [versionId] is the version that was on screen when the turn happened. It is
/// what lets the sheet stop sending context across a version boundary: an
/// answer about v3 must not be handed to a question about v4.
class AssistantTurnRecord {
  const AssistantTurnRecord({
    required this.id,
    required this.dishId,
    required this.versionId,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String dishId;
  final String? versionId;

  /// `user` or `assistant`.
  final String role;
  final String text;
  final DateTime createdAt;

  bool get isMine => role == 'user';
}

/// The chat's local memory: newest last, and only this device's.
class AssistantTurnRepository {
  AssistantTurnRepository(this._db);

  final AppDatabase _db;

  static const page = 20;

  Future<int> count(String dishId) async {
    final query = _db.selectOnly(_db.assistantTurnRows)
      ..addColumns([_db.assistantTurnRows.id.count()])
      ..where(_db.assistantTurnRows.dishId.equals(dishId));
    final row = await query.getSingle();
    return row.read(_db.assistantTurnRows.id.count()) ?? 0;
  }

  /// The last [limit] turns, oldest first — the order a chat is read in.
  Future<List<AssistantTurnRecord>> load(String dishId, {int limit = page}) async {
    final rows = await (_db.select(_db.assistantTurnRows)
          ..where((t) => t.dishId.equals(dishId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
    return [for (final row in rows.reversed) _toModel(row)];
  }

  Future<AssistantTurnRecord> add({
    required String dishId,
    required String? versionId,
    required String role,
    required String text,
    DateTime? now,
  }) async {
    final record = AssistantTurnRecord(
      id: _uuid.v4(),
      dishId: dishId,
      versionId: versionId,
      role: role,
      text: text,
      createdAt: now ?? DateTime.now(),
    );
    await _db.into(_db.assistantTurnRows).insert(
          AssistantTurnRowsCompanion.insert(
            id: record.id,
            dishId: record.dishId,
            versionId: Value(record.versionId),
            role: record.role,
            message: record.text,
            createdAt: record.createdAt,
          ),
        );
    return record;
  }

  Future<void> clear(String dishId) async {
    await (_db.delete(_db.assistantTurnRows)
          ..where((t) => t.dishId.equals(dishId)))
        .go();
  }

  /// Called when a dish goes away, so its chat does not outlive it.
  Future<void> forget(String dishId) => clear(dishId);

  static AssistantTurnRecord _toModel(AssistantTurnRow row) =>
      AssistantTurnRecord(
        id: row.id,
        dishId: row.dishId,
        versionId: row.versionId,
        role: row.role,
        text: row.message,
        createdAt: row.createdAt,
      );
}
