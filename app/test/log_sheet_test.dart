import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/presentation/screens/log/log_sheet.dart';
import 'package:food_finder/presentation/state/journal_store.dart';

Dish _dish() => Dish(
      id: 'd1',
      title: 'Paneer',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.toCook,
      minutes: 20,
      steps: const ['Fry the paneer'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 1,
          changes: const [],
          ingredients: const ['200 g paneer'],
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      cooks: const [],
    );

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await JournalRepository(db).seed([_dish()]);
  });
  tearDown(() async => db.close());

  Widget sheet() => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: ShokuTheme.light(),
          home: Scaffold(body: LogSheet(dish: _dish())),
        ),
      );

  testWidgets('a note alone is enough to save, and it is kept', (tester) async {
    await tester.pumpWidget(sheet());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.enterText(
      find.byType(TextField).at(0),
      'The pan ran hot, so I pulled it early',
    );
    await tester.pump();

    await tester.tap(find.text('Save tonight'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final dish = (await JournalRepository(db).loadDishes()).single;
    expect(dish.cooks, hasLength(1));
    expect(dish.cooks.single.note, 'The pan ran hot, so I pulled it early');
    // A local path is never written as a photo URL.
    expect(dish.cooks.single.photoKey, isEmpty);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('with nothing recorded there is nothing to save', (tester) async {
    await tester.pumpWidget(sheet());
    await tester.pump(const Duration(milliseconds: 200));

    final button = tester.widget<Text>(find.text('Save tonight'));
    expect(button.data, 'Save tonight');
    // Tapping with nothing in it writes nothing.
    await tester.tap(find.text('Save tonight'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final dish = (await JournalRepository(db).loadDishes()).single;
    expect(dish.cooks, isEmpty);

    await tester.pumpWidget(const SizedBox());
  });
}
