import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/db/pantry_repository.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/auth_service.dart';
import 'package:food_finder/data/sync/sync_repository.dart';
import 'package:food_finder/data/sync/sync_service.dart';
import 'package:food_finder/presentation/state/journal_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:food_finder/presentation/state/sync_providers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Auth as the sync layer sees it: a token and a stream of changes.
class _FakeAuth extends AuthService {
  _FakeAuth({this.token, Stream<ShokuAuthEvent>? eventStream})
      : _events = eventStream;

  final String? token;
  final Stream<ShokuAuthEvent>? _events;

  @override
  String? get accessToken => token;

  @override
  Stream<ShokuAuthEvent> get events => _events ?? const Stream.empty();
}

http.Response _okPull() => http.Response(
      jsonEncode({
        'dishes': <Map<String, dynamic>>[],
        'versions': <Map<String, dynamic>>[],
        'cook_logs': <Map<String, dynamic>>[],
        'cursor': null,
      }),
      200,
    );

/// A container whose API answers with [respond], counting every request.
ProviderContainer _container({
  required AppDatabase db,
  required int Function() calls,
  required http.Response Function(int call) respond,
  String? token = 'jwt',
  Stream<ShokuAuthEvent>? events,
}) {
  final client = MockClient((request) async => respond(calls()));

  return ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      authServiceProvider
          .overrideWithValue(_FakeAuth(token: token, eventStream: events)),
      syncServiceProvider.overrideWith(
        (ref) => SyncService(
          repository: SyncRepository(db, JournalRepository(db)),
          api: ApiClient(
            baseUrl: 'https://api.test',
            tokenProvider: () => token,
            httpClient: client,
          ),
        ),
      ),
    ],
  );
}

