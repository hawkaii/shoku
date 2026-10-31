import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/feed_service.dart';
import 'package:food_finder/data/services/import_service.dart';
import 'package:food_finder/presentation/screens/dish/share_row.dart';
import 'package:food_finder/presentation/screens/wall/wall_screen.dart';
import 'package:food_finder/presentation/state/feed_providers.dart';
import 'package:food_finder/presentation/state/import_providers.dart';
import 'package:food_finder/presentation/state/journal_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _item(String shortcode, String title) => {
      'shortcode': shortcode,
      'title': title,
      'thumbnail_url': '',
      'creator': 'Ravi',
      'creator_handle': '@ravi',
      'platform': 'instagram',
      'steps': ['Fry the paneer', 'Add the garlic', 'Serve'],
      'tags': ['paneer', 'quick', 'weeknight', 'extra'],
      'url': 'https://instagram.com/reel/$shortcode/',
    };

String _feed(List<Map<String, dynamic>> items,
        {String? cursor, bool hasMore = false}) =>
    jsonEncode({'items': items, 'cursor': cursor, 'has_more': hasMore});

final _content = jsonEncode({
  'shortcode': 'ABC',
  'recipe': {
    'title': 'Paneer Tikka',
    'servings': 2,
    'minutes': 20,
    'kcal': 0,
    'protein': 0,
    'ingredients': [
      {'name': 'paneer', 'amount': '200 g', 'grams': 200},
    ],
    'steps': ['Fry'],
    'tags': <String>[],
  },
  'creator': 'Ravi',
  'url': 'https://instagram.com/reel/ABC/',
});

Dish _importedDish({String shortcode = 'ABC'}) => Dish(
      id: 'd1',
      title: 'Paneer',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.toCook,
      minutes: 20,
      steps: const ['Fry'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 0,
          changes: const [],
          ingredients: const ['paneer'],
          createdAt: DateTime(2026, 1, 1),
          originKind: 'import',
          originShortcode: shortcode,
        ),
      ],
      cooks: const [],
    );

void main() {
  late AppDatabase db;
  late List<String> calls;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    calls = [];
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async => db.close());

  ApiClient api(http.Client client) => ApiClient(
        baseUrl: 'https://api.test',
        tokenProvider: () => 'jwt',
        httpClient: client,
      );

  Widget wall(http.Client client, {List<Dish> dishes = const []}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        feedServiceProvider.overrideWithValue(FeedService(api: api(client))),
        importServiceProvider.overrideWithValue(ImportService(
          api: api(client),
          repository: JournalRepository(db),
        )),
        dishesProvider.overrideWithValue(dishes),
      ],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const Scaffold(body: WallScreen()),
      ),
    );
  }

  testWidgets('a card carries the reel, the creator and the step count',
      (tester) async {
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      return http.Response(_feed([_item('ABC', 'Paneer Tikka')]), 200);
    });

    await tester.pumpWidget(wall(client));
    await tester.pumpAndSettle();

    expect(find.text('Paneer Tikka'), findsOneWidget);
    expect(find.text('Ravi · Instagram'), findsOneWidget);
    expect(find.text('3 steps'), findsOneWidget);
    // Chips are set in caps, like every label in the kit.
    expect(find.text('PANEER'), findsOneWidget);
    // Tags are capped so a card cannot become a wall of chips.
    expect(find.text('EXTRA'), findsNothing);
    expect(calls.single, 'GET /v1/feed');
  });

  testWidgets('an empty wall says nobody has shared anything yet',
      (tester) async {
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      return http.Response(_feed([]), 200);
    });

    await tester.pumpWidget(wall(client));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('wall-empty-title')), findsOneWidget);
    expect(find.text('Nothing has been shared yet'), findsOneWidget);
    expect(find.text('You have not shared anything of yours'), findsNothing);
  });

  testWidgets('an empty wall you could fill says so', (tester) async {
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      return http.Response(_feed([]), 200);
    });

    await tester.pumpWidget(wall(client, dishes: [_importedDish()]));
    await tester.pumpAndSettle();

    expect(find.text('You have not shared anything of yours'), findsOneWidget);
  });

  testWidgets('add to cookbook reads the cache and never queues an import',
      (tester) async {
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path == '/v1/feed') {
        return http.Response(_feed([_item('ABC', 'Paneer Tikka')]), 200);
      }
      return http.Response(_content, 200);
    });

    await tester.pumpWidget(wall(client));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('feed-add-to-cookbook')));
    await tester.pumpAndSettle();

    expect(calls.any((c) => c == 'POST /v1/imports'), isFalse,
        reason: 'the reel is already parsed; the queue would duplicate it');
    expect(calls.any((c) => c == 'GET /v1/content/ABC'), isTrue);
    expect((await JournalRepository(db).loadDishes()).single.title,
        'Paneer Tikka');
    expect(find.textContaining('Saved Paneer Tikka'), findsOneWidget);
  });

  testWidgets('a feed that fails is a quiet retry, not a dialog',
      (tester) async {
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      return http.Response('{"error":"boom"}', 500);
    });

    await tester.pumpWidget(wall(client));
    await tester.pumpAndSettle();

    expect(find.text('The Wall did not load'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('the next page is asked for with the cursor', (tester) async {
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}?${request.url.query}');
      final cursor = request.url.queryParameters['cursor'];
      if (cursor == null) {
        return http.Response(
          _feed([_item('A1', 'First reel')], cursor: 'c2', hasMore: true),
          200,
        );
      }
      return http.Response(_feed([_item('B1', 'Second reel')]), 200);
    });

    await tester.pumpWidget(wall(client));
    await tester.pumpAndSettle();

    expect(find.text('First reel'), findsOneWidget);
    expect(find.text('Second reel'), findsNothing);

    await tester.tap(find.text('More reels'));
    await tester.pumpAndSettle();

    expect(find.text('Second reel'), findsOneWidget);
    expect(
      calls.any((c) => c.contains('cursor=c2')),
      isTrue,
      reason: 'the cursor the server sent is the cursor we ask with',
    );
  });

  testWidgets('publishing calls PUT and flips the row; removing calls DELETE',
      (tester) async {
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path == '/v1/feed') {
        return http.Response(_feed([]), 200);
      }
      return http.Response(
        jsonEncode({'shortcode': 'ABC', 'shared': request.method == 'PUT'}),
        request.method == 'DELETE' ? 200 : 200,
      );
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [
        feedServiceProvider.overrideWithValue(FeedService(api: api(client))),
      ],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const Scaffold(body: ShareOnWallRow(shortcode: 'ABC')),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Share this reel on the Wall'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('share-wall')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Visible to every Shoku user'), findsOneWidget,
        reason: 'the consequence is named before it happens');
    await tester.tap(find.text('Share it'));
    await tester.pumpAndSettle();

    expect(calls, contains('PUT /v1/content/ABC/share'));
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('share-wall-label'))).data,
      'On the Wall',
    );

    await tester.tap(find.byKey(const ValueKey('unshare-wall')));
    await tester.pumpAndSettle();

    expect(calls, contains('DELETE /v1/content/ABC/share'));
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('share-wall-label'))).data,
      'Share this reel on the Wall',
    );
  });
}
