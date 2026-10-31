import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/presentation/screens/dish/dish_screen.dart';
import 'package:food_finder/presentation/state/journal_providers.dart';

Dish _dish({List<List<int>>? links, List<String> tags = const []}) => Dish(
      id: 'd1',
      title: 'Paneer Tikka',
      subtitle: 'From Ravi',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.toCook,
      minutes: 20,
      steps: const ['Heat the oil', 'Add the garlic'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 0,
          changes: const [],
          ingredients: const ['2 tbsp olive oil', 'garlic'],
          createdAt: DateTime(2026, 1, 1),
          steps: const ['Heat the oil', 'Add the garlic'],
          stepIngredients: links,
          tags: tags,
        ),
      ],
      cooks: const [],
    );

Widget _app(Dish dish) => ProviderScope(
      overrides: [dishProvider.overrideWith((ref, id) => dish)],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const DishScreen(dishId: 'd1'),
      ),
    );

void main() {
  test('a version keeps the links it was imported with, or none', () {
    expect(_dish(links: const [
      [0],
      [1],
    ]).versions.single.stepIngredientLinks(0), [0]);

    expect(_dish().versions.single.stepIngredients, isNull);
    expect(_dish().versions.single.stepIngredientLinks(0), isNull);
  });

  testWidgets('the dossier shows the method, with the ingredients each step uses',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(_dish(links: const [
      [0],
      [1],
    ])));
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text('Heat the oil'), findsOneWidget);
    expect(find.text('Add the garlic'), findsOneWidget);
    // The step's ingredient line, quoted from the recipe.
    expect(find.text('garlic'), findsWidgets);
    expect(find.byKey(const ValueKey('step-ingredients')), findsNWidgets(2));
  });

  testWidgets('a version with no links shows the method and no ingredient line',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(_dish()));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Heat the oil'), findsOneWidget);
    expect(find.byKey(const ValueKey('step-ingredients')), findsNothing);
    // No shortcode, nothing to publish, no affordance at all.
    expect(find.byKey(const ValueKey('share-wall')), findsNothing);
    // No tag, no honesty line.
    expect(find.byKey(const ValueKey('from-video-note')), findsNothing);
  });

  testWidgets('a silent reel says its amounts may be off, under the version',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(_dish(tags: const ['from video'])));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const ValueKey('from-video-note')), findsOneWidget);
    expect(find.text('read from the video — amounts may be off'),
        findsOneWidget);

    // Not a warning: muted body copy, and nowhere near the danger colour.
    final note = tester.widget<Text>(
      find.byKey(const ValueKey('from-video-note')),
    );
    final context = tester.element(find.byKey(const ValueKey('from-video-note')));
    expect(note.style?.color, context.colors.inkMuted);
    expect(note.style?.fontSize, ShokuType.bodySmall.fontSize);
  });
}
