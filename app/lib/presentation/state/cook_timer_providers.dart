import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/cook_timer_repository.dart';
import '../../data/models/cook_timer.dart';
import 'journal_store.dart';

/// Owns the kitchen timer and nothing else: where it started, how long it runs,
/// when it was paused.
///
/// Every mutation is written to disk before it becomes state, so killing the app
/// one frame later loses nothing.
class CookTimerStore extends StateNotifier<CookTimer?> {
  CookTimerStore(this._repo) : super(null) {
    _restore();
  }

  final CookTimerRepository _repo;

  bool _restored = false;

  /// False until the row has been read, which the screen needs in order to tell
  /// "no timer" apart from "still loading".
  bool get isRestored => _restored;

  Future<void> _restore() async {
    try {
      state = await _repo.read();
    } catch (_) {
      // A timer is convenience, never the product. A bad row must not take the
      // cook screen down with it.
      state = null;
    } finally {
      _restored = true;
    }
  }

  Future<void> start({
    required String dishId,
    required String versionId,
    required int stepIndex,
    required Duration duration,
    DateTime? now,
  }) async {
    final timer = CookTimer(
      dishId: dishId,
      versionId: versionId,
      stepIndex: stepIndex,
      startedAt: now ?? DateTime.now(),
      duration: CookTimer.clampDuration(duration),
    );
    await _persist(timer);
  }

  Future<void> pause({DateTime? now}) async {
    final timer = state;
    if (timer == null) return;
    await _persist(timer.pausedNow(now ?? DateTime.now()));
  }

  Future<void> resume({DateTime? now}) async {
    final timer = state;
    if (timer == null) return;
    await _persist(timer.resumedAt(now ?? DateTime.now()));
  }

  Future<void> stop() async {
    await _repo.clear();
    state = null;
  }

  /// Drops the timer when the version it belongs to is no longer the one on
  /// screen.
  ///
  /// A fork changes what the steps mean, and the old step index would point at
  /// somebody else's instruction — a silent re-point is worse than losing the
  /// timer. Returns true when a timer was actually dropped, so the screen can say
  /// so out loud.
  Future<bool> dropIfVersionChanged({
    required String dishId,
    required String versionId,
  }) async {
    final timer = state;
    if (timer == null) return false;
    if (timer.dishId != dishId || timer.versionId == versionId) return false;
    await stop();
    return true;
  }

  Future<void> _persist(CookTimer timer) async {
    await _repo.write(timer);
    state = timer;
  }
}

final cookTimerRepositoryProvider = Provider<CookTimerRepository>(
  (ref) => CookTimerRepository(ref.watch(databaseProvider)),
);

final cookTimerProvider = StateNotifierProvider<CookTimerStore, CookTimer?>(
  (ref) => CookTimerStore(ref.watch(cookTimerRepositoryProvider)),
);
