import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/db/pantry_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/data/models/pantry_item.dart';
import 'package:food_finder/presentation/screens/dish/dish_screen.dart';
import 'package:food_finder/presentation/state/journal_store.dart';

Dish _dish({List<String>? ingredients}) => Dish(
      id: 'd1',
      title: 'Paneer Tikka',
      subtitle: 'From Ravi',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.toCook,
      minutes: 22,
      steps: const ['Heat the oil', 'Add the paneer'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 1,
          changes: const [],
          ingredients:
              ingredients ?? const ['400 g paneer', '2 tbsp oil', 'salt'],
          createdAt: DateTime(2026, 1, 1),
          steps: const ['Heat the oil', 'Add the paneer'],
        ),
      ],
      cooks: const [],
    );

void main() {
  late AppDatabase db;
  late JournalRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = JournalRepository(db);
    await repo.seed([_dish()]);
  });
  tearDown(() async => db.close());

  Widget app() => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: ShokuTheme.light(),
          home: const DishScreen(dishId: 'd1'),
        ),
      );

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
  }

  testWidgets('everything that matters fits above the fold', (tester) async {
    await PantryRepository(db)
        .add(name: 'paneer', quantity: 400, unit: PantryUnit.g);
    await open(tester);

    for (final key in [
      'fridge-strip',
      'ingredients-toggle',
      'steps-toggle',
      'cook-mode-button',
    ]) {
      final rect = tester.getRect(find.byKey(ValueKey(key)));
      expect(rect.bottom, lessThanOrEqualTo(844),
          reason: '$key has to be reachable without scrolling');
    }
    expect(find.text('Paneer Tikka'), findsOneWidget);
  });

  testWidgets('the strip counts lines, and offers the missing ones',
      (tester) async {
    await PantryRepository(db)
        .add(name: 'paneer', quantity: 400, unit: PantryUnit.g);
    await PantryRepository(db).add(name: 'oil', wanted: true);
    await open(tester);

    expect(find.text('1 of 3 in your fridge · 1 on your list · 1 missing'),
        findsOneWidget);
    expect(find.text('Add 1 missing to list'), findsOneWidget);
  });

  testWidgets('ingredients fold into a summary that carries the version',
      (tester) async {
    await open(tester);

    expect(find.text('3 ingredients'), findsOneWidget);
    expect(find.byKey(const ValueKey('version-picker')), findsOneWidget);
    expect(find.byKey(const ValueKey('ingredient-line-0')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('ingredients-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('400 g paneer'), findsOneWidget);
    expect(find.byKey(const ValueKey('ingredient-fridge-0')), findsOneWidget);
  });

  testWidgets('steps fold into a summary and carry a speaker and an ask',
      (tester) async {
    await open(tester);

    expect(find.text('2 steps · 22 min'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('steps-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('Heat the oil'), findsOneWidget);
    expect(find.byKey(const ValueKey('step-speak-0')), findsOneWidget);
    expect(find.text('Ask about step 1'), findsOneWidget);
  });

  testWidgets('history is last, collapsed to outcomes, and expands to the log',
      (tester) async {
    await repo.commitCook(
      dishId: 'd1',
      mood: CookMood.comfort,
      rating: 5,
      note: 'Better with more chilli',
      changes: const ['More chilli'],
    );
    await open(tester);
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('history-toggle')), 200);
    await tester.pumpAndSettle();

    expect(find.text('V2 · NAILED IT'), findsOneWidget);
    expect(find.text('Better with more chilli'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('history-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('Better with more chilli'), findsOneWidget);
    expect(find.text('What altered'), findsOneWidget);
  });

  testWidgets('the overflow holds cooking actions, not the page body',
      (tester) async {
    await open(tester);

    await tester.tap(find.byKey(const ValueKey('dish-overflow')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dish-menu-cook')), findsOneWidget);
    expect(find.byKey(const ValueKey('dish-menu-status')), findsOneWidget);
  });

  testWidgets('the header carries a speaker, and the orb is the assistant door',
      (tester) async {
    await open(tester);

    expect(find.byKey(const ValueKey('dish-speak')), findsOneWidget);
    expect(find.byKey(const ValueKey('bot-orb')), findsOneWidget);
    expect(find.byKey(const ValueKey('dish-ask')), findsNothing,
        reason: 'the old ASK chip was replaced by the one assistant');
  });
}
