import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';

/// The journal has to survive a restart, so these tests exercise the real
/// database — in memory, but through the same code path the app uses.
JournalRepository _repo(AppDatabase db) => JournalRepository(db);

Dish _dish({String id = 'd1'}) => Dish(
      id: id,
      title: 'Paneer',
      subtitle: 'Weeknight',
      coverUrl: 'https://example.com/a.jpg',
      sourceHandle: '@ravi',
      status: DishStatus.toCook,
      minutes: 30,
      steps: const ['Fry', 'Simmer'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 1,
          changes: const ['First attempt'],
          ingredients: const ['200 g paneer'],
          createdAt: DateTime(2026, 1, 1),
          steps: const ['Fry'],
        ),
      ],
      cooks: const [],
    );

void main() {
  late AppDatabase db;
  late JournalRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = _repo(db);
  });

  tearDown(() async => db.close());

  test('a seeded dish round-trips with its version', () async {
    await repo.seed([_dish()]);

    final dishes = await repo.loadDishes();
    expect(dishes, hasLength(1));
    expect(dishes.single.title, 'Paneer');
    expect(dishes.single.versions, hasLength(1));
    expect(dishes.single.versions.single.ingredients, ['200 g paneer']);
  });

  test('committing a cook appends a version and a cook log', () async {
    await repo.seed([_dish()]);

    await repo.commitCook(
      dishId: 'd1',
      mood: CookMood.comfort,
      rating: 5,
      note: 'Less salt',
      changes: const ['-1 tsp salt'],
    );

    final dish = (await repo.loadDishes()).single;
    expect(dish.versions, hasLength(2));
    expect(dish.cooks, hasLength(1));
    expect(dish.cooks.single.note, 'Less salt');
    expect(dish.status, DishStatus.cooked);
    // The new version inherits the previous ingredients and points at its parent.
    expect(dish.versions.last.ingredients, ['200 g paneer']);
    expect(dish.versions.last.parentVersionId, 'v1');
    // Cook IDs are client-generated UUIDs, not derived from a clock.
    expect(dish.cooks.single.id.length, greaterThan(8));
  });

  test('three cooks promote the dish to signature', () async {
    await repo.seed([_dish()]);
    for (var i = 0; i < 3; i++) {
      await repo.commitCook(
        dishId: 'd1',
        mood: CookMood.quick,
        rating: 4,
        note: '',
        changes: const [],
      );
    }
    final dish = (await repo.loadDishes()).single;
    expect(dish.cooks, hasLength(3));
    expect(dish.status, DishStatus.signature);
  });

  test('cooks come back newest first', () async {
    await repo.seed([_dish()]);
    for (var i = 0; i < 3; i++) {
      await repo.commitCook(
        dishId: 'd1',
        mood: CookMood.quick,
        rating: 3,
        note: 'cook $i',
        changes: const [],
      );
    }
    final dish = (await repo.loadDishes()).single;
    expect(dish.cooks.first.versionNumber, 4);
    expect(dish.cooks.last.versionNumber, 2);
    expect(dish.lastCook?.note, 'cook 2');
  });

  test('status can be overridden by hand', () async {
    await repo.seed([_dish()]);
    await repo.setStatus('d1', DishStatus.cooked);
    expect((await repo.loadDishes()).single.status, DishStatus.cooked);
  });

  test('deleting writes a tombstone that loadDishes hides', () async {
    await repo.seed([_dish()]);
    await repo.deleteDish('d1');

    expect(await repo.loadDishes(), isEmpty);
    // The row still exists, so a stale device cannot resurrect it.
    expect(await repo.countDishes(), 1);
  });

  test('seeding twice does not duplicate rows', () async {
    await repo.seed([_dish()]);
    await repo.seed([_dish()]);
    final dishes = await repo.loadDishes();
    expect(dishes, hasLength(1));
    expect(dishes.single.versions, hasLength(1));
  });
}
