import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/main.dart';
import 'package:food_finder/presentation/screens/cook/cook_mode_screen.dart';
import 'package:food_finder/presentation/screens/dish/dish_screen.dart';
import 'package:food_finder/presentation/state/auth_providers.dart';
import 'package:food_finder/presentation/state/cook_timer_providers.dart';
import 'package:food_finder/presentation/state/journal_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:food_finder/presentation/state/shoku_providers.dart';

import 'support/fake_timer_alerts.dart';

Dish _dish() => Dish(
      id: 'd1',
      title: 'Paneer butter masala',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@me',
      status: DishStatus.toCook,
      minutes: 20,
      steps: const ['Mix for 5 min', 'Chop the onion', 'Simmer 10 min'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 1,
          changes: const [],
          ingredients: const ['200 g paneer'],
          createdAt: DateTime(2026, 1, 1),
          steps: const ['Mix for 5 min', 'Chop the onion', 'Simmer 10 min'],
        ),
      ],
      cooks: const [],
    );

void main() {
  testWidgets('the orb sits on the trailing edge, above the tab bar',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await JournalRepository(db).seed([_dish()]);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authReadyProvider.overrideWith((ref) async {}),
        databaseProvider.overrideWithValue(db),
        onboardingDoneProvider.overrideWith((ref) => true),
      ],
      child: const ShokuApp(),
    ));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(seconds: 4));

    final orb = find.byKey(const ValueKey('bot-orb'));
    expect(orb, findsOneWidget);
    final rect = tester.getRect(orb);
    expect(rect.width, 56);
    expect(rect.right, closeTo(390 - 16, 0.5));
    // The body ends above the 64 px bar; twelve more pixels of air.
    expect(rect.bottom, closeTo(844 - 64 - 12, 1.5));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping the orb opens the kitchen thread with its scope chip',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await JournalRepository(db).seed([_dish()]);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authReadyProvider.overrideWith((ref) async {}),
        databaseProvider.overrideWithValue(db),
        onboardingDoneProvider.overrideWith((ref) => true),
      ],
      child: const ShokuApp(),
    ));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(seconds: 4));

    await tester.tap(find.byKey(const ValueKey('bot-orb')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('bot-sheet')), findsOneWidget);
    expect(find.byKey(const ValueKey('bot-scope-chip')), findsOneWidget);
    expect(find.text('NO DISH'), findsOneWidget);
    expect(find.byKey(const ValueKey('bot-input')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the dish page opens a dish-scoped thread, and has no ASK chip',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await JournalRepository(db).seed([_dish()]);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        dishProvider.overrideWith((ref, id) => _dish()),
      ],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const DishScreen(dishId: 'd1'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dish-ask')), findsNothing,
        reason: 'the old ASK chip is gone; the orb is the only door');
    expect(find.byKey(const ValueKey('bot-orb')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bot-orb')));
    await tester.pumpAndSettle();
    expect(find.text('Paneer butter masala'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('cook mode carries a 40 px chip in the step header, not the orb',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        dishProvider.overrideWith((ref, id) => _dish()),
        timerAlertsProvider.overrideWithValue(FakeTimerAlerts()),
      ],
      child: MaterialApp(
        theme: ShokuTheme.dark(),
        home: const CookModeScreen(dishId: 'd1'),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const ValueKey('bot-inline-chip')), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('bot-inline-chip'))).height,
        40);
    expect(find.byKey(const ValueKey('bot-orb')), findsNothing,
        reason: 'the orb must never float over the cook timer');
    // No FAB pinned over the timer any more.
    expect(find.byKey(const ValueKey('cook-ask-fab')), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });
}
