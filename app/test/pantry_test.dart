import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/db/pantry_repository.dart';
import 'dart:convert';

import 'package:food_finder/data/models/pantry_item.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/suggestions_service.dart';
import 'package:food_finder/data/sync/sync_repository.dart';
import 'package:food_finder/presentation/screens/pantry/pantry_screen.dart';
import 'package:food_finder/presentation/state/pantry_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';

void main() {
  group('units', () {
    test('weights and volumes convert inside their family', () {
      expect(
        PantryParser.deductAmount(
            have: 1, haveUnit: PantryUnit.kg, needed: 500, neededUnit: PantryUnit.g),
        0.5,
      );
      expect(
        PantryParser.deductAmount(
            have: 500, haveUnit: PantryUnit.ml, needed: 2, neededUnit: PantryUnit.tbsp),
        470,
      );
    });

    test('counts never convert to weight or volume', () {
      expect(
        PantryParser.deductAmount(
            have: 2, haveUnit: PantryUnit.bunch, needed: 200, neededUnit: PantryUnit.g),
        isNull,
      );
      expect(
        PantryParser.deductAmount(
            have: 2, haveUnit: PantryUnit.pcs, needed: 1, neededUnit: PantryUnit.pcs),
        1,
      );
    });
  });

  group('deduction defaults come from the line, never the shelf', () {
    test('500 g rice against 2 kg of stock defaults to 0.5 kg', () {
      final amount = PantryParser.statedAmountIn(
        line: '500 g rice',
        stockUnit: PantryUnit.kg,
      );
      expect(amount, 0.5);
    });

    test('a line that states nothing has no default at all', () {
      expect(
        PantryParser.statedAmountIn(line: 'rice', stockUnit: PantryUnit.kg),
        isNull,
        reason: 'naming an ingredient is not asking for the whole stock',
      );
      expect(
        PantryParser.statedAmountIn(
            line: 'rice, rinsed', stockUnit: PantryUnit.kg),
        isNull,
      );
    });

    test('a count line still counts', () {
      expect(
        PantryParser.statedAmountIn(line: '3 lemons', stockUnit: PantryUnit.pcs),
        3,
      );
      expect(
        PantryParser.statedAmountIn(line: '2 eggs', stockUnit: PantryUnit.bunch),
        isNull,
        reason: 'a bunch is not a piece',
      );
    });
  });

  group('parsing', () {
    test('a leading quantity and unit become an amount', () {
      final line = PantryParser.parseLine('2 kg rice');
      expect(line.name, 'rice');
      expect(line.quantity, 2);
      expect(line.unit, PantryUnit.kg);
      expect(line.confident, isTrue);
    });

    test('a bare count is a count, not a guess', () {
      final line = PantryParser.parseLine('3 lemons');
      expect(line.quantity, 3);
      expect(line.unit, PantryUnit.pcs);
    });

    test('an unreadable line is kept raw and marked ambiguous', () {
      final line = PantryParser.parseLine('AMUL BUTTER 500G');
      expect(line.confident, isFalse);
      expect(line.raw, 'AMUL BUTTER 500G');
    });
  });

  group('the store', () {
    late AppDatabase db;
    late PantryRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = PantryRepository(db);
    });
    tearDown(() async => db.close());

    test('add, edit and tombstone round-trip', () async {
      final added = await repo.add(
          name: 'rice', quantity: 2, unit: PantryUnit.kg, aliases: const ['2 KG RICE']);
      expect((await repo.load()).single.name, 'rice');

      await repo.save(added.copyWith(quantity: 1.5));
      expect((await repo.load()).single.quantity, 1.5);

      await repo.remove(added.id);
      expect(await repo.load(), isEmpty);
      expect((await repo.load(includeDeleted: true)).single.isDeleted, isTrue);
    });

    test('a pull is last-write-wins and a tombstone hides', () async {
      final item = await repo.add(name: 'rice', quantity: 2, unit: PantryUnit.kg);

      await repo.applyPull([
        {
          'id': item.id,
          'name': 'rice',
          'quantity': 5,
          'unit': 'kg',
          'aliases': <String>[],
          'wanted': false,
          'source': 'photo',
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2099-01-01T00:00:00Z',
          'deleted_at': null,
        },
      ]);
      expect((await repo.load()).single.quantity, 5);

      await repo.applyPull([
        {
          'id': item.id,
          'name': 'rice',
          'quantity': 5,
          'unit': 'kg',
          'aliases': <String>[],
          'wanted': false,
          'source': 'photo',
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2099-02-01T00:00:00Z',
          'deleted_at': '2099-02-01T00:00:00Z',
        },
      ]);
      expect(await repo.load(), isEmpty);
    });

    test('the push payload carries pantry_items', () async {
      final journal = JournalRepository(db);
      await repo.add(name: 'rice', quantity: 2, unit: PantryUnit.kg);
      final payload = await SyncRepository(db, journal).dirtyPayload();
      final row = (payload['pantry_items'] ?? const []).single;
      expect(row['name'], 'rice');
      expect(row['unit'], 'kg');
    });
  });

  group('suggestions', () {
    test('a fixture scores a reel and names what is missing', () async {
      final client = ApiClient(
        baseUrl: 'https://api.test',
        tokenProvider: () => 'jwt',
        httpClient: MockClient((request) async {
          expect(request.url.path, '/v1/feed/suggestions');
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'shortcode': 'ABC',
                  'title': 'Paneer Tikka',
                  'thumbnail_url': '',
                  'creator': 'Ravi',
                  'platform': 'instagram',
                  'ingredients': ['paneer', 'garlic', 'chilli', 'lime'],
                  'match': {
                    'have': 3,
                    'total': 4,
                    'missing': ['lime'],
                  },
                },
              ],
            }),
            200,
          );
        }),
      );

      final reels = await SuggestionsService(api: client).fetch();

      expect(reels.single.title, 'Paneer Tikka');
      expect(reels.single.scoreLabel, '3 of 4');
      expect(reels.single.missing, ['lime']);
      expect(reels.single.asFeedItem.shortcode, 'ABC');
    });

    test('an endpoint that is not there yet is an empty shelf', () async {
      final client = ApiClient(
        baseUrl: 'https://api.test',
        tokenProvider: () => 'jwt',
        httpClient: MockClient((_) async => http.Response('{}', 404)),
      );
      expect(await SuggestionsService(api: client).fetch(), isEmpty);
    });
  });

  group('deduction', () {
    late AppDatabase db;
    late PantryStore store;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await PantryRepository(db).add(
          name: 'rice', quantity: 2, unit: PantryUnit.kg);
    });
    tearDown(() async => db.close());

    test('comparable units deduct, incompatible ones are reported', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      store = container.read(pantryStoreProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final rice = (await PantryRepository(db).load()).single;
      final skipped = await store.deduct([
        (item: rice, amount: 500, unit: PantryUnit.g),
      ]);
      expect(skipped, 0);
      expect((await PantryRepository(db).load()).single.quantity, 1.5);

      final again = (await PantryRepository(db).load()).single;
      final skipped2 = await store.deduct([
        (item: again, amount: 1, unit: PantryUnit.pcs),
      ]);
      expect(skipped2, 1, reason: 'a piece is not a weight');
      expect((await PantryRepository(db).load()).single.quantity, 1.5);
    });
  });

  group('the page', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() async => db.close());

    Widget page() => ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            theme: ShokuTheme.light(),
            home: const Scaffold(body: PantryScreen()),
          ),
        );

    testWidgets('empty pantry says what it is and how to fill it',
        (tester) async {
      await tester.pumpWidget(page());
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const ValueKey('pantry-empty')), findsOneWidget);
      expect(find.text('Add items'), findsOneWidget);
      expect(find.text('Pantry'), findsOneWidget);
    });

    testWidgets('typed capture reviews before anything enters stock',
        (tester) async {
      await tester.pumpWidget(page());
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.byKey(const ValueKey('pantry-add')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, '2 kg rice\nAMUL BUTTER 500G');
      await tester.tap(find.byKey(const ValueKey('pantry-parse')));
      await tester.pumpAndSettle();

      // Confident line pre-checked, the unreadable one is not.
      expect(find.text('Add 1 of 2'), findsOneWidget);
      expect(find.textContaining('Couldn’t read (1)'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('pantry-confirm')));
      await tester.pumpAndSettle();

      final items = await PantryRepository(db).load();
      expect(items.single.name, 'rice');
      expect(items.single.quantity, 2);
      expect(items.single.unit, PantryUnit.kg);
    });
  });
}
