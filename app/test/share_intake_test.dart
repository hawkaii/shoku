import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/import_service.dart';
import 'package:food_finder/data/services/pending_share.dart';
import 'package:food_finder/data/services/share_intake.dart';
import 'package:food_finder/main.dart';
import 'package:food_finder/presentation/screens/add/import_sheet.dart';
import 'package:food_finder/presentation/state/auth_providers.dart';
import 'package:food_finder/presentation/state/import_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:food_finder/presentation/state/shoku_providers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _shortcode = 'DZzRs0Jx_v1';
const _url = 'https://www.instagram.com/reel/$_shortcode/';

/// The same three calls the plugin offers, without a platform channel.
class _FakeShareSource implements ShareSource {
  _FakeShareSource(
      {this.initialPayload = const [], this.livePayloads = const []});

  /// What launched the process.
  final List<String> initialPayload;

  /// What arrives while the app is running; replayed on subscription.
  final List<List<String>> livePayloads;

  int resets = 0;

  final _events = StreamController<List<String>>();

  @override
  Future<List<String>> initial() async => initialPayload;

  @override
  Stream<List<String>> stream() {
    for (final payload in livePayloads) {
      _events.add(payload);
    }
    return _events.stream;
  }

  @override
  Future<void> reset() async => resets++;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('share intake', () {
    test('a cold-start share is published and written to disk', () async {
      final source = _FakeShareSource(initialPayload: [_url]);
      final container = ProviderContainer(
        overrides: [shareSourceProvider.overrideWithValue(source)],
      );
      addTearDown(container.dispose);

      await container.read(shareIntakeProvider).ready;

      final pending = container.read(pendingShareProvider);
      expect(pending, isNotNull);
      expect(pending!.url, _url);
      expect(pending.hasUrl, isTrue);
      expect(source.resets, 1,
          reason: 'the launching intent is acknowledged once');

      final stored = await PendingShareStore().read();
      expect(stored?.url, _url,
          reason: 'onboarding and a kill both need the note on disk');
    });

    test('a payload with no link is kept, not dropped, and still resets',
        () async {
      final source = _FakeShareSource(
        initialPayload: ['Look at this reel', 'shared from Instagram'],
      );
      final container = ProviderContainer(
        overrides: [shareSourceProvider.overrideWithValue(source)],
      );
      addTearDown(container.dispose);

      await container.read(shareIntakeProvider).ready;

      final pending = container.read(pendingShareProvider);
      expect(pending, isNotNull,
          reason: 'a share with no URL is still a share');
      expect(pending!.url, isNull);
      expect(pending.hasUrl, isFalse);

      final stored = await PendingShareStore().read();
      expect(stored, isNotNull,
          reason: 'the sheet still has to explain itself after a restart');
      expect(stored!.hasUrl, isFalse);
      expect(source.resets, 1);
    });

    test('an empty payload resets and opens nothing', () async {
      final source = _FakeShareSource();
      final container = ProviderContainer(
        overrides: [shareSourceProvider.overrideWithValue(source)],
      );
      addTearDown(container.dispose);

      await container.read(shareIntakeProvider).ready;

      expect(container.read(pendingShareProvider), isNull);
      expect(await PendingShareStore().read(), isNull);
      expect(source.resets, 1,
          reason: 'an empty payload used to be left in the plugin');
    });

    test('a share that arrives while the app is up is published', () async {
      final source = _FakeShareSource(livePayloads: [
        ['https://youtu.be/abc123'],
      ]);
      final container = ProviderContainer(
        overrides: [shareSourceProvider.overrideWithValue(source)],
      );
      addTearDown(container.dispose);

      await container.read(shareIntakeProvider).ready;
      await pumpEventQueue();

      expect(
          container.read(pendingShareProvider)?.url, 'https://youtu.be/abc123');
      expect(
          (await PendingShareStore().read())?.url, 'https://youtu.be/abc123');
    });

    test('a persisted share survives with no live payload at all', () async {
      final sharedAt = DateTime(2026, 11, 6, 7, 30);
      await PendingShareStore()
          .write(PendingShare(url: _url, sharedAt: sharedAt));

      final source = _FakeShareSource();
      final container = ProviderContainer(
        overrides: [shareSourceProvider.overrideWithValue(source)],
      );
      addTearDown(container.dispose);

      await container.read(shareIntakeProvider).ready;

      expect(container.read(pendingShareProvider), isNull,
          reason: 'nothing launched this process from a share');
      final stored = await PendingShareStore().read();
      expect(stored?.url, _url,
          reason: 'the shell reads this after onboarding, minutes later');
      expect(stored!.sharedAt, sharedAt);
    });

    test('a share is consumed exactly once', () async {
      await PendingShareStore().write(
        PendingShare(url: _url, sharedAt: DateTime(2026, 11, 6, 7, 30)),
      );
      final store = PendingShareStore();

      expect((await store.take())?.url, _url);
      expect(await store.take(), isNull,
          reason: 'a second consumer gets nothing');
      expect(await store.read(), isNull);
    });

    test('a corrupt note is forgotten rather than thrown', () async {
      SharedPreferences.setMockInitialValues({'share_pending': 'not json'});
      expect(await PendingShareStore().read(), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('share_pending'), isNull);
    });
  });

