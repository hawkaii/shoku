import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/models/cook_timer.dart';
import 'package:food_finder/presentation/screens/cook/timer_card.dart';

final _start = DateTime(2026, 1, 1, 19, 0);

CookTimer _timer({DateTime? pausedAt}) => CookTimer(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 2,
      startedAt: _start,
      duration: const Duration(minutes: 10),
      pausedAt: pausedAt,
    );

Widget _harness({
  CookTimer? timer,
  int remainingMs = 10 * 60 * 1000,
  int suggestedMinutes = 5,
  required Map<String, int> taps,
}) {
  return MaterialApp(
    theme: ShokuTheme.light(),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CookTimerCard(
          timer: timer,
          remainingMs: remainingMs,
          suggestedMinutes: suggestedMinutes,
          currentStep: 2,
          onStart: () => taps.update('start', (v) => v + 1, ifAbsent: () => 1),
          onPause: () => taps.update('pause', (v) => v + 1, ifAbsent: () => 1),
          onResume: () => taps.update('resume', (v) => v + 1, ifAbsent: () => 1),
          onStop: () => taps.update('stop', (v) => v + 1, ifAbsent: () => 1),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a step with time offers to start, and nothing else',
      (tester) async {
    final taps = <String, int>{};
    await tester.pumpWidget(_harness(taps: taps));

    expect(find.text('start 5 min timer'), findsOneWidget);
    expect(find.byKey(const ValueKey('timer-pause')), findsNothing);
    expect(find.byKey(const ValueKey('timer-stop')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('timer-start')));
    expect(taps['start'], 1);
  });

  testWidgets('a step without time shows no timer at all', (tester) async {
    await tester.pumpWidget(_harness(taps: {}, suggestedMinutes: 0));

    expect(find.byKey(const ValueKey('timer-start')), findsNothing);
    expect(find.byKey(const ValueKey('timer-clock')), findsNothing);
  });

  testWidgets('running reads the clock and offers pause and stop',
      (tester) async {
    final taps = <String, int>{};
    await tester.pumpWidget(_harness(
      timer: _timer(),
      remainingMs: 6 * 60 * 1000 + 5000,
      taps: taps,
    ));

    expect(find.text('06:05'), findsOneWidget);
    expect(find.text('running'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('timer-pause')));
    expect(taps['pause'], 1);

    await tester.tap(find.byKey(const ValueKey('timer-stop')));
    expect(taps['stop'], 1);
  });

  testWidgets('a paused timer says paused and offers resume', (tester) async {
    final taps = <String, int>{};
    await tester.pumpWidget(_harness(
      timer: _timer(pausedAt: _start.add(const Duration(minutes: 1))),
      remainingMs: 9 * 60 * 1000,
      taps: taps,
    ));

    expect(find.text('paused'), findsOneWidget);
    expect(find.byKey(const ValueKey('timer-pause')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('timer-resume')));
    expect(taps['resume'], 1);
  });

  testWidgets('a finished timer says so and offers to start again',
      (tester) async {
    final taps = <String, int>{};
    await tester.pumpWidget(_harness(
      timer: _timer(),
      remainingMs: 0,
      taps: taps,
    ));

    expect(find.text("time's up"), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.byKey(const ValueKey('timer-pause')), findsNothing);
    expect(find.byKey(const ValueKey('timer-resume')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('timer-start')));
    expect(taps['start'], 1);
  });

  testWidgets('a timer on another step says which step', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ShokuTheme.light(),
      home: Scaffold(
        body: CookTimerCard(
          timer: _timer(),
          remainingMs: 4 * 60 * 1000,
          suggestedMinutes: 5,
          currentStep: 5,
          onStart: () {},
          onPause: () {},
          onResume: () {},
          onStop: () {},
        ),
      ),
    ));

    expect(find.text('step 3 · running'), findsOneWidget);
    expect(find.text('04:00'), findsOneWidget);
  });
}
