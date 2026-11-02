import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/db/pantry_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/data/mock/sample_recipe.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/models/pantry_item.dart';
import 'package:food_finder/presentation/screens/dish/dish_screen.dart';
import 'package:food_finder/presentation/state/journal_providers.dart';
import 'package:food_finder/data/sync/sync_repository.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:food_finder/presentation/state/pantry_providers.dart';

void main() {
  late AppDatabase db;
  late JournalRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = JournalRepository(db);
  });
  tearDown(() async => db.close());

  JournalStore store() {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    return container.read(journalStoreProvider.notifier);
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('a signed-out kitchen gets exactly one sample', () async {
    final journal = store();
    await settle();

    await journal.ensureSample(signedIn: false, sample: SampleRecipe.dish());
    await journal.ensureSample(signedIn: false, sample: SampleRecipe.dish());
    await settle();

    final dishes = await repo.loadDishes();
    expect(dishes, hasLength(1));
    expect(dishes.single.isSample, isTrue);
    expect(dishes.single.title, 'Paneer Tikka');
    expect(dishes.single.versions, hasLength(1));
  });

  test('the sample is a local row: sync never sees it', () async {
    final journal = store();
    await settle();
    await journal.ensureSample(signedIn: false, sample: SampleRecipe.dish());
    await settle();

    final payload = await SyncRepository(db, repo).dirtyPayload();
    expect(payload['dishes'], isEmpty);
    expect(payload['versions'], isEmpty);
    expect((await db.select(db.dishRows).getSingle()).dirty, 0);
  });

  test('signing in takes it away, and signing out does not bring it back',
      () async {
    final journal = store();
    await settle();
    await journal.ensureSample(signedIn: false, sample: SampleRecipe.dish());
    await settle();

    await journal.ensureSample(signedIn: true, sample: SampleRecipe.dish());
    await settle();

    expect(await repo.loadDishes(), isEmpty);
    expect(await db.select(db.dishRows).get(), isEmpty,
        reason: 'a hard delete, not a tombstone the server would inherit');
    expect(await repo.sampleWasRemoved(), isTrue);

    await journal.ensureSample(signedIn: false, sample: SampleRecipe.dish());
    await settle();
    expect(await repo.loadDishes(), isEmpty,
        reason: 'once there is an account, the starter dish is gone for good');
  });

  testWidgets('the sample says it is one, and what an account adds',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final sample = SampleRecipe.dish();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        dishProvider.overrideWith((ref, id) => sample),
      ],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const DishScreen(dishId: SampleRecipe.dishId),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('SAMPLE'), findsOneWidget);
    expect(
      find.text('Sign in to import your own reels and talk to the recipe.'),
      findsOneWidget,
    );
  });

  test('the whole loop works on the sample', () async {
    final journal = store();
    await settle();
    await journal.ensureSample(signedIn: false, sample: SampleRecipe.dish());
    await settle();

    // Cook it, fork a version, and leave a log.
    final number = await repo.commitCook(
      dishId: SampleRecipe.dishId,
      mood: CookMood.comfort,
      rating: 5,
      note: 'More chilli',
      changes: const ['More chilli'],
    );
    expect(number, 2);

    final dish = (await repo.loadDishes()).single;
    expect(dish.versions, hasLength(2));
    expect(dish.cooks, hasLength(1));
    expect(dish.cooks.single.versionNumber, 2);

    // And the fridge can deduct from it: 400 g paneer, 200 g used.
    await PantryRepository(db).add(
        name: 'paneer', quantity: 400, unit: PantryUnit.g);
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final pantry = container.read(pantryStoreProvider.notifier);
    await settle();

    final paneer = (await PantryRepository(db).load()).single;
    final skipped = await pantry.deduct([
      (item: paneer, amount: 200, unit: PantryUnit.g),
    ]);
    expect(skipped, 0);
    expect((await PantryRepository(db).load()).single.quantity, 200);
  });
}
