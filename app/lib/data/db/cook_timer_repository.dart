import 'package:drift/drift.dart';

import '../models/cook_timer.dart';
import 'app_database.dart';

/// The one kitchen timer, on disk.
///
/// Deliberately not part of sync: a timer is a fact about this phone's kitchen,
/// not about the recipe. It never sets `dirty`, and the server never sees it.
class CookTimerRepository {
  CookTimerRepository(this._db);

  final AppDatabase _db;

  /// A single kitchen: there is one timer, and starting another replaces it.
  static const _id = 'active';

  Future<CookTimer?> read() async {
    final row = await (_db.select(_db.cookTimerRows)
          ..where((t) => t.id.equals(_id)))
        .getSingleOrNull();
    if (row == null) return null;

    return CookTimer(
      dishId: row.dishId,
      versionId: row.versionId,
      stepIndex: row.stepIndex,
      startedAt: row.startedAt,
      // A corrupt row must not become an absurd countdown.
      duration: CookTimer.clampDuration(Duration(milliseconds: row.durationMs)),
      pausedTotal: Duration(milliseconds: row.pausedMs),
      pausedAt: row.pausedAt,
    );
  }

  Future<void> write(CookTimer timer) async {
    await _db.into(_db.cookTimerRows).insertOnConflictUpdate(
          CookTimerRowsCompanion.insert(
            id: _id,
            dishId: timer.dishId,
            versionId: timer.versionId,
            stepIndex: timer.stepIndex,
            startedAt: timer.startedAt,
            durationMs: timer.durationMs,
            pausedMs: Value(timer.pausedTotal.inMilliseconds),
            pausedAt: Value(timer.pausedAt),
          ),
        );
  }

  Future<void> clear() async {
    await (_db.delete(_db.cookTimerRows)..where((t) => t.id.equals(_id))).go();
  }
}
