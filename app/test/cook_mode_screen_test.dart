import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/cook_timer_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/data/models/cook_timer.dart';
import 'package:food_finder/presentation/screens/cook/cook_mode_screen.dart';
import 'package:food_finder/presentation/state/cook_timer_providers.dart';
import 'package:food_finder/presentation/state/journal_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';

import 'support/fake_timer_alerts.dart';

Dish _dish({String versionId = 'v1'}) => Dish(
      id: 'd1',
      title: 'Paneer',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@me',
      status: DishStatus.cooked,
      minutes: 20,
      steps: const ['Mix for 5 min', 'Chop the onion', 'Simmer 10 min', 'Plate'],
      versions: [
        RecipeVersion(
          id: versionId,
          number: 1,
          changes: const [],
          ingredients: const ['paneer'],
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      cooks: const [],
    );

Future<void> _pumpCook(
  WidgetTester tester, {
  required AppDatabase db,
  required Dish dish,
  FakeTimerAlerts? alerts,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        dishProvider.overrideWith((ref, id) => dish),
        timerAlertsProvider.overrideWithValue(alerts ?? FakeTimerAlerts()),
      ],
      child: MaterialApp(
        theme: ShokuTheme.dark(),
        home: const CookModeScreen(dishId: 'd1'),
      ),
    ),
  );
  // The timer is read from disk after the first frame; a ticker keeps the tree
  // from ever settling, so pump a fixed amount instead of settling.
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets('reopening the cook screen lands on the step with the timer',
      (tester) async {
    final startedAt = DateTime.now().subtract(const Duration(minutes: 3));
    await CookTimerRepository(db).write(CookTimer(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 2,
      startedAt: startedAt,
      duration: const Duration(minutes: 10),
    ));

    await _pumpCook(tester, db: db, dish: _dish());

    // 10 minutes asked, 3 spent: the clock is derived, not counted.
    expect(find.text('07:00'), findsOneWidget);
    expect(find.text('running'), findsOneWidget);
    expect(find.text('3/4'), findsOneWidget, reason: 'the running step opens');

    // Dispose the screen before the test ends so its ticker goes with it.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a fork clears the timer and says so', (tester) async {
    await CookTimerRepository(db).write(CookTimer(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 2,
      startedAt: DateTime.now(),
      duration: const Duration(minutes: 10),
    ));

    // The dish has forked to v2 since the timer was started.
    await _pumpCook(tester, db: db, dish: _dish(versionId: 'v2'));

    expect(find.text('running'), findsNothing);
    expect(find.textContaining('Timer cleared'), findsOneWidget);
    expect(await CookTimerRepository(db).read(), isNull,
        reason: 'the old step index means nothing in the new version');

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a running timer can be paused, resumed and stopped',
      (tester) async {
    final alerts = FakeTimerAlerts();
    await _pumpCook(tester, db: db, dish: _dish(), alerts: alerts);

    // Step 1 mentions five minutes, so there is something to start.
    await tester.tap(find.byKey(const ValueKey('timer-start')));
    await tester.pump();
    expect(find.text('running'), findsOneWidget);

    // The notification is in the app's language, with the step counted from one,
    // because the screen — not the store — has the localizations.
    expect(alerts.scheduledCopies.single.title, 'Timer is up');
    expect(alerts.scheduledCopies.single.body, contains('Step 1'));

    await tester.tap(find.byKey(const ValueKey('timer-pause')));
    await tester.pump();
    expect(find.text('paused'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('timer-resume')));
    await tester.pump();
    expect(find.text('running'), findsOneWidget);
    expect(alerts.scheduledCopies, hasLength(2), reason: 'resume re-arms it');

    await tester.tap(find.byKey(const ValueKey('timer-stop')));
    await tester.pump();
    expect(find.text('running'), findsNothing);
    expect(find.text('start 5 min timer'), findsOneWidget);
    expect(await CookTimerRepository(db).read(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('leaving the step ends its timer and its alert', (tester) async {
    final alerts = FakeTimerAlerts();
    await _pumpCook(tester, db: db, dish: _dish(), alerts: alerts);

    await tester.tap(find.byKey(const ValueKey('timer-start')));
    await tester.pump();
    expect(alerts.scheduled, hasLength(1), reason: 'starting mirrors it');

    await tester.tap(find.text('Next step'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('2/4'), findsOneWidget, reason: 'the page actually moved');
    expect(find.text('running'), findsNothing);
    expect(await CookTimerRepository(db).read(), isNull);
    expect(alerts.cancelled, contains(alerts.scheduledIds.single),
        reason: 'a ring for a step already left is the bug');

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the cook header offers hands-free next to the step count',
      (tester) async {
    await _pumpCook(tester, db: db, dish: _dish());

    expect(find.byKey(const ValueKey('hands-free-toggle')), findsOneWidget);
    expect(find.text('Hands-free'), findsOneWidget);
    expect(find.text('1/4'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
