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

  // ---- regressions found in review ------------------------------------

  test('seeding the real demo data twice is a no-op', () async {
    await repo.seed(JournalData.dishes);
    await repo.seed(JournalData.dishes);

    final dishes = await repo.loadDishes();
    final mousse = dishes.firstWhere((d) => d.id == 'mousse');
    // Demo versions arrive without ids; if the seed mints a new UUID each time,
    // this is 6 instead of 3.
    expect(mousse.versions, hasLength(3));
  });

  test('seed rows are local, not pending upload', () async {
    await repo.seed(JournalData.dishes);
    final dirty = await db.customSelect(
      'SELECT COUNT(*) AS n FROM dish_rows WHERE dirty = 1',
    ).getSingle();
    expect(dirty.data['n'], 0,
        reason: 'the demo kitchen must never sync as the user journal');
  });

  test('an imported version round-trips with its provenance', () async {
    await repo.seed([_dish()]);
    final imported = _dish().copyWith(versions: [
      RecipeVersion(
        id: 'import-1',
        number: 0,
        changes: const [],
        ingredients: const ['250 g paneer'],
        createdAt: DateTime(2026, 2, 1),
        originKind: 'import',
        originCreator: '@ravi',
        originUrl: 'https://instagram.com/reel/abc',
        originShortcode: 'abc',
      ),
    ]);
    await repo.upsertDish(imported);

    final dish = (await repo.loadDishes()).single;
    final version = dish.versions.firstWhere((v) => v.id == 'import-1');
    expect(version.number, 0);
    expect(version.isImport, isTrue);
    expect(version.originCreator, '@ravi');
    expect(version.originShortcode, 'abc');
  });

  test('an update re-dirties the dish but never rewrites a version', () async {
    await repo.seed([_dish()]);
    await db.customUpdate('UPDATE dish_rows SET dirty = 0');

    await repo.upsertDish(_dish().copyWith(title: 'Paneer 2'));

    final row = await db.customSelect('SELECT * FROM dish_rows').getSingle();
    expect(row.data['title'], 'Paneer 2');
    expect(row.data['dirty'], 1);
    final versions = await db.customSelect(
      'SELECT COUNT(*) AS n FROM version_rows',
    ).getSingle();
    expect(versions.data['n'], 1);
  });

  test('two concurrent commits get distinct version numbers', () async {
    await repo.seed([_dish()]);

    await Future.wait([
      repo.commitCook(
        dishId: 'd1',
        mood: CookMood.quick,
        rating: 4,
        note: 'a',
        changes: const [],
      ),
      repo.commitCook(
        dishId: 'd1',
        mood: CookMood.quick,
        rating: 4,
        note: 'b',
        changes: const [],
      ),
    ]);

    final dish = (await repo.loadDishes()).single;
    final numbers = dish.versions.map((v) => v.number).toList()..sort();
    expect(numbers, [1, 2, 3], reason: 'a double tap must not claim v2 twice');
  });

  test('a cook keeps millisecond precision and points at a version', () async {
    final exact = DateTime(2026, 5, 4, 12, 0, 0, 123, 456);
    await repo.seed([
      _dish().copyWith(cooks: [
        CookLog(
          id: 'c-ms',
          cookedAt: exact,
          versionNumber: 1,
          photoUrl: 'https://example.com/p.jpg',
          outcome: CookOutcome.good,
          note: '',
          changes: const [],
        ),
      ]),
    ]);

    final cook = (await repo.loadDishes()).single.cooks.single;
    // Storing datetimes as unix seconds would flatten this to .000.
    expect(cook.cookedAt.millisecond, 123);
    expect(cook.photoState, 'synced', reason: 'a remote URL needs no upload');
  });

  test('committing records the version id and local photo state', () async {
    await repo.seed([_dish()]);
    await repo.commitCook(
      dishId: 'd1',
      mood: CookMood.comfort,
      rating: 5,
      note: '',
      changes: const [],
      photoUrl: '/data/user/0/shoku/photo.jpg',
    );

    final dish = (await repo.loadDishes()).single;
    final cook = dish.cooks.first;
    expect(cook.photoState, 'local');
    expect(cook.versionId, dish.versions.last.id);
  });

  test('a new version inherits the recipe steps when the previous one has none',
      () async {
    // A version with no steps of its own must fall back to the dish's steps,
    // not to an empty list.
    await repo.seed([
      _dish().copyWith(versions: [
        RecipeVersion(
          id: 'v1',
          number: 1,
          changes: const ['First attempt'],
          ingredients: const ['200 g paneer'],
          createdAt: DateTime(2026, 1, 1),
        ),
      ]),
    ]);
    await repo.commitCook(
      dishId: 'd1',
      mood: CookMood.quick,
      rating: 4,
      note: '',
      changes: const ['more garlic'],
    );

    final dish = (await repo.loadDishes()).single;
    expect(dish.versions.last.steps, ['Fry', 'Simmer']);
  });

  test('a tombstoned dish accepts no new cooks', () async {
    await repo.seed([_dish()]);
    await repo.deleteDish('d1');

    final version = await repo.commitCook(
      dishId: 'd1',
      mood: CookMood.quick,
      rating: 4,
      note: 'should not exist',
      changes: const [],
    );

    expect(version, isNull);
    expect(await repo.loadDish('d1'), isNull);
    final cooks = await db.customSelect(
      'SELECT COUNT(*) AS n FROM cook_log_rows',
    ).getSingle();
    expect(cooks.data['n'], 0);
  });
}
