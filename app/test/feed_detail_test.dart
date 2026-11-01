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
import 'package:food_finder/presentation/screens/wall/wall_screen.dart';
import 'package:food_finder/presentation/state/feed_providers.dart';
import 'package:food_finder/presentation/state/import_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _shortcode = 'ABC123';

String _feed() => jsonEncode({
      'items': [
        {
          'shortcode': _shortcode,
          'title': 'Paneer Tikka',
          'thumbnail_url': '',
          'creator': 'Ravi',
          'creator_handle': '@ravi',
          'platform': 'instagram',
          'steps': ['Fry the paneer', 'Add the garlic', 'Serve'],
          'tags': ['paneer', 'quick'],
          'url': 'https://instagram.com/reel/$_shortcode/',
        },
      ],
      'cursor': null,
      'has_more': false,
    });

/// Deliberately different words from the feed card, so a test can tell which
/// one the detail is showing.
final _content = jsonEncode({
  'shortcode': _shortcode,
  'recipe': {
    'title': 'Paneer Tikka (as read)',
    'servings': 2,
    'minutes': 25,
    'kcal': 0,
    'protein': 0,
    'ingredients': [
      {'name': 'paneer', 'amount': '200 g', 'grams': 200},
      {'name': 'garlic', 'amount': null, 'grams': null},
    ],
    'steps': ['Toast the spices', 'Sear the paneer', 'Finish with lime'],
    'tags': ['paneer', 'quick'],
  },
  'prose': {'summary': '', 'creator_note': ''},
  'creator': 'Ravi',
  'creator_handle': '@ravi',
  'platform': 'instagram',
  'thumbnail_url': '',
  'url': 'https://instagram.com/reel/$_shortcode/',
  'extraction_version': 3,
});

/// A dish this phone made from the same reel — with edits that must never
/// appear on the Wall's view of somebody else's extraction.
Dish _myCookbookCopy() => Dish(
      id: 'd1',
      title: 'MY EDITED PANEER',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.signature,
      minutes: 99,
      steps: const ['MY OWN STEP'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 1,
          changes: const ['MY PRIVATE CHANGE'],
          ingredients: const ['MY SECRET INGREDIENT'],
          createdAt: DateTime(2026, 1, 1),
          originKind: 'import',
          originShortcode: _shortcode,
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

  Widget wall(http.Client client) => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          feedServiceProvider.overrideWithValue(FeedService(
            api: ApiClient(
              baseUrl: 'https://api.test',
              tokenProvider: () => 'jwt',
              httpClient: client,
            ),
          )),
          importServiceProvider.overrideWithValue(ImportService(
            api: ApiClient(
              baseUrl: 'https://api.test',
              tokenProvider: () => 'jwt',
              httpClient: client,
            ),
            repository: JournalRepository(db),
          )),
        ],
        child: MaterialApp(
          theme: ShokuTheme.light(),
          home: const Scaffold(body: WallScreen()),
        ),
      );

  http.Client server() => MockClient((request) async {
        calls.add('${request.method} ${request.url.path}');
        if (request.url.path == '/v1/feed') {
          return http.Response(_feed(), 200);
        }
        return http.Response(_content, 200);
      });

  testWidgets('tapping a card opens the extraction, not the card copy',
      (tester) async {
    await tester.pumpWidget(wall(server()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Paneer Tikka'));
    await tester.pumpAndSettle();

    // The detail carries the extracted method, which the card never had.
    expect(find.text('Toast the spices'), findsOneWidget);
    expect(find.text('Sear the paneer'), findsOneWidget);
    expect(find.text('Finish with lime'), findsOneWidget);
    expect(find.text('Paneer Tikka (as read)'), findsOneWidget);
    expect(find.text('25 min · 2 ingredients · 3 steps'), findsOneWidget);
    expect(calls, contains('GET /v1/content/$_shortcode'));
  });

  testWidgets('adding from the detail still never queues an import',
      (tester) async {
    await tester.pumpWidget(wall(server()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Paneer Tikka'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('feed-detail-add')));
    await tester.pumpAndSettle();

    expect(calls.any((c) => c == 'POST /v1/imports'), isFalse);
    expect((await JournalRepository(db).loadDishes()).single.title,
        'Paneer Tikka (as read)');
    // And the sheet now knows there is nothing left to add.
    expect(find.byKey(const ValueKey('feed-detail-imported')), findsOneWidget);
  });

  testWidgets('a reel already in the cookbook says so, on card and detail',
      (tester) async {
    await JournalRepository(db).seed([_myCookbookCopy()]);
    await tester.pumpWidget(wall(server()));
    await tester.pumpAndSettle();

    expect(find.text('In your cookbook'), findsOneWidget,
        reason: 'the card stops offering a second copy');

    await tester.tap(find.text('Paneer Tikka'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('feed-detail-imported')), findsOneWidget);
    expect(find.byKey(const ValueKey('feed-detail-add')), findsNothing);
  });

  testWidgets('nothing of mine leaks into somebody else\'s reel',
      (tester) async {
    await JournalRepository(db).seed([_myCookbookCopy()]);
    await tester.pumpWidget(wall(server()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Paneer Tikka'));
    await tester.pumpAndSettle();

    for (final mine in [
      'MY EDITED PANEER',
      'MY OWN STEP',
      'MY PRIVATE CHANGE',
      'MY SECRET INGREDIENT',
    ]) {
      expect(find.text(mine), findsNothing,
          reason: 'the Wall shows the extraction, never a dish or version');
    }
    // The extraction is what is on screen.
    expect(find.text('Toast the spices'), findsOneWidget);
  });

  testWidgets('a detail that fails to load is a quiet retry', (tester) async {
    final client = MockClient((request) async {
      if (request.url.path == '/v1/feed') return http.Response(_feed(), 200);
      return http.Response('{"error":"boom"}', 500);
    });

    await tester.pumpWidget(wall(client));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Paneer Tikka'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('feed-detail-failed')), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(Dialog), findsNothing);
  });
}