void main() {
  late AppDatabase db;
  var calls = 0;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    calls = 0;
  });

  tearDown(() async => db.close());

  testWidgets('without a token it reports signed out and makes no request',
      (tester) async {
    final container = _container(
      db: db,
      calls: () => calls,
      respond: (_) {
        calls++;
        return _okPull();
      },
      token: null,
    );

    await container.read(syncControllerProvider).syncNow();

    expect(container.read(syncStatusProvider), SyncStatus.signedOut);
    expect(calls, 0, reason: 'a 401 we can predict is not worth a round trip');

    // The signed-out retry is a timer; dispose cancels it so the test does not
    // end with work still scheduled.
    container.dispose();
  });

  testWidgets('signing in fills an empty journal without a reload',
      (tester) async {
    final events = StreamController<ShokuAuthEvent>();
    addTearDown(events.close);

    final container = _container(
      db: db,
      calls: () => calls,
      respond: (_) {
        calls++;
        return http.Response(
          jsonEncode({
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
            'versions': <Map<String, dynamic>>[],
            'cook_logs': <Map<String, dynamic>>[],
            'cursor': 'c1',
          }),
          200,
        );
      },
      events: events.stream,
    );
    addTearDown(container.dispose);

    container.read(syncControllerProvider);
    expect(container.read(dishesProvider), isEmpty,
        reason: 'the browser holds nothing of its own');
    await tester.pump();

    events.add(ShokuAuthEvent.signedIn);
    await tester.pump();
    await tester.pump();

    expect(
      container.read(dishesProvider).map((d) => d.title),
      contains('Ravi paneer'),
      reason: 'a sign-in is enough; no reload required',
    );
    expect(container.read(syncStatusProvider), SyncStatus.idle);
    container.dispose();
    // Riverpod's subscription bookkeeping leaves a zero-duration timer behind;
    // let it run so the test does not end with work scheduled.
    await tester.pump(Duration.zero);
  });

  testWidgets('a failed pass retries itself instead of going quiet forever',
      (tester) async {
    final container = _container(
      db: db,
      calls: () => calls,
      respond: (call) {
        calls++;
        return call == 0
            ? http.Response('{"error":"boom"}', 500)
            : _okPull();
      },
    );
    addTearDown(container.dispose);

    await container.read(syncControllerProvider).syncNow();
    expect(container.read(syncStatusProvider), SyncStatus.failed);
    expect(calls, 1);

    // Nothing else touches sync: only the backoff can rescue it.
    await tester.pump(SyncBackoff.delayFor(0));
    await tester.pump();

    expect(container.read(syncStatusProvider), SyncStatus.idle);
    expect(calls, 2);
  });

  testWidgets('signing in runs a pass immediately', (tester) async {
    final events = StreamController<ShokuAuthEvent>();
    addTearDown(events.close);

    final container = _container(
      db: db,
      calls: () => calls,
      respond: (_) {
        calls++;
        return _okPull();
      },
      events: events.stream,
    );
    addTearDown(container.dispose);

    // The app watches this provider at the root; without the read, nothing is
    // subscribed to auth and the test would prove nothing.
    container.read(syncControllerProvider);
    await tester.pump();

    events.add(ShokuAuthEvent.signedIn);
    await tester.pump();
    await tester.pump();

    expect(calls, greaterThan(0), reason: 'the journal fills without a reload');
    expect(container.read(syncStatusProvider), SyncStatus.idle);
  });

  testWidgets('a token refresh heals a 401', (tester) async {
    var unauthorized = true;
    final events = StreamController<ShokuAuthEvent>();
    addTearDown(events.close);

    final container = _container(
      db: db,
      calls: () => calls,
      respond: (_) {
        calls++;
        return unauthorized
            ? http.Response('{"error":"unauthorized"}', 401)
            : _okPull();
      },
      events: events.stream,
    );
    addTearDown(container.dispose);

    await container.read(syncControllerProvider).syncNow();
    expect(container.read(syncStatusProvider), SyncStatus.signedOut);
    expect(calls, 1);

    unauthorized = false;
    events.add(ShokuAuthEvent.tokenRefreshed);
    await tester.pump();
    await tester.pump();

    expect(container.read(syncStatusProvider), SyncStatus.idle);
    expect(calls, 2);
  });

  testWidgets('coming back to the app retries after a failure',
      (tester) async {
    final container = _container(
      db: db,
      calls: () => calls,
      respond: (call) {
        calls++;
        return call == 0
            ? http.Response('{"error":"boom"}', 500)
            : _okPull();
      },
    );
    addTearDown(container.dispose);

    final controller = container.read(syncControllerProvider);
    await controller.syncNow();
    expect(container.read(syncStatusProvider), SyncStatus.failed);

    // Before the backoff would have fired.
    await controller.onResume();

    expect(container.read(syncStatusProvider), SyncStatus.idle);
    expect(calls, 2);
  });

  testWidgets('resume does nothing when the last pass was clean',
      (tester) async {
    final container = _container(
      db: db,
      calls: () => calls,
      respond: (_) {
        calls++;
        return _okPull();
      },
    );
    addTearDown(container.dispose);

    final controller = container.read(syncControllerProvider);
    await controller.syncNow();
    await controller.onResume();

    expect(calls, 1, reason: 'an idle journal is not worth a request');
  });

  testWidgets('a sync asked for mid-pass runs once more, and carries the edit',
      (tester) async {
    final pushBodies = <Map<String, dynamic>>[];
    final firstPullStarted = Completer<void>();
    final releaseFirstPull = Completer<void>();
    var pulls = 0;

    final client = MockClient((request) async {
      if (request.url.path.endsWith('/push')) {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        pushBodies.add(body);
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
      // The first pull is held open. That is the window a real edit and its
      // syncNow() land in: after the push was accepted, before the pass ends.
      pulls++;
      if (pulls == 1) {
        firstPullStarted.complete();
        await releaseFirstPull.future;
      }
      return _okPull();
    });

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        authServiceProvider.overrideWithValue(_FakeAuth(token: 'jwt')),
        syncServiceProvider.overrideWith(
          (ref) => SyncService(
            repository: SyncRepository(db, JournalRepository(db)),
            api: ApiClient(
              baseUrl: 'https://api.test',
              tokenProvider: () => 'jwt',
              httpClient: client,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final pantry = PantryRepository(db);
    await pantry.add(name: 'salt');

    final controller = container.read(syncControllerProvider);
    final firstPass = controller.syncNow();
    await firstPullStarted.future;

    await pantry.add(name: 'rice');
    await controller.syncNow(); // asked for while the pass is still running
    await controller.syncNow(); // and again: a burst is still one follow-up

    releaseFirstPull.complete();
    await firstPass;

    expect(pushBodies, hasLength(2),
        reason: 'the request is queued, not dropped, and it is queued once');
    expect(
      (pushBodies.last['pantry_items'] as List)
          .map((row) => (row as Map)['name']),
      contains('rice'),
      reason: 'the follow-up pass is what gets the mid-pass edit to the server',
    );
    expect(await SyncRepository(db, JournalRepository(db)).dirtyCount(), 0);
    expect(container.read(syncStatusProvider), SyncStatus.idle);
  });
}
