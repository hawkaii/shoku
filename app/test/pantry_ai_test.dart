import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/pantry_repository.dart';
import 'package:food_finder/data/models/pantry_item.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/pantry_ai_service.dart';
import 'package:food_finder/presentation/screens/pantry/pantry_add_screen.dart';
import 'package:food_finder/presentation/screens/pantry/pantry_screen.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:food_finder/presentation/state/pantry_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A server that answers `/v1/pantry/parse` and remembers what it was asked.
class _FakeAi {
  _FakeAi(this.respond);

  final http.Response Function(http.Request request) respond;
  final requests = <http.Request>[];

  ApiClient get client => ApiClient(
        baseUrl: 'https://api.test',
        tokenProvider: () => 'jwt',
        httpClient: MockClient((request) async {
          requests.add(request);
          return respond(request);
        }),
      );

  List<String> get sentLines {
    final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
    return [for (final line in body['lines'] as List) line.toString()];
  }
}

http.Response _ok(List<Map<String, Object?>> items, {int remaining = 9}) =>
    http.Response(
      jsonEncode({
        'items': items,
        'remaining': remaining,
        'reset_at': '2026-11-03T00:00:00Z',
      }),
      200,
      headers: {'content-type': 'application/json'},
    );

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Widget page(List<Override> overrides) => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db), ...overrides],
        child: MaterialApp.router(
          theme: ShokuTheme.light(),
          routerConfig: GoRouter(
            initialLocation: '/pantry',
            routes: [
              GoRoute(
                path: '/pantry',
                builder: (_, __) => const Scaffold(body: PantryScreen()),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (_, __) => const Scaffold(body: PantryAddScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Future<void> review(WidgetTester tester, String text) async {
    await tester.tap(find.byKey(const ValueKey('pantry-add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('pantry-text')), text);
    await tester.tap(find.byKey(const ValueKey('pantry-parse')));
    await tester.pumpAndSettle();
  }

  testWidgets('one call carries every leftover line, and only those',
      (tester) async {
    final ai = _FakeAi((_) => _ok([
          {
            'line': 'HALDIRAM BHUJIA 200G',
            'name': 'bhujia',
            'quantity': 200,
            'unit': 'g',
          },
          {'line': 'asdfgh', 'name': 'asdfgh', 'quantity': null, 'unit': null},
        ]));

    await PantryRepository(db)
        .add(name: 'rice', quantity: 2, unit: PantryUnit.kg);
    await tester.pumpWidget(
      page([
        pantryAiServiceProvider
            .overrideWithValue(PantryAiService(api: ai.client))
      ]),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await review(
        tester, '2 kg rice\nHALDIRAM BHUJIA 200G\nTATA SALT 1KG\nasdfgh');

    expect(ai.requests, hasLength(1),
        reason: 'a receipt is one request, never one per line');
    expect(ai.sentLines, [
      'HALDIRAM BHUJIA 200G',
      'TATA SALT 1KG',
      'asdfgh',
    ]);
  });

  testWidgets('nothing is sent when the device read the whole receipt',
      (tester) async {
    final ai = _FakeAi((_) => _ok(const []));
    final repo = PantryRepository(db);
    await repo.add(name: 'rice', quantity: 2, unit: PantryUnit.kg);
    await repo.add(name: 'lemons', quantity: 3, unit: PantryUnit.pcs);
    await tester.pumpWidget(
      page([
        pantryAiServiceProvider
            .overrideWithValue(PantryAiService(api: ai.client))
      ]),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await review(tester, '2 kg rice\n3 lemons');

    expect(ai.requests, isEmpty);
    expect(find.text('Add 2 of 2'), findsOneWidget);
  });

  testWidgets('a returned line is merged, checked, and says it is from AI',
      (tester) async {
    final ai = _FakeAi((_) => _ok([
          {
            'line': 'HALDIRAM BHUJIA 200G',
            'name': 'bhujia',
            'quantity': 200,
            'unit': 'g',
          },
        ]));
    await tester.pumpWidget(
      page([
        pantryAiServiceProvider
            .overrideWithValue(PantryAiService(api: ai.client))
      ]),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await review(tester, 'HALDIRAM BHUJIA 200G\n500');

    expect(find.text('bhujia'), findsOneWidget);
    expect(find.text('200 g'), findsOneWidget);
    expect(find.byKey(const ValueKey('pantry-ai-chip-0')), findsOneWidget);
    expect(find.textContaining('Couldn’t read (1)'), findsOneWidget,
        reason: 'the line the model omitted stays unreadable');
    expect(find.text('Add 1 of 2'), findsOneWidget,
        reason: 'a returned line arrives checked');

    await tester.tap(find.byKey(const ValueKey('pantry-confirm')));
    await tester.pumpAndSettle();

    final item = (await PantryRepository(db).load()).single;
    expect(item.name, 'bhujia');
    expect(item.quantity, 200);
    expect(item.unit, PantryUnit.g);
    expect(item.aliases, contains('HALDIRAM BHUJIA 200G'));
  });

  testWidgets('the daily cap leaves the lines and says why', (tester) async {
    await PantryRepository(db)
        .add(name: 'rice', quantity: 2, unit: PantryUnit.kg);
    final ai = _FakeAi((_) => http.Response(
          jsonEncode({
            'error': 'daily_cap_reached',
            'reset_at': '2026-11-03T00:00:00Z',
          }),
          429,
          headers: {'content-type': 'application/json'},
        ));
    await tester.pumpWidget(
      page([
        pantryAiServiceProvider
            .overrideWithValue(PantryAiService(api: ai.client))
      ]),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await review(tester, '2 kg rice\n500');

    expect(ai.requests, hasLength(1), reason: 'a cap is never retried');
    expect(find.text('AI reads used up for today — type them instead'),
        findsOneWidget);
    expect(find.textContaining('Couldn’t read (1)'), findsOneWidget);
    expect(find.text('Add 1 of 2'), findsOneWidget);
  });

  testWidgets('a failed call never blocks the rows that did parse',
      (tester) async {
    final ai = _FakeAi((_) => http.Response('{"error":"unavailable"}', 503));
    await PantryRepository(db)
        .add(name: 'rice', quantity: 2, unit: PantryUnit.kg);
    await tester.pumpWidget(
      page([
        pantryAiServiceProvider
            .overrideWithValue(PantryAiService(api: ai.client))
      ]),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await review(tester, '2 kg rice\n500');

    expect(find.byKey(const ValueKey('pantry-ai-cap')), findsNothing,
        reason: 'offline or a bad day is silent');
    await tester.tap(find.byKey(const ValueKey('pantry-confirm')));
    await tester.pumpAndSettle();

    final item = (await PantryRepository(db).load()).single;
    expect(item.name, 'rice');
    expect(item.quantity, 2);
  });

  group('the service', () {
    test('only whitelisted units survive, and none without an amount',
        () async {
      final ai = _FakeAi((_) => _ok([
            {'line': 'a', 'name': 'ghee', 'quantity': 100, 'unit': 'cups'},
            {'line': 'b', 'name': 'chips', 'quantity': null, 'unit': 'pcs'},
            {'line': 'c', 'name': 'rice', 'quantity': 1, 'unit': 'kg'},
          ]));
      final service =
          PantryAiService(api: ai.client, newRequestId: () => 'req-1234');

      final result = await service.read(['a', 'b', 'c']);

      expect(result.items[0].unit, isNull,
          reason: 'cups is not a unit we keep');
      expect(result.items[1].unit, isNull, reason: 'a unit with no amount');
      expect(result.items[2].unit, PantryUnit.kg);
      expect(result.remaining, 9);
      expect(
        (jsonDecode(ai.requests.single.body) as Map)['request_id'],
        'req-1234',
      );
    });

    test('a 429 is a state with a date, not a failure', () async {
      final ai =
          _FakeAi((_) => http.Response('{"error":"daily_cap_reached"}', 429));
      final service = PantryAiService(api: ai.client);
      await expectLater(
        service.read(['asdfgh']),
        throwsA(isA<PantryCapReached>()),
      );
    });
  });
}
