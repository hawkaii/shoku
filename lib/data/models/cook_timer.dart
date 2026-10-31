import 'dart:math' as math;

/// A kitchen timer defined by the wall clock, never by ticks.
///
/// The previous one counted seconds down inside a `Timer.periodic`. That number
/// drifts whenever a frame is late, freezes the moment the app is backgrounded,
/// and is gone entirely when the process is killed — which is exactly when a cook
/// needs it. So nothing is counted here. The facts we store are the ones a
/// restart can still trust:
///
///   * which version's step it belongs to
///   * when it started
///   * how long it was asked to run
///   * how long it has spent paused
///
/// The remainder is derived from those on every read, so backgrounding, a locked
/// screen and a cold start all agree with each other.
///
/// **It will not alert you while the phone is locked.** There is no local
/// notification and no exact-alarm permission — that decision is still open, and
/// this class does not pretend otherwise. The clock is honest the moment the app
/// is on screen again; it is silent while it is not.
class CookTimer {
  const CookTimer({
    required this.dishId,
    required this.versionId,
    required this.stepIndex,
    required this.startedAt,
    required this.duration,
    this.pausedTotal = Duration.zero,
    this.pausedAt,
  });

  /// A row claiming a week-long step is corrupt data, not a long braise.
  static const Duration maxDuration = Duration(hours: 6);

  /// A timer of no length is not a timer.
  static const Duration minDuration = Duration(minutes: 1);

  final String dishId;
  final String versionId;
  final int stepIndex;
  final DateTime startedAt;
  final Duration duration;

  /// Time spent paused before the current pause, if there is one.
  final Duration pausedTotal;

  /// When the current pause began — null while the timer is running.
  final DateTime? pausedAt;

  bool get isPaused => pausedAt != null;

  int get durationMs => duration.inMilliseconds;

  /// Clamps a requested length into something a kitchen can mean.
  static Duration clampDuration(Duration requested) {
    if (requested <= Duration.zero) return minDuration;
    if (requested > maxDuration) return maxDuration;
    return requested;
  }

  /// The remainder at [now], always between zero and the full duration.
  ///
  /// Both clamps exist because a device clock is not trustworthy:
  /// a clock that jumps *backwards* would otherwise hand the cook more time than
  /// the step asked for, and one that jumps *forwards* would produce a negative
  /// number and a timer reading "-3:12".
  int remainingMsAt(DateTime now) {
    if (durationMs <= 0) return 0;

    var elapsed =
        now.difference(startedAt).inMilliseconds - pausedTotal.inMilliseconds;
    final paused = pausedAt;
    if (paused != null) {
      elapsed -= now.difference(paused).inMilliseconds;
    }

    elapsed = math.max(0, elapsed);
    return math.min(math.max(durationMs - elapsed, 0), durationMs);
  }

  bool isDoneAt(DateTime now) => remainingMsAt(now) == 0;

  CookTimer pausedNow(DateTime now) {
    if (isPaused) return this;
    return CookTimer(
      dishId: dishId,
      versionId: versionId,
      stepIndex: stepIndex,
      startedAt: startedAt,
      duration: duration,
      pausedTotal: pausedTotal,
      pausedAt: now,
    );
  }

  CookTimer resumedAt(DateTime now) {
    final paused = pausedAt;
    if (paused == null) return this;
    final offset = now.difference(paused);
    return CookTimer(
      dishId: dishId,
      versionId: versionId,
      stepIndex: stepIndex,
      startedAt: startedAt,
      duration: duration,
      // A backwards clock during a pause must not rewind the timer.
      pausedTotal: pausedTotal + (offset.isNegative ? Duration.zero : offset),
      pausedAt: null,
    );
  }

  /// mm:ss, rounded up: a five-minute timer reads 05:00 when it starts and 00:00
  /// only when it is actually finished.
  static String formatRemaining(int remainingMs) {
    final seconds = (remainingMs <= 0 ? 0 : (remainingMs / 1000).ceil());
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${rest.toString().padLeft(2, '0')}';
  }
}