  group('cold start into the shell', () {
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

    Widget app(ImportService importService, ShareSource source) {
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          onboardingDoneProvider.overrideWith((ref) => true),
          authReadyProvider.overrideWith((ref) async {}),
          shareSourceProvider.overrideWithValue(source),
          importServiceProvider.overrideWithValue(importService),
        ],
        child: const ShokuApp(),
      );
    }

    /// The gate, the router and the shell, in the order a cold start runs them.
    Future<void> boot(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 10),
      );
      // The sheet opens from an async store read, and its first request is one
      // more turn of the event loop.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 10),
      );
    }

    testWidgets('a share from before the shell opens the sheet with its link',
        (tester) async {
      await PendingShareStore().write(
        PendingShare(url: _url, sharedAt: DateTime(2026, 11, 6, 7, 30)),
      );

      final calls = <String>[];
      final client = MockClient((request) async {
        calls.add('${request.method} ${request.url.path}');
        return http.Response(
          jsonEncode({'job_id': null, 'state': 'queued', 'shortcode': ''}),
          202,
        );
      });

      final source = _FakeShareSource();
      await tester.pumpWidget(app(service(client), source));
      await boot(tester);

      expect(find.byType(ImportSheet), findsOneWidget,
          reason: 'the shell takes the note once it exists');
      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byType(ImportSheet),
          matching: find.byType(TextField),
        ),
      );
      expect(field.controller!.text, _url);
      expect(calls, contains('POST /v1/imports'),
          reason: 'the import starts on its own, from the shared link');
      expect(await PendingShareStore().read(), isNull,
          reason: 'the note is cleared when it is consumed');

      // The shell schedules a sync pass three seconds in; let it fire, then
      // tear the tree down so no timer outlives the test.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a share with no link explains itself instead of vanishing',
        (tester) async {
      await PendingShareStore().write(
        PendingShare(sharedAt: DateTime(2026, 11, 6, 7, 30)),
      );

      final calls = <String>[];
      final client = MockClient((request) async {
        calls.add('${request.method} ${request.url.path}');
        return http.Response('{}', 200);
      });

      final source = _FakeShareSource();
      await tester.pumpWidget(app(service(client), source));
      await boot(tester);

      expect(find.byType(ImportSheet), findsOneWidget,
          reason: 'a share with no URL is not silence');
      expect(find.byKey(const ValueKey('import-notice')), findsOneWidget);
      expect(find.textContaining('didn’t include a link'), findsOneWidget);
      expect(calls, isEmpty, reason: 'there is no link to import yet');

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpWidget(const SizedBox());
    });
  });
}
