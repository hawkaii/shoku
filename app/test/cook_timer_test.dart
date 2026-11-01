import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/models/cook_timer.dart';

/// The timer is arithmetic on the wall clock, so these tests are too: no pumping,
/// no fake ticks, just "what does the clock say now".
CookTimer _timer({
  DateTime? startedAt,
  Duration duration = const Duration(minutes: 10),
  Duration pausedTotal = Duration.zero,
  DateTime? pausedAt,
}) {
  return CookTimer(
    dishId: 'd1',
    versionId: 'v1',
    stepIndex: 2,
    startedAt: startedAt ?? DateTime(2026, 1, 1, 19, 0),
    duration: duration,
    pausedTotal: pausedTotal,
    pausedAt: pausedAt,
  );
}

void main() {
  final start = DateTime(2026, 1, 1, 19, 0);

  test('the remainder is the clock, not a count of ticks', () {
    final timer = _timer();

    expect(timer.remainingMsAt(start), 10 * 60 * 1000);
    expect(timer.remainingMsAt(start.add(const Duration(minutes: 4))),
        6 * 60 * 1000);
    expect(timer.remainingMsAt(start.add(const Duration(seconds: 150))),
        7 * 60 * 1000 + 30000);
  });

  test('a finished timer reads zero, never less', () {
    final timer = _timer();
    expect(timer.remainingMsAt(start.add(const Duration(minutes: 11))), 0);
    expect(timer.remainingMsAt(start.add(const Duration(days: 3))), 0);
  });

  test('a clock that jumps backwards cannot add time', () {
    final timer = _timer();

    // The device thinks it is an hour before the timer started.
    final jumped = start.subtract(const Duration(hours: 1));
    expect(timer.remainingMsAt(jumped), 10 * 60 * 1000);
    expect(timer.remainingMsAt(jumped), lessThanOrEqualTo(timer.durationMs));
  });

  test('pausing stops the clock, resuming starts it again', () {
    final paused = _timer().pausedNow(start.add(const Duration(minutes: 1)));

    // Five minutes later, still nine minutes left: pause means pause.
    expect(paused.remainingMsAt(start.add(const Duration(minutes: 5))),
        9 * 60 * 1000);

    final resumed = paused.resumedAt(start.add(const Duration(minutes: 5)));
    expect(resumed.isPaused, isFalse);
    expect(resumed.pausedTotal, const Duration(minutes: 4));
    expect(resumed.remainingMsAt(start.add(const Duration(minutes: 6))),
        8 * 60 * 1000);
  });

  test('a clock jump during a pause cannot rewind the timer', () {
    final paused = _timer().pausedNow(start.add(const Duration(minutes: 1)));
    final resumed = paused.resumedAt(start.subtract(const Duration(hours: 2)));

    // A negative pause is worth nothing: the timer never gains time from it.
    expect(resumed.pausedTotal, Duration.zero);
    expect(resumed.remainingMsAt(start.add(const Duration(minutes: 6))),
        4 * 60 * 1000);
  });

  test('absurd lengths are clamped, not obeyed', () {
    expect(CookTimer.clampDuration(Duration.zero), CookTimer.minDuration);
    expect(CookTimer.clampDuration(const Duration(seconds: -30)),
        CookTimer.minDuration);
    expect(CookTimer.clampDuration(const Duration(days: 30)),
        CookTimer.maxDuration);
    expect(CookTimer.clampDuration(const Duration(minutes: 5)),
        const Duration(minutes: 5));
  });

  test('the clock reads mm:ss and rounds up', () {
    expect(CookTimer.formatRemaining(10 * 60 * 1000), '10:00');
    expect(CookTimer.formatRemaining(1), '00:01');
    expect(CookTimer.formatRemaining(0), '00:00');
    expect(CookTimer.formatRemaining(-5000), '00:00');
  });
}
