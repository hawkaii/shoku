import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/pantry_ai_service.dart';
import 'package:food_finder/data/services/receipt_image.dart';
import 'package:food_finder/presentation/screens/pantry/pantry_add_screen.dart';
import 'package:food_finder/presentation/screens/pantry/pantry_screen.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:food_finder/presentation/state/pantry_providers.dart';
import 'package:food_finder/presentation/state/sync_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _jpeg = [0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
const _png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2, 3, 4];

http.Response _ok(List<Map<String, Object?>> items) => http.Response(
      jsonEncode({
        'items': items,
        'remaining': 9,
        'reset_at': '2026-11-03T00:00:00Z',
      }),
      200,
      headers: {'content-type': 'application/json'},
    );

void main() {
  group('the image that goes up', () {
    test('is downscaled to 1600 px on the long edge at quality 80', () {
      expect(ReceiptImage.pickOptions.maxEdge, 1600);
      expect(ReceiptImage.pickOptions.quality, 80);
    });

    test('says what it actually is, from its own bytes', () {
      expect(ReceiptImage.mimeTypeOf(_jpeg), 'image/jpeg');
      expect(ReceiptImage.mimeTypeOf(_png), 'image/png',
          reason:
              'a screenshot comes back as PNG even when JPEG was asked for');
      expect(
        ReceiptImage.mimeTypeOf([
          0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, //
          0x57, 0x45, 0x42, 0x50, 0,
        ]),
        'image/webp',
      );
    });

    test('base64 is the wire form', () {
      expect(ReceiptImage.base64Of(_jpeg), base64Encode(_jpeg));
    });
  });

  group('the vision call', () {
    test('sends the image, its type and a request id', () async {
      http.Request? sent;
      final api = ApiClient(
        baseUrl: 'https://api.test',
        tokenProvider: () => 'jwt',
        httpClient: MockClient((request) async {
          sent = request;
          return _ok([
            {
              'line': 'AMUL BUTTER 500G',
              'name': 'butter',
              'quantity': 500,
              'unit': 'g',
            },
          ]);
        }),
      );
      final service =
          PantryVisionService(api: api, newRequestId: () => 'req-1234');

      final result = await service.read(_png, mimeType: 'image/png');

      expect(sent!.url.path, '/v1/pantry/parse-image');
      final body = jsonDecode(sent!.body) as Map<String, dynamic>;
      expect(body['request_id'], 'req-1234');
      expect(body['mime_type'], 'image/png');
      expect(base64Decode(body['image_base64'] as String), _png);
      expect(result.items.single.name, 'butter');
      expect(result.items.single.quantity, 500);
      expect(result.remaining, 9);
    });

    test('an empty image is not a request', () async {
      var calls = 0;
      final service = PantryVisionService(
        api: ApiClient(
          baseUrl: 'https://api.test',
          tokenProvider: () => 'jwt',
          httpClient: MockClient((_) async {
            calls++;
            return _ok(const []);
          }),
        ),
      );
      expect((await service.read(const [])).items, isEmpty);
      expect(calls, 0);
    });

    test('the daily cap is a state, not a failure', () async {
      final service = PantryVisionService(
        api: ApiClient(
          baseUrl: 'https://api.test',
          tokenProvider: () => 'jwt',
          httpClient: MockClient(
              (_) async => http.Response('{"error":"daily_cap_reached"}', 429)),
        ),
      );
      await expectLater(
        service.read(_jpeg),
        throwsA(isA<PantryCapReached>()),
      );
    });
  });

  group('the photo door', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      SharedPreferences.setMockInitialValues(
          {'receipt_vision_disclosure': true});
    });
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
                      builder: (_, __) =>
                          const Scaffold(body: PantryAddScreen()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

    PantryVisionService vision(http.Response response) => PantryVisionService(
          api: ApiClient(
            baseUrl: 'https://api.test',
            tokenProvider: () => 'jwt',
            httpClient: MockClient((_) async => response),
          ),
        );

    Future<void> openPhotoDoor(WidgetTester tester) async {
      await tester.tap(find.byKey(const ValueKey('pantry-add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pantry-door-photo')));
      await tester.pumpAndSettle();
    }

    /// The door opens on its own copy and button; the source sheet is what the
    /// button opens.
    Future<void> pick(WidgetTester tester) async {
      await tester.tap(find.byKey(const ValueKey('pantry-photo')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Screenshot or photo'));
      await tester.pumpAndSettle();
    }

    testWidgets('uploads the picture and reviews what came back, marked AI',
        (tester) async {
      var picks = 0;
      await tester.pumpWidget(page([
        receiptImagePickerProvider.overrideWithValue((source) async {
          picks++;
          return _jpeg;
        }),
        pantryVisionServiceProvider.overrideWithValue(vision(_ok([
          {
            'line': 'AMUL BUTTER 500G',
            'name': 'butter',
            'quantity': 500,
            'unit': 'g',
          },
        ]))),
      ]));
      await tester.pump(const Duration(milliseconds: 200));

      await openPhotoDoor(tester);
      await pick(tester);

      expect(picks, 1);
      expect(find.text('butter'), findsOneWidget);
      expect(find.text('500 g'), findsOneWidget);
      expect(find.byKey(const ValueKey('pantry-ai-chip-0')), findsOneWidget);
      expect(find.text('Add 1 of 1'), findsOneWidget);
    });

    testWidgets('the disclosure comes once, before the first upload',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      var picks = 0;
      await tester.pumpWidget(page([
        receiptImagePickerProvider.overrideWithValue((source) async {
          picks++;
          return _jpeg;
        }),
        pantryVisionServiceProvider.overrideWithValue(vision(_ok(const []))),
      ]));
      await tester.pump(const Duration(milliseconds: 200));

      await openPhotoDoor(tester);
      await tester.tap(find.byKey(const ValueKey('pantry-photo')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pantry-vision-disclosure')),
          findsOneWidget);
      expect(picks, 0, reason: 'nothing is uploaded before the trade is said');

      await tester
          .tap(find.byKey(const ValueKey('pantry-vision-disclosure-ok')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Screenshot or photo'));
      await tester.pumpAndSettle();
      expect(picks, 1);

      // Second time: no sheet. The memory is the device's, not the session's.
      await tester.tap(find.byKey(const ValueKey('pantry-door-photo')));
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey('pantry-vision-disclosure')), findsNothing);
      expect(
        (await SharedPreferences.getInstance())
            .getBool('receipt_vision_disclosure'),
        isTrue,
      );
    });

    testWidgets('an unreadable picture is a sentence, not an error',
        (tester) async {
      await tester.pumpWidget(page([
        receiptImagePickerProvider.overrideWithValue((source) async => _jpeg),
        pantryVisionServiceProvider.overrideWithValue(vision(_ok(const []))),
      ]));
      await tester.pump(const Duration(milliseconds: 200));

      await openPhotoDoor(tester);
      await pick(tester);

      expect(
        find.text('Nothing readable in that picture — type it instead.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('pantry-line-0')), findsNothing);
    });

    testWidgets('the cap keeps the lines and says why', (tester) async {
      await tester.pumpWidget(page([
        receiptImagePickerProvider.overrideWithValue((source) async => _jpeg),
        pantryVisionServiceProvider.overrideWithValue(
          vision(http.Response('{"error":"daily_cap_reached"}', 429)),
        ),
      ]));
      await tester.pump(const Duration(milliseconds: 200));

      await openPhotoDoor(tester);
      await pick(tester);

      expect(find.text('AI reads used up for today — type them instead'),
          findsOneWidget);
    });

    testWidgets('no connection: the door is closed, typing still is not',
        (tester) async {
      var picks = 0;
      await tester.pumpWidget(page([
        syncStatusProvider.overrideWith((ref) => SyncStatus.offline),
        receiptImagePickerProvider.overrideWithValue((source) async {
          picks++;
          return _jpeg;
        }),
      ]));
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.byKey(const ValueKey('pantry-add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pantry-door-photo')));
      await tester.pumpAndSettle();

      expect(
        find.text(
            'The receipt reader needs a connection. Type it or say it instead.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('pantry-photo')));
      await tester.pumpAndSettle();
      expect(find.text('Screenshot or photo'), findsNothing,
          reason: 'the door does not open without a connection');
      expect(picks, 0);

      // And the typed door is untouched.
      await tester.tap(find.byKey(const ValueKey('pantry-door-typed')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pantry-text')), findsOneWidget);
    });
  });

  test('ML Kit and the on-device OCR service are gone', () {
    expect(File('lib/data/services/ocr_service.dart').existsSync(), isFalse);
    expect(File('pubspec.yaml').readAsStringSync(),
        isNot(contains('google_mlkit_text_recognition')));
  });
}
