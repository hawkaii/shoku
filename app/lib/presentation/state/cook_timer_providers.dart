import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/cook_timer_repository.dart';
import '../../data/models/cook_timer.dart';
import '../../data/services/timer_alerts.dart';
import 'journal_store.dart';

/// Owns the kitchen timer and nothing else: where it started, how long it runs,
/// when it was paused.
///
/// Every mutation is written to disk before it becomes state, so killing the app
/// one frame later loses nothing. Every start also mirrors itself into a local
/// notification, and every path that ends the timer cancels that notification by
/// the same id — a ring for a step the cook left ten minutes ago is the bug that
/// gets noticed in a kitchen.
class CookTimerStore extends StateNotifier<CookTimer?> {
  CookTimerStore(
    this._repo, {
    TimerAlerts alerts = const SilentTimerAlerts(),
    this.onAlertPermission,
  })  : _alerts = alerts,
        super(null) {
    _restore();
  }

  final CookTimerRepository _repo;
  final TimerAlerts _alerts;

  /// Where the card learns whether alerts are on, late, or off.
  final void Function(TimerAlertPermission)? onAlertPermission;

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
    // Ends any timer already running, including its notification.
    await _cancelMirror(state);

    final timer = CookTimer(
      dishId: dishId,
      versionId: versionId,
      stepIndex: stepIndex,
      startedAt: now ?? DateTime.now(),
      duration: CookTimer.clampDuration(duration),
    );
    await _persist(timer);

    // Asked here, at the first timer, and never at launch.
    final permission = await _alerts.ensurePermission();
    onAlertPermission?.call(permission);
    if (permission == TimerAlertPermission.allowed ||
        permission == TimerAlertPermission.inexact) {
      await _alerts.schedule(
        timer,
        exact: permission == TimerAlertPermission.allowed,
      );
    }
  }

  Future<void> pause({DateTime? now}) async {
    final timer = state;
    if (timer == null) return;
    // A paused timer has no end time, so nothing may ring for it.
    await _cancelMirror(timer);
    await _persist(timer.pausedNow(now ?? DateTime.now()));
  }

  Future<void> resume({DateTime? now}) async {
    final timer = state;
    if (timer == null) return;
    final resumed = timer.resumedAt(now ?? DateTime.now());
    await _persist(resumed);

    final permission = await _alerts.ensurePermission();
    onAlertPermission?.call(permission);
    if (permission == TimerAlertPermission.allowed ||
        permission == TimerAlertPermission.inexact) {
      await _alerts.schedule(
        resumed,
        exact: permission == TimerAlertPermission.allowed,
      );
    }
  }

  Future<void> stop() async {
    await _cancelMirror(state);
    await _repo.clear();
    state = null;
  }

  /// The timer ran out in front of the cook. The card keeps its "time's up"
  /// state, but nothing may ring for it afterwards — an inexact alarm can fire
  /// minutes late, and a ring for a timer you already watched finish is noise.
  Future<void> cancelAlert() async {
    final timer = state;
    if (timer == null) return;
    await _alerts.cancel(timer);
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

  Future<void> _cancelMirror(CookTimer? timer) async {
    if (timer == null) return;
    await _alerts.cancel(timer);
  }
}

final cookTimerRepositoryProvider = Provider<CookTimerRepository>(
  (ref) => CookTimerRepository(ref.watch(databaseProvider)),
);

/// The mirror, as a provider so tests can prove it is scheduled and cancelled.
final timerAlertsProvider = Provider<TimerAlerts>(
  (ref) => LocalTimerAlerts(),
);

final timerAlertPermissionProvider =
    StateProvider<TimerAlertPermission>((ref) => TimerAlertPermission.unknown);

final cookTimerProvider = StateNotifierProvider<CookTimerStore, CookTimer?>(
  (ref) => CookTimerStore(
    ref.watch(cookTimerRepositoryProvider),
    alerts: ref.watch(timerAlertsProvider),
    onAlertPermission: (permission) =>
        ref.read(timerAlertPermissionProvider.notifier).state = permission,
  ),
);
