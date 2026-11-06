import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/sync/sync_repository.dart';

/// A reinstalled app has an empty database and no cursor. One pull is all it
/// gets before the cookbook draws its first frame, so this replay is the real
/// test of "delete the app, sign in, your recipes come back".
///
/// The payload is a production account's own `/v1/sync/pull` response, dumped
/// whole: eleven dishes (two of them tombstones), fourteen versions, two cooks
/// and four pantry rows.
void main() {
  late AppDatabase db;
  late JournalRepository journal;
  late SyncRepository sync;
  late Map<String, dynamic> payload;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    journal = JournalRepository(db);
    sync = SyncRepository(db, journal);
    payload = jsonDecode(
      File('test/fixtures/pull_from_production.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    await sync.applyPull(payload);
  });

  tearDown(() async => db.close());

  test('the live dishes come back, and the tombstones stay buried', () async {
    final dishes = await journal.loadDishes();

    expect(dishes, hasLength(9), reason: 'eleven rows, two of them deleted');
    expect(dishes.map((d) => d.title), isNot(contains('Masala Chicken Pulao')));

    final newest = dishes.firstWhere(
      (d) => d.title == 'Chinese Tomato Eggs',
      orElse: () => throw StateError('the newest dish did not come back'),
    );
    expect(newest.versions, isNotEmpty,
        reason: 'a dish without a version cannot be cooked');
    expect(newest.versions.first.steps, isNotEmpty);
    expect(newest.versions.first.ingredients, isNotEmpty);
  });

  test('restored rows are clean, so the next pass pushes nothing', () async {
    final dirty = await sync.dirtyPayload();
    for (final entry in dirty.entries) {
      expect(entry.value, isEmpty,
          reason: '${entry.key} was applied but left dirty');
    }
  });

  test('applying the same pull twice does not duplicate anything', () async {
    await sync.applyPull(payload);
    expect(await journal.loadDishes(), hasLength(9));
    final versions = await db.select(db.versionRows).get();
    expect(versions, hasLength(14));
  });
}
