import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/db/pantry_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/sync/sync_repository.dart';
import 'package:food_finder/data/sync/sync_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// These tests run the real database and the real merge rules; only HTTP is
/// faked. That is the combination where sync bugs actually live.
Dish _dish(
        {String id = 'd1', int versions = 1, List<String> tags = const []}) =>
    Dish(
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
            tags: tags,
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
          // Accept every table, the way the server does on a clean push.
          return http.Response(
            jsonEncode({
              for (final table in const [
                'dishes',
                'versions',
                'cook_logs',
                'photos',
                'pantry_items',
              ])
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

  /// A pull that answers one queued page at a time, recording the cursor each
  /// request carried. The last page is repeated if the client asks again, which
  /// is how "the server never stops paging" is spelled here.
  ApiClient paged({
    required List<Map<String, dynamic>> pages,
    required List<String?> askedCursors,
  }) {
    var index = 0;
    return ApiClient(
      baseUrl: 'https://api.test',
      tokenProvider: () => 'jwt',
      httpClient: MockClient((request) async {
        askedCursors.add(
          (jsonDecode(request.body) as Map<String, dynamic>)['cursor']
              as String?,
        );
        final page = pages[index < pages.length ? index : pages.length - 1];
        index++;
        return http.Response(jsonEncode(page), 200);
      }),
    );
  }

  Map<String, dynamic> remoteDish(String id, String title) => {
        'id': id,
        'title': title,
        'subtitle': '',
        'cover_url': '',
        'source_handle': '',
        'status': 'toCook',
        'minutes': 20,
        'baseline_kcal': 0,
        'baseline_protein': 0,
        'steps': const ['Fry'],
        'created_at': '2026-02-01T10:00:00Z',
        'updated_at': '2026-02-01T10:00:00Z',
        'deleted_at': null,
      };

  test('pushes dirty rows and marks them clean when accepted', () async {
    await local.seed([_dish()]);
    // Seeded rows are local demo data (dirty = 0); make one dirty the way a
    // real edit would.
    await local.setStatus('d1', DishStatus.signature);

    final outcome = await SyncService(repository: sync, api: client()).sync();

    expect(outcome.pushed, 1);
    expect(
        ((pushedBodies.single['dishes'] as List).single
            as Map<String, dynamic>)['title'],
        'Paneer');
    expect(await sync.dirtyCount(), 0,
        reason: 'accepted rows must stop being dirty');
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

  test('a status change and a tombstone both reach the wire', () async {
    await local.seed([_dish()]);
    await local.setStatus('d1', DishStatus.signature);
    await local.deleteDish('d1');

    await SyncService(repository: sync, api: client()).sync();

    final row = (pushedBodies.single['dishes'] as List).single as Map;
    expect(row['status'], 'signature');
    expect(row['deleted_at'], isNotNull,
        reason: 'a delete is a tombstone the server has to hear about');
  });

  test('tags are pushed with the version that carries them', () async {
    await local.seed([
      _dish(tags: const ['from video'])
    ]);
    await local.commitCook(
      dishId: 'd1',
      mood: CookMood.comfort,
      rating: 4,
      note: 'guessed',
      changes: const ['more garlic'],
    );

    await SyncService(repository: sync, api: client()).sync();

    final version = (pushedBodies.single['versions'] as List).last as Map;
    expect(version['tags'], ['from video'],
        reason: 'the server cannot invent tags; it only stores what we send');
  });

  test('tags arrive on a pulled version', () async {
    await SyncService(
      repository: sync,
      api: client(pull: {
        'dishes': [
          {
            'id': 'remote-7',
            'title': 'Silent reel',
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
            'id': 'rv7',
            'dish_id': 'remote-7',
            'number': 0,
            'changes': <String>[],
            'ingredients': ['salt'],
            'steps': ['Fry'],
            'tags': ['from video', 'quick'],
            'kcal': 0,
            'protein': 0,
            'origin_kind': 'import',
            'created_at': '2026-02-01T10:00:00Z',
          },
        ],
        'cook_logs': <Map<String, dynamic>>[],
        'cursor': 'c7',
      }),
    ).sync();

    final dish =
        (await local.loadDishes()).firstWhere((d) => d.id == 'remote-7');
    expect(dish.versions.single.tags, ['from video', 'quick']);
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

    final dish =
        (await local.loadDishes()).firstWhere((d) => d.id == 'remote-9');
    expect(dish.versions.single.stepIngredients, isNull);
  });

  group('marking a push clean', () {
    /// One dirty row in every table the wire has: a dish, the version and cook
    /// a `commitCook` appends, the photo projected from that cook, and a pantry
    /// item. Anything the server accepts must stop being pushed.
    Future<void> makeEveryTableDirty() async {
      await local.seed([_dish()]);
      await local.setStatus('d1', DishStatus.signature);
      await local.commitCook(
        dishId: 'd1',
        mood: CookMood.comfort,
        rating: 5,
        note: 'good',
        changes: const ['more garlic'],
        photoKey: 'photos/debrief.jpg',
      );
      await PantryRepository(db).add(name: 'rice', quantity: 2);
    }

    test('an accepted push clears all five tables, pantry and photos included',
        () async {
      await makeEveryTableDirty();
      expect(await sync.dirtyCount(), 5,
          reason: 'one dirty row in each of dishes, versions, cook_logs, '
              'photos and pantry_items');

      await SyncService(repository: sync, api: client()).sync();

      final body = pushedBodies.single;
      expect(body['pantry_items'], hasLength(1),
          reason: 'the pantry rides in the same push');
      expect(body['photos'], hasLength(1),
          reason: 'a cook with a photo_key projects one photo row');

      expect(await sync.dirtyCount(), 0,
          reason: 'a row the server accepted must never be pushed again');
    });

    test('a second pass after a clean push sends no push at all', () async {
      await makeEveryTableDirty();
      await SyncService(repository: sync, api: client()).sync();
      expect(pushedBodies, hasLength(1));

      await SyncService(repository: sync, api: client()).sync();

      expect(pushedBodies, hasLength(1),
          reason: 'nothing is dirty, so there is nothing to post');
      expect(await sync.dirtyCount(), 0);
    });
  });

  group('following every page', () {
    test('has_more is followed until false, and the cursor lands on read rows',
        () async {
      final asked = <String?>[];
      final progress = <SyncProgress>[];
      final api = paged(
        askedCursors: asked,
        pages: [
          {
            'dishes': [remoteDish('page-1', 'Page one')],
            'versions': <Map<String, dynamic>>[],
            'cook_logs': <Map<String, dynamic>>[],
            'cursor': 'c1',
            'has_more': true,
          },
          {
            'dishes': [remoteDish('page-2', 'Page two')],
            'versions': <Map<String, dynamic>>[],
            'cook_logs': <Map<String, dynamic>>[],
            'cursor': null,
            'has_more': false,
          },
        ],
      );

      final outcome = await SyncService(repository: sync, api: api)
          .sync(onProgress: progress.add);

      expect(
        (await local.loadDishes()).map((d) => d.title),
        containsAll(['Page one', 'Page two']),
        reason: 'the page after the first one is not optional',
      );
      expect(asked, [null, 'c1'],
          reason: 'the second request resumes where the first stopped');
      expect(outcome.pages, 2);
      expect(outcome.pulled, 2);
      expect(progress.map((p) => p.pages), [1, 2],
          reason: 'progress is reported per page, not once at the end');
      expect(await sync.readCursor(), 'c1',
          reason: 'the last cursor the server minted still points at rows the '
              'client has actually read');
    });

    test(
        'a server that always says has_more fails at the cap and keeps the cursor',
        () async {
      final asked = <String?>[];
      final api = paged(
        askedCursors: asked,
        pages: [
          {
            'dishes': [remoteDish('endless', 'Endless')],
            'versions': <Map<String, dynamic>>[],
            'cook_logs': <Map<String, dynamic>>[],
            'cursor': 'c-forever',
            'has_more': true,
          },
        ],
      );

      await expectLater(
        SyncService(repository: sync, api: api, maxPages: 3).sync(),
        throwsA(isA<SyncPageLimitExceeded>()),
        reason: 'a bound that returns quietly is the silent stop again',
      );

      expect(asked, hasLength(3));
      expect(await sync.readCursor(), isNull,
          reason: 'no cursor may be written past rows nobody has read');
      expect(await local.loadDishes(), hasLength(1),
          reason: 'the rows that did arrive are kept; the merge is idempotent');
    });

    test('a page that outlives the clock fails the same way', () async {
      final asked = <String?>[];
      final api = paged(
        askedCursors: asked,
        pages: [
          {
            'dishes': [remoteDish('slow', 'Slow')],
            'versions': <Map<String, dynamic>>[],
            'cook_logs': <Map<String, dynamic>>[],
            'cursor': 'c-slow',
            'has_more': true,
          },
        ],
      );

      await expectLater(
        SyncService(repository: sync, api: api, pageTimeLimit: Duration.zero)
            .sync(),
        throwsA(isA<SyncPageLimitExceeded>()),
      );

      expect(asked, hasLength(1));
      expect(await sync.readCursor(), isNull);
    });
  });
}
