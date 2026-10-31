import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/import_service.dart';
import 'package:food_finder/presentation/widgets/kit/step_ingredients.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Widget _harness(List<String> ingredients, List<int>? indices) => MaterialApp(
      theme: ShokuTheme.light(),
      home: Scaffold(
        body: StepIngredientsLine(ingredients: ingredients, indices: indices),
      ),
    );

const _key = ValueKey('step-ingredients');

void main() {
  group('the line under a step', () {
    testWidgets('renders nothing when the parse has no links', (tester) async {
      await tester.pumpWidget(_harness(['olive oil'], null));
      expect(find.byKey(_key), findsNothing);

      await tester.pumpWidget(_harness(['olive oil'], const []));
      expect(find.byKey(_key), findsNothing);
    });

    testWidgets('cited names render in the order the server sent',
        (tester) async {
      await tester.pumpWidget(
        _harness(['olive oil', 'garlic', 'chilli'], const [2, 0]),
      );

      final text = tester.widget<Text>(find.byKey(_key));
      expect(text.data, 'chilli · olive oil');
    });

    testWidgets('a stated amount is quoted verbatim, and stays muted',
        (tester) async {
      await tester.pumpWidget(
        _harness(['2 tbsp olive oil', 'garlic'], const [0, 1]),
      );

      final text = tester.widget<Text>(find.byKey(_key));
      expect(text.data, '2 tbsp olive oil · garlic');

      // Body sans, muted, inline — never the stat face or the accent, which are
      // the treatments that make a number read as measured.
      final context = tester.element(find.byKey(_key));
      expect(text.style?.fontSize, ShokuType.bodySmall.fontSize);
      expect(text.style?.color, context.colors.inkMuted);
      expect(text.style?.fontFamily, ShokuType.bodySmall.fontFamily);
      expect(text.textAlign, isNot(TextAlign.right));
    });

    testWidgets('an index the list does not have is dropped, not clamped',
        (tester) async {
      await tester.pumpWidget(
        _harness(['olive oil', 'garlic'], const [9, 1, -3]),
      );

      expect(tester.takeException(), isNull);
      final text = tester.widget<Text>(find.byKey(_key));
      expect(text.data, 'garlic');
    });

    testWidgets('every index out of range means nothing is shown',
        (tester) async {
      await tester.pumpWidget(_harness(['olive oil'], const [4, 7]));
      expect(find.byKey(_key), findsNothing);
    });
  });

  group('import keeps the links locally', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() async => db.close());

    ImportService service(Map<String, dynamic> content) => ImportService(
          api: ApiClient(
            baseUrl: 'https://api.test',
            tokenProvider: () => 'jwt',
            httpClient: MockClient((request) async {
              return http.Response(jsonEncode(content), 200);
            }),
          ),
          repository: JournalRepository(db),
        );

    Map<String, dynamic> content(Object? links) => {
          'shortcode': 'SC',
          'recipe': {
            'title': 'Paneer',
            'servings': 2,
            'minutes': 20,
            'kcal': 0,
            'protein': 0,
            'ingredients': [
              {'name': 'olive oil', 'amount': '2 tbsp', 'grams': null},
              {'name': 'garlic', 'amount': null, 'grams': null},
            ],
            'steps': ['Heat the oil', 'Add the garlic'],
            'tags': <String>[],
          },
          'creator': 'Ravi',
          'url': 'https://instagram.com/reel/SC/',
          'step_ingredients': links,
        };

    test('step_ingredients lands on the imported version', () async {
      await service(content([
        [0],
        [1, 0],
      ])).createDish('SC');

      final version = (await JournalRepository(db).loadDishes()).single.versions.single;
      expect(version.stepIngredientLinks(0), [0]);
      expect(version.stepIngredientLinks(1), [1, 0]);
    });

    test('a null step_ingredients leaves the version with no links', () async {
      await service(content(null)).createDish('SC');

      final version = (await JournalRepository(db).loadDishes()).single.versions.single;
      expect(version.stepIngredients, isNull);
      expect(version.stepIngredientLinks(0), isNull);
    });
  });
}
