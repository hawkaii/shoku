import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/presentation/screens/recipes/recipes_screen.dart';
import 'package:food_finder/presentation/state/journal_providers.dart';
import 'package:food_finder/presentation/widgets/kit/dish_image.dart';

Dish _dish(String id, String title, {int minutes = 30}) => Dish(
      id: id,
      title: title,
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@me',
      status: DishStatus.cooked,
      minutes: minutes,
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 1,
          changes: const [],
          ingredients: const [],
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      cooks: const [],
    );

Widget _harness(List<Dish> dishes) => ProviderScope(
      overrides: [
        dishesProvider.overrideWithValue(dishes),
        libraryFilterProvider.overrideWith((ref) => LibraryFilter.cooked),
      ],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const Scaffold(body: RecipesScreen()),
      ),
    );

void main() {
  setUp(() {});

  testWidgets('two columns, and the title sits under the photo', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness([
      _dish('a', 'Alpha'),
      _dish('b', 'Beta'),
    ]));
    await tester.pump(const Duration(milliseconds: 900));

    expect(tester.takeException(), isNull);

    final alpha = tester.getRect(find.text('Alpha'));
    final beta = tester.getRect(find.text('Beta'));
    expect(alpha.top, beta.top, reason: 'a fixed two-column row');
    expect(alpha.left < beta.left, isTrue);

    final photo = tester.getRect(find.byType(ShokuDishImage).first);
    expect(alpha.top, greaterThanOrEqualTo(photo.bottom),
        reason: 'the words never sit on the photograph');
  });

  testWidgets('a duration nobody recorded is left out entirely',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness([_dish('a', 'Alpha', minutes: 0)]));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.textContaining('min'), findsNothing);
    expect(find.textContaining('—'), findsNothing);
  });

  testWidgets('a known duration still reads plainly', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness([_dish('a', 'Alpha', minutes: 30)]));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('30 min · never cooked'), findsOneWidget);
  });
}
