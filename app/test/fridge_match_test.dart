import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/db/pantry_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/data/models/fridge_match.dart';
import 'package:food_finder/data/models/pantry_item.dart';
import 'package:food_finder/presentation/screens/dish/dish_screen.dart';
import 'package:food_finder/presentation/state/journal_store.dart';

PantryItem _item(
  String name, {
  double? quantity,
  PantryUnit? unit,
  List<String> aliases = const [],
  bool wanted = false,
  String id = 'p',
}) =>
    PantryItem(
      id: id,
      name: name,
      quantity: quantity,
      unit: unit,
      aliases: aliases,
      wanted: wanted,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Dish _dish({List<String>? ingredients, int versions = 1}) => Dish(
      id: 'd1',
      title: 'Paneer Tikka',
      subtitle: 'From Ravi',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.toCook,
      minutes: 22,
      steps: const ['Heat the oil'],
      versions: [
        for (var v = 1; v <= versions; v++)
          RecipeVersion(
            id: 'v$v',
            number: v,
            changes: v == 1 ? const [] : const ['More salt'],
            ingredients: ingredients ?? const ['400 g paneer', '2 tbsp oil'],
            createdAt: DateTime(2026, 1, v),
            steps: const ['Heat the oil'],
          ),
      ],
      cooks: const [],
    );

void main() {
  group('one line, answered by the shelf', () {
    test('enough is the stock amount', () {
      final fridge = FridgeMatcher([
        _item('paneer', quantity: 400, unit: PantryUnit.g),
      ]);
      final match = fridge.match('400 g paneer');
      expect(match.state, FridgeState.inFridge);
      expect(match.label, 'In the fridge · 400 g');
    });

    test('short says how much of the ask you have', () {
      final fridge = FridgeMatcher([
        _item('paneer', quantity: 200, unit: PantryUnit.g),
      ]);
      final match = fridge.match('400 g paneer');
      expect(match.state, FridgeState.some);
      expect(match.label, 'Some in the fridge · 200 g of 400 g');
    });

    test('units that do not compare are some, never enough', () {
      final fridge = FridgeMatcher([
        _item('coriander', quantity: 1, unit: PantryUnit.bunch),
      ]);
      expect(fridge.match('200 g coriander').label, 'Some in the fridge');
    });

    test('an amount the shelf never recorded is not an amount you have', () {
      final fridge = FridgeMatcher([_item('paneer')]);
      expect(fridge.match('400 g paneer').label, 'Some in the fridge');
      expect(fridge.match('paneer').label, 'Some in the fridge');
    });

    test('a line that states no amount is never "enough"', () {
      final fridge = FridgeMatcher([
        _item('paneer', quantity: 900, unit: PantryUnit.g),
      ]);
      final match = fridge.match('paneer');
      expect(match.state, FridgeState.some,
          reason: 'some paneer is not four hundred grams of it');
      expect(match.label, 'Some in the fridge');
    });

    test('an alias is the receipt meeting the recipe', () {
      final fridge = FridgeMatcher([
        _item('butter', quantity: 500, unit: PantryUnit.g,
            aliases: const ['AMUL BUTTER 500G']),
      ]);
      expect(fridge.match('500 g amul butter 500g').state, FridgeState.inFridge);
    });

    test('a plural is the same shelf as its singular', () {
      final fridge = FridgeMatcher([
        _item('onion', quantity: 3, unit: PantryUnit.pcs),
      ]);
      expect(fridge.match('2 onions').state, FridgeState.inFridge);
    });

    test('a wanted row is on the list, not in the fridge', () {
      final fridge = FridgeMatcher([_item('paneer', wanted: true)]);
      expect(fridge.match('400 g paneer').label, 'On your list');
    });

    test('looked, and it is not there', () {
      final fridge = FridgeMatcher([_item('paneer', quantity: 200, unit: PantryUnit.g)]);
      expect(fridge.match('200 g lime').label, 'Missing');
    });

    test('a substring is not a match', () {
      final fridge = FridgeMatcher([_item('oil', quantity: 1, unit: PantryUnit.l)]);
      expect(fridge.match('100 g olives').label, 'Missing',
          reason: 'olives are not oil, however similar the letters');
    });

    test('exact wins over a shared word', () {
      final fridge = FridgeMatcher([
        _item('olive oil', quantity: 1, unit: PantryUnit.l, id: 'a'),
        _item('oil', quantity: 1, unit: PantryUnit.l, id: 'b'),
      ]);
      expect(fridge.match('2 tbsp oil').item?.name, 'oil');
    });

    test('two items are never summed into enough', () {
      final fridge = FridgeMatcher([
        _item('paneer', quantity: 200, unit: PantryUnit.g, id: 'a'),
        _item('paneer block', quantity: 200, unit: PantryUnit.g, id: 'b'),
      ]);
      final match = fridge.match('400 g paneer');
      expect(match.state, FridgeState.some,
          reason: 'the best single match answers, not the total');
      expect(match.label, 'Some in the fridge · 200 g of 400 g');
    });

    test('one item may cover two lines', () {
      final fridge = FridgeMatcher([
        _item('paneer', quantity: 400, unit: PantryUnit.g),
      ]);
      expect(fridge.match('200 g paneer').state, FridgeState.inFridge);
      expect(fridge.match('100 g paneer').state, FridgeState.inFridge);
    });

    test('what the fridge cannot answer is never called missing', () {
      final fridge = FridgeMatcher([_item('paneer', quantity: 1, unit: PantryUnit.kg)]);

      expect(fridge.match('to taste').state, FridgeState.notTracked);
      expect(fridge.match('1 tsp spice').state, FridgeState.notTracked);
      expect(fridge.match('').state, FridgeState.notTracked);
      expect(fridge.match('as needed').state, FridgeState.notTracked);
    });

    test('a fridge that was never set up tracks nothing', () {
      final fridge = FridgeMatcher(const []);
      final match = fridge.match('400 g paneer');
      expect(match.state, FridgeState.notTracked);
      expect(match.label, 'Not tracked');
    });
  });

  group('the strip', () {
    FridgeCoverage coverageFor(List<String> lines, List<PantryItem> pantry) {
      final matcher = FridgeMatcher(pantry);
      return FridgeCoverage(
        matches: [for (final line in lines) matcher.match(line)],
        lines: lines,
        unset: matcher.isUnset,
      );
    }

    test('counts lines, and names the missing ones once', () {
      final coverage = coverageFor(
        ['400 g paneer', '2 tbsp oil', 'salt', 'salt'],
        [
          _item('paneer', quantity: 400, unit: PantryUnit.g),
          _item('oil', wanted: true),
        ],
      );

      expect(coverage.strip, '1 of 4 in your fridge · 1 on your list · 2 missing');
      expect(coverage.missingNames, ['salt'],
          reason: 'two mentions are one shopping-list line');
    });

    test('an unset fridge says so instead of counting', () {
      final coverage = coverageFor(['400 g paneer'], const []);
      expect(coverage.strip, 'Not tracked · Set up your fridge');
    });
  });

  group('on the page', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await JournalRepository(db).seed([_dish()]);
    });
    tearDown(() async => db.close());

    Widget app() => ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            theme: ShokuTheme.light(),
            home: const DishScreen(dishId: 'd1'),
          ),
        );

    testWidgets('adding the missing names writes wanted rows, with Undo',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await PantryRepository(db).add(name: 'paneer', quantity: 400, unit: PantryUnit.g);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(find.text('Add 1 missing to list'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('fridge-add-missing')));
      await tester.pumpAndSettle();

      var rows = await PantryRepository(db).load();
      final oil = rows.where((r) => r.wanted).toList();
      expect(oil.map((r) => r.name), ['oil']);
      expect(find.text('1 added to your list'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      rows = await PantryRepository(db).load();
      expect(rows.where((r) => r.wanted), isEmpty);
    });

    testWidgets('a version that disappears is named, not silently swapped',
        (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await JournalRepository(db).seed([_dish(versions: 2)]);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('v2'), findsOneWidget, reason: 'v2 is on screen');

      // A pull from another device drops the head. The page must say what it
      // did rather than quietly showing a shorter recipe.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(DishScreen)),
      );
      await db.customStatement("DELETE FROM version_rows WHERE id = 'v2'");
      await container.read(journalStoreProvider.notifier).refresh();
      await tester.pumpAndSettle();

      expect(find.text('v2 is gone — showing v1'), findsOneWidget);
    });
  });
}
