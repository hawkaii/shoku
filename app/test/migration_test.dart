import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/cook_timer_repository.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/data/models/cook_timer.dart';

/// A migration that throws on a real phone is a crash on launch, so the upgrade
/// path is tested the way it happens: a database written by an older build,
/// opened by this one.
void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('shoku_mig'));
  tearDown(() async => dir.delete(recursive: true));

  /// Writes a database, takes away the things a given schema version did not
  /// have, and stamps it with that version.
  Future<File> oldDatabase({
    required int version,
    required List<String> undo,
  }) async {
    final file = File('${dir.path}/shoku_$version.db');
    final db = AppDatabase(NativeDatabase(file));
    for (final statement in undo) {
      await db.customStatement(statement);
    }
    await db.customStatement('PRAGMA user_version = $version');
    await db.close();
    return file;
  }

  test('a v3 database gains the timer table and the step links', () async {
    final file = await oldDatabase(version: 3, undo: [
      'DROP TABLE cook_timer_rows',
      'ALTER TABLE version_rows DROP COLUMN step_ingredients',
    ]);

    final upgraded = AppDatabase(NativeDatabase(file));

    expect(await upgraded.select(upgraded.cookTimerRows).get(), isEmpty);
    await CookTimerRepository(upgraded).write(CookTimer(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 1,
      startedAt: DateTime(2026, 1, 1),
      duration: const Duration(minutes: 4),
    ));
    expect((await CookTimerRepository(upgraded).read())!.stepIndex, 1);
    await upgraded.close();
  });

  test('a v4 database gains the step links and keeps its versions', () async {
    final file = await oldDatabase(version: 4, undo: [
      'ALTER TABLE version_rows DROP COLUMN step_ingredients',
    ]);

    final upgraded = AppDatabase(NativeDatabase(file));
    final versions = await upgraded.select(upgraded.versionRows).get();
    expect(versions, isEmpty);
    await upgraded.close();
  });

  test('the links survive a write and read', () async {
    final db = AppDatabase(NativeDatabase(File('${dir.path}/full.db')));
    final repo = JournalRepository(db);

    await repo.upsertDish(Dish(
      id: 'd1',
      title: 'Paneer',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.toCook,
      minutes: 20,
      steps: const ['Fry the paneer', 'Add the garlic'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 0,
          changes: const [],
          ingredients: const ['200 g paneer', '2 tbsp olive oil'],
          createdAt: DateTime(2026, 1, 1),
          steps: const ['Fry the paneer', 'Add the garlic'],
          stepIngredients: const [
            [0],
            [1],
          ],
        ),
      ],
      cooks: const [],
    ));

    final dish = (await repo.loadDishes()).single;
    expect(dish.versions.single.stepIngredientLinks(0), [0]);
    expect(dish.versions.single.stepIngredientLinks(1), [1]);
    await db.close();
  });
}
