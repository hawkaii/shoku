import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/import_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _shortcode = 'DZzRs0Jx_v1';

final _content = jsonEncode({
  'shortcode': _shortcode,
  'recipe': {
    'title': 'Paneer Tikka',
    'servings': 2,
    'minutes': 20,
    'kcal': 0,
    'protein': 0,
    'ingredients': [
      {'name': 'paneer', 'amount': '200 g', 'grams': 200},
    ],
    'steps': ['Fry the paneer'],
    'tags': <String>[],
  },
  'creator': 'Ravi',
  'creator_handle': '@ravi',
  'platform': 'instagram',
  'thumbnail_url': 'https://example.test/reel.jpg',
  'url': 'https://www.instagram.com/reel/$_shortcode/',
});

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  ImportService service(http.Client client) => ImportService(
        api: ApiClient(
          baseUrl: 'https://api.test',
          tokenProvider: () => 'jwt',
          httpClient: client,
        ),
        repository: JournalRepository(db),
      );

  test('two pollers finishing one reel write one dish', () async {
    // The tracker's poller and the sheet's poller both settle the same job, so
    // both call createDish within the same second. A slow read is what lets the
    // two calls overlap: without single-flight both pass the duplicate scan.
    var contentFetches = 0;
    final importer = service(MockClient((request) async {
      contentFetches++;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return http.Response(_content, 200);
    }));

    final both = await Future.wait([
      importer.createDish(_shortcode),
      importer.createDish(_shortcode),
    ]);

    expect(contentFetches, 1, reason: 'one reel, one read of its content');
    expect(both.first, isNotNull);
    expect(both.last!.id, both.first!.id,
        reason: 'both callers get the same dish, not two');

    final dishes = await JournalRepository(db).loadDishes();
    expect(dishes, hasLength(1));
    expect(dishes.single.title, 'Paneer Tikka');
  });

  test('a call that fails leaves nothing behind, so a retry can run', () async {
    var attempts = 0;
    final importer = service(MockClient((request) async {
      attempts++;
      if (attempts == 1) {
        // Three polls of the same shortcode must not replay this forever.
        return http.Response(jsonEncode({'error': 'worker_unavailable'}), 503);
      }
      return http.Response(_content, 200);
    }));

    await expectLater(
      importer.createDish(_shortcode),
      throwsA(isA<ApiError>()),
    );

    final dish = await importer.createDish(_shortcode);

    expect(dish, isNotNull, reason: 'the entry was cleared in finally');
    expect(attempts, 2, reason: 'the retry is a real attempt, not a replay');

    final dishes = await JournalRepository(db).loadDishes();
    expect(dishes, hasLength(1));
  });

  test('a dish that already exists is returned without a second insert',
      () async {
    var contentFetches = 0;
    final importer = service(MockClient((request) async {
      contentFetches++;
      return http.Response(_content, 200);
    }));

    final first = await importer.createDish(_shortcode);
    final second = await importer.createDish(_shortcode);

    expect(second!.id, first!.id);
    expect(contentFetches, 1, reason: 'the duplicate scan still wins');
    expect(await JournalRepository(db).loadDishes(), hasLength(1));
  });
}
