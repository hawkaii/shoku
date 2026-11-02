import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/presentation/screens/dish/dish_screen.dart';
import 'package:food_finder/presentation/state/journal_store.dart';

void main() {
  testWidgets('debug dump', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = JournalRepository(db);
    await repo.seed([
      Dish(
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
            ingredients: const ['400 g paneer', '2 tbsp oil', 'salt'],
            createdAt: DateTime(2026, 1, 1),
            steps: const ['Heat the oil', 'Add the paneer'],
          ),
        ],
        cooks: const [],
      ),
    ]);
    await repo.commitCook(
      dishId: 'd1',
      mood: CookMood.comfort,
      rating: 5,
      note: 'Better with more chilli',
      changes: const ['More chilli'],
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const DishScreen(dishId: 'd1'),
      ),
    ));
    await tester.pumpAndSettle();
    for (final e in find.byType(Text).evaluate()) {
      final t = e.widget as Text;
      if ((t.data ?? '').toLowerCase().contains('nail')) {
        // ignore: avoid_print
        print('FOUND TEXT: ${t.data}');
      }
    }
    await db.close();
  });
}
