import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';

const _uuid = Uuid();

/// Which conversation a turn belongs to: the kitchen's, or one dish's.
class BotThread {
  const BotThread.kitchen()
      : scope = 'kitchen',
        dishId = null;

  const BotThread.dish(this.dishId) : scope = 'dish';

  final String scope;
  final String? dishId;

  String get key => dishId == null ? scope : '$scope:$dishId';

  static BotThread of(String scope, String? dishId) =>
      dishId == null ? const BotThread.kitchen() : BotThread.dish(dishId);

  @override
  bool operator ==(Object other) =>
      other is BotThread && other.scope == scope && other.dishId == dishId;

  @override
  int get hashCode => Object.hash(scope, dishId);
}

/// One thing that was said in a recipe's chat.
///
/// [versionId] is the version that was on screen when the turn happened. It is
/// what lets the sheet stop sending context across a version boundary: an
/// answer about v3 must not be handed to a question about v4.
class AssistantTurnRecord {
  const AssistantTurnRecord({
    required this.id,
    required this.thread,
    required this.versionId,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final BotThread thread;
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

  Future<int> count(String dishId) => countThread(BotThread.dish(dishId));

  Future<int> countThread(BotThread thread) async {
    final query = _db.selectOnly(_db.assistantTurnRows)
      ..addColumns([_db.assistantTurnRows.id.count()])
      ..where(_threadFilter(thread));
    final row = await query.getSingle();
    return row.read(_db.assistantTurnRows.id.count()) ?? 0;
  }

  /// The last [limit] turns, oldest first — the order a chat is read in.
  Future<List<AssistantTurnRecord>> load(String dishId, {int limit = page}) =>
      loadThread(BotThread.dish(dishId), limit: limit);

  Future<List<AssistantTurnRecord>> loadThread(
    BotThread thread, {
    int limit = page,
  }) async {
    final rows = await (_db.select(_db.assistantTurnRows)
          ..where((t) => _threadFilter(thread))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
    return [for (final row in rows.reversed) _toModel(row)];
  }

  Future<AssistantTurnRecord> add({
    String? dishId,
    BotThread? thread,
    required String? versionId,
    required String role,
    required String text,
    DateTime? now,
  }) async {
    final where = thread ?? BotThread.of('dish', dishId);
    final record = AssistantTurnRecord(
      id: _uuid.v4(),
      thread: where,
      versionId: versionId,
      role: role,
      text: text,
      createdAt: now ?? DateTime.now(),
    );
    await _db.into(_db.assistantTurnRows).insert(
          AssistantTurnRowsCompanion.insert(
            id: record.id,
            dishId: Value(record.thread.dishId),
            scope: Value(record.thread.scope),
            versionId: Value(record.versionId),
            role: record.role,
            message: record.text,
            createdAt: record.createdAt,
          ),
        );
    return record;
  }

  Future<void> clear(String dishId) => clearThread(BotThread.dish(dishId));

  Future<void> clearThread(BotThread thread) async {
    await (_db.delete(_db.assistantTurnRows)
          ..where((t) => _threadFilter(thread)))
        .go();
  }

  /// A dish's thread goes with the dish.
  Future<void> forget(String dishId) => clear(dishId);

  Expression<bool> _threadFilter(BotThread thread) =>
      _db.assistantTurnRows.scope.equals(thread.scope) &
      (thread.dishId == null
          ? _db.assistantTurnRows.dishId.isNull()
          : _db.assistantTurnRows.dishId.equals(thread.dishId!));

  static AssistantTurnRecord _toModel(AssistantTurnRow row) =>
      AssistantTurnRecord(
        id: row.id,
        thread: BotThread.of(row.scope, row.dishId),
        versionId: row.versionId,
        role: row.role,
        text: row.message,
        createdAt: row.createdAt,
      );
}
