import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/cook_timer_repository.dart';
import 'package:food_finder/data/models/cook_timer.dart';

/// A migration that throws on a real phone is a crash on launch, so the upgrade
/// path is tested the way it happens: a database written by the previous build,
/// opened by this one.
void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('shoku_mig'));
  tearDown(() async => dir.delete(recursive: true));

  test('a v3 database gains the timer table instead of failing to open',
      () async {
    final file = File('${dir.path}/shoku.db');

    // A database from the previous release: everything except the timer.
    final old = AppDatabase(NativeDatabase(file));
    await old.customStatement('DROP TABLE cook_timer_rows');
    await old.customStatement('PRAGMA user_version = 3');
    await old.close();

    final upgraded = AppDatabase(NativeDatabase(file));

    // Opening runs the migration; the timer table is empty and usable.
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
}
