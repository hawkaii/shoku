import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/sync/sync_repository.dart';
import 'package:food_finder/data/sync/sync_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// These tests run the real database and the real merge rules; only HTTP is
/// faked. That is the combination where sync bugs actually live.
Dish _dish({String id = 'd1', int versions = 1}) => Dish(
      id: id,
      title: 'Paneer',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.cooked,
      minutes: 30,
      steps: const ['Fry'],
      versions: [
        for (var i = 1; i <= versions; i++)
          RecipeVersion(
            id: 'v$i',
            number: i,
            changes: const ['First'],
            ingredients: const ['200 g paneer'],
            createdAt: DateTime(2026, 1, 1),
          ),
      ],
      cooks: const [],
    );

void main() {
  late AppDatabase db;
  late JournalRepository local;
  late SyncRepository sync;
  late List<Map<String, dynamic>> pushedBodies;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    local = JournalRepository(db);
    sync = SyncRepository(db, local);
    pushedBodies = [];
  });

  tearDown(() async => db.close());

  ApiClient client({
    Map<String, dynamic> pull = const {},
    bool unauthorized = false,
  }) {
    return ApiClient(
      baseUrl: 'https://api.test',
      tokenProvider: () => 'jwt',
      httpClient: MockClient((request) async {
        if (unauthorized) return http.Response('{}', 401);
        if (request.url.path.endsWith('/push')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          pushedBodies.add(body);
          // Accept everything, the way the server does on a clean push.
          return http.Response(
            jsonEncode({
              for (final table in ['dishes', 'versions', 'cook_logs'])
                table: [
                  for (final row in (body[table] as List))
                    {'id': (row as Map)['id'], 'result': 'accepted'},
                ],
            }),
            200,
          );
        }
        return http.Response(jsonEncode(pull), 200);
      }),
    );
  }

  test('pushes dirty rows and marks them clean when accepted', () async {
    await local.seed([_dish()]);
    // Seeded rows are local demo data (dirty = 0); make one dirty the way a
    // real edit would.
    await local.setStatus('d1', DishStatus.signature);

    final outcome = await SyncService(repository: sync, api: client()).sync();

    expect(outcome.pushed, 1);
    expect(pushedBodies.single['dishes'].single['title'], 'Paneer');
    expect(await sync.dirtyCount(), 0, reason: 'accepted rows must stop being dirty');
  });

  test('a pushed version carries its provenance', () async {
    await local.seed([_dish()]);
    await local.commitCook(
      dishId: 'd1',
      mood: CookMood.comfort,
      rating: 5,
      note: 'good',
      changes: const ['more garlic'],
    );

    await SyncService(repository: sync, api: client()).sync();

    final body = pushedBodies.single;
    final version = (body['versions'] as List).last as Map;
    expect(version['origin_kind'], 'mine');
    expect(version['number'], 2);
    final cook = (body['cook_logs'] as List).single as Map;
    expect(cook['note'], 'good');
    expect(cook['version_id'], isNotEmpty);
  });

  test('pull inserts rows this device has never seen', () async {
    await SyncService(
      repository: sync,
      api: client(pull: {
        'dishes': [
          {
            'id': 'remote-1',
            'title': 'Ravi paneer',
            'subtitle': '',
            'cover_url': '',
            'source_handle': '@ravi',
            'status': 'toCook',
            'minutes': 25,
            'baseline_kcal': 0,
            'baseline_protein': 0,
            'steps': ['Simmer'],
            'created_at': '2026-02-01T10:00:00Z',
            'updated_at': '2026-02-01T10:00:00Z',
            'deleted_at': null,
          },
        ],
        'versions': [],
        'cook_logs': [],
        'cursor': 'c1',
      }),
    ).sync();

    final dishes = await local.loadDishes();
    expect(dishes.map((d) => d.title), contains('Ravi paneer'));
    expect(await sync.readCursor(), 'c1');
  });

  test('a local edit is not clobbered by an older server copy', () async {
    await local.seed([_dish()]);
    await local.setStatus('d1', DishStatus.signature); // dirty

    await SyncService(
      repository: sync,
      api: client(pull: {
        'dishes': [
          {
            'id': 'd1',
            'title': 'Stale title',
            'subtitle': '',
            'cover_url': '',
            'source_handle': '',
            'status': 'toCook',
            'minutes': 30,
            'baseline_kcal': 0,
            'baseline_protein': 0,
            'steps': <String>[],
            'created_at': '2026-01-01T10:00:00Z',
            'updated_at': '2026-01-01T10:00:00Z',
            'deleted_at': null,
          },
        ],
        'versions': [],
        'cook_logs': [],
        'cursor': null,
      }),
    ).sync();

    final dish = (await local.loadDishes()).single;
    expect(dish.title, 'Paneer', reason: 'the local, unsynced row wins');
  });

  test('a tombstone from the server hides the dish locally', () async {
    await SyncService(
      repository: sync,
      api: client(pull: {
        'dishes': [
          {
            'id': 'gone-1',
            'title': 'Deleted elsewhere',
            'subtitle': '',
            'cover_url': '',
            'source_handle': '',
            'status': 'cooked',
            'minutes': 10,
            'baseline_kcal': 0,
            'baseline_protein': 0,
            'steps': <String>[],
            'created_at': '2026-01-01T10:00:00Z',
            'updated_at': '2026-03-01T10:00:00Z',
            'deleted_at': '2026-03-01T10:00:00Z',
          },
        ],
        'versions': [],
        'cook_logs': [],
        'cursor': 'c2',
      }),
    ).sync();

    expect(await local.loadDishes(), isEmpty);
  });

  test('an unauthenticated push surfaces as ApiUnauthenticated', () async {
    await local.seed([_dish()]);
    await local.setStatus('d1', DishStatus.signature);

    await expectLater(
      SyncService(repository: sync, api: client(unauthorized: true)).sync(),
      throwsA(isA<ApiUnauthenticated>()),
    );
  });

  test('step links are local: never pushed, and a pulled version has none',
      () async {
    await local.seed([
      _dish(),
    ]);
    await local.commitCook(
      dishId: 'd1',
      mood: CookMood.comfort,
      rating: 5,
      note: 'good',
      changes: const ['more garlic'],
    );

    await SyncService(repository: sync, api: client()).sync();

    final versions = pushedBodies.single['versions'] as List;
    expect(versions, isNotEmpty);
    for (final version in versions) {
      expect((version as Map).containsKey('step_ingredients'), isFalse,
          reason: 'the links are not part of the wire');
    }

    await SyncService(
      repository: sync,
      api: client(pull: {
        'dishes': [
          {
            'id': 'remote-9',
            'title': 'From another phone',
            'subtitle': '',
            'cover_url': '',
            'source_handle': '',
            'status': 'toCook',
            'minutes': 20,
            'baseline_kcal': 0,
            'baseline_protein': 0,
            'steps': ['Fry'],
            'created_at': '2026-02-01T10:00:00Z',
            'updated_at': '2026-02-01T10:00:00Z',
            'deleted_at': null,
          },
        ],
        'versions': [
          {
            'id': 'rv1',
            'dish_id': 'remote-9',
            'number': 0,
            'changes': <String>[],
            'ingredients': ['salt'],
            'steps': ['Fry'],
            'kcal': 0,
            'protein': 0,
            'origin_kind': 'import',
            'created_at': '2026-02-01T10:00:00Z',
          },
        ],
        'cook_logs': <Map<String, dynamic>>[],
        'cursor': 'c9',
      }),
    ).sync();

    final dish = (await local.loadDishes())
        .firstWhere((d) => d.id == 'remote-9');
    expect(dish.versions.single.stepIngredients, isNull);
  });
}
