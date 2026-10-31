import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/presentation/screens/journal/journal_screen.dart';
import 'package:food_finder/presentation/state/journal_providers.dart';

Dish _dish({CookMood mood = CookMood.comfort, int rating = 4}) => Dish(
      id: 'd1',
      title: 'Paneer Tikka',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.cooked,
      minutes: 20,
      steps: const ['Fry'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 1,
          changes: const [],
          ingredients: const ['paneer'],
          createdAt: DateTime(2026, 10, 30),
        ),
      ],
      cooks: [
        CookLog(
          id: 'c1',
          cookedAt: DateTime(2026, 10, 30, 20, 15),
          versionNumber: 1,
          versionId: 'v1',
          photoUrl: '',
          outcome: CookOutcome.good,
          note: '',
          changes: const [],
          mood: mood,
          rating: rating,
        ),
      ],
    );

void main() {
  testWidgets('a cook entry shows the mood and the rating, quietly',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [dishesProvider.overrideWithValue([_dish()])],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const Scaffold(body: JournalScreen()),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('cook-mood-rating')), findsOneWidget);
    expect(find.text('comfort · 4/5'), findsOneWidget);

    final text = tester.widget<Text>(
      find.byKey(const ValueKey('cook-mood-rating')),
    );
    final context = tester.element(
      find.byKey(const ValueKey('cook-mood-rating')),
    );
    expect(text.style?.color, context.colors.inkMuted);
    expect(text.style?.fontSize, ShokuType.bodySmall.fontSize);
  });

  testWidgets('the words follow the log, not a default', (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        dishesProvider
            .overrideWithValue([_dish(mood: CookMood.project, rating: 2)]),
      ],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const Scaffold(body: JournalScreen()),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('project · 2/5'), findsOneWidget);
  });
}
