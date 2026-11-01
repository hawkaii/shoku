import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';

Dish _dish() => Dish(
      id: 'd1',
      title: 'Paneer',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.cooked,
      minutes: 20,
      steps: const ['Fry the paneer'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 1,
          changes: const ['First'],
          ingredients: const ['200 g paneer'],
          createdAt: DateTime(2026, 1, 1),
          steps: const ['Fry the paneer'],
          stepIngredients: const [
            [0],
          ],
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
    await repo.seed([_dish()]);
  });
  tearDown(() async => db.close());

  test('an applied edit is one version, parented on the base', () async {
    final before = (await repo.loadDishes()).single;

    final number = await repo.applyEditVersion(
      dishId: 'd1',
      baseVersionId: 'v1',
      ingredients: const ['200 g paneer', '2 potatoes'],
      steps: const ['Fry the paneer', 'Boil the potatoes'],
      stepIngredients: const [
        [0],
        [1],
      ],
      changes: const ['Added 2 potatoes'],
    );

    expect(number, 2);
    final after = (await repo.loadDishes()).single;
    expect(after.versions, hasLength(before.versions.length + 1));

    final head = after.versions.last;
    expect(head.number, 2);
    expect(head.parentVersionId, 'v1');
    expect(head.changes, ['Added 2 potatoes']);
    expect(head.steps.last, 'Boil the potatoes');
    expect(head.stepIngredients, [
      [0],
      [1],
    ]);
    expect(head.tags, contains('chat'),
        reason: 'the dossier and history both say where this came from');

    // The dish's own steps follow its head, because cook mode reads them.
    expect(after.steps.last, 'Boil the potatoes');

    // No cook row: an ask never measures food.
    expect(after.cooks, isEmpty);

    // And it is dirty, so it rides the normal sync wire.
    final rows = await db.select(db.versionRows).get();
    expect(rows.firstWhere((r) => r.id == head.id).dirty, 1);
  });

  test('a moved head refuses the edit and writes nothing', () async {
    final before = (await repo.loadDishes()).single;

    final number = await repo.applyEditVersion(
      dishId: 'd1',
      baseVersionId: 'some-older-version',
      ingredients: const ['200 g paneer', '2 potatoes'],
      steps: const ['Fry the paneer', 'Boil the potatoes'],
      stepIngredients: const [
        [0],
        [1],
      ],
      changes: const ['Added 2 potatoes'],
    );

    expect(number, isNull, reason: 'never write arrays computed on a stale base');
    final after = (await repo.loadDishes()).single;
    expect(after.versions, hasLength(before.versions.length));
    expect(after.cooks, isEmpty);
  });
}
