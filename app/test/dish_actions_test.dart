import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/presentation/screens/recipes/recipes_screen.dart';
import 'package:food_finder/presentation/state/journal_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:food_finder/presentation/widgets/kit/dish_image.dart';

Dish _dish({DishStatus status = DishStatus.toCook}) => Dish(
      id: 'd1',
      title: 'Paneer Tikka',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: status,
      minutes: 20,
      steps: const ['Fry'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 0,
          changes: const [],
          ingredients: const ['paneer'],
          createdAt: DateTime(2026, 1, 1),
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
  });
  tearDown(() async => db.close());

  Widget app() => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: ShokuTheme.light(),
          home: const Scaffold(body: RecipesScreen()),
        ),
      );

  Future<void> openSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.longPress(find.byType(ShokuDishImage).first);
    await tester.pumpAndSettle();
  }

  testWidgets('a long press offers the actions, as a sheet', (tester) async {
    await repo.seed([_dish()]);
    await openSheet(tester);

    expect(find.text('Mark as cooked'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Keep it'), findsOneWidget);
  });

  testWidgets('a cooked dish offers the way back', (tester) async {
    await repo.seed([_dish(status: DishStatus.cooked)]);
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 600));

    // The Cookbook opens on To cook; the cooked dish lives on the other side.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(RecipesScreen)),
    );
    container.read(libraryFilterProvider.notifier).state = LibraryFilter.cooked;
    await tester.pump(const Duration(milliseconds: 200));

    await tester.longPress(find.byType(ShokuDishImage).first);
    await tester.pumpAndSettle();

    expect(find.text('Move back to To cook'), findsOneWidget);
  });

  testWidgets('mark as cooked flips the status and moves the card',
      (tester) async {
    await repo.seed([_dish()]);
    await openSheet(tester);

    await tester.tap(find.byKey(const ValueKey('dish-action-status')));
    await tester.pumpAndSettle();

    final saved = (await repo.loadDishes()).single;
    expect(saved.status, DishStatus.cooked);
    expect((await db.select(db.dishRows).getSingle()).dirty, 1,
        reason: 'the change has to reach the server');

    // Same list, other side of the switch: the card is gone from To cook.
    expect(find.byType(ShokuDishImage), findsNothing);
  });

  testWidgets('delete asks first, then writes a tombstone', (tester) async {
    await repo.seed([_dish()]);
    await openSheet(tester);

    await tester.tap(find.byKey(const ValueKey('dish-action-delete')));
    await tester.pumpAndSettle();

    expect(find.text('Remove this dish?'), findsOneWidget);
    expect(
      find.textContaining('leaves your journal'),
      findsOneWidget,
      reason: 'the copy says where it goes, not that it is gone forever',
    );

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    final row = await db.select(db.dishRows).getSingle();
    expect(row.deletedAt, isNotNull,
        reason: 'a tombstone, never a hard delete');
    expect(row.dirty, 1, reason: 'the tombstone has to reach the server');
    expect(await repo.loadDishes(), isEmpty, reason: 'it leaves the journal');
    expect(find.byType(ShokuDishImage), findsNothing);
  });

  testWidgets('keeping it changes nothing', (tester) async {
    await repo.seed([_dish()]);
    await openSheet(tester);

    await tester.tap(find.byKey(const ValueKey('dish-action-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep it').last);
    await tester.pumpAndSettle();

    final row = await db.select(db.dishRows).getSingle();
    expect(row.deletedAt, isNull);
    expect(await repo.loadDishes(), hasLength(1));
  });
}
