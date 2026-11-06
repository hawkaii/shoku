import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/import_service.dart';
import 'package:food_finder/data/services/pending_import.dart';
import 'package:food_finder/presentation/navigation/import_scope.dart';
import 'package:food_finder/presentation/screens/add/import_sheet.dart';
import 'package:food_finder/presentation/screens/journal/import_card.dart';
import 'package:food_finder/presentation/state/import_providers.dart';
import 'package:food_finder/presentation/state/import_tracker.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _shortcode = 'ABC123';

String _poll({String state = 'extracting', String? stage, String? title}) =>
    jsonEncode({
      'job_id': 'job1',
      'state': state,
      'shortcode': _shortcode,
      'reason': null,
      'progress_stage': stage ?? state,
      'created_at': '2026-10-31T06:20:00Z',
      'updated_at': '2026-10-31T06:20:01Z',
      'title': title,
    });

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
    'steps': ['Fry'],
    'tags': <String>[],
  },
  'creator': 'Ravi',
  'url': 'https://instagram.com/reel/$_shortcode/',
});

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async => db.close());

  /// The shell's stand-in: the scope that owns the poller, showing a tab that is
  /// not the Journal.
  Widget otherTab(http.Client client) => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
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
          home: const ImportTrackerScope(
            child: Scaffold(body: Center(child: Text('Cookbook'))),
          ),
        ),
      );

  Widget card(http.Client client) => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
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
          home: const Scaffold(body: JournalImportCard()),
        ),
      );

  Future<void> seedPending() => PendingImportStore().write(PendingImport(
        url: 'https://instagram.com/reel/$_shortcode/',
        shortcode: _shortcode,
        jobId: 'job1',
        startedAt: DateTime(2026, 10, 31, 6, 20),
      ));

  testWidgets('a running import is visible by name, then leaves when it lands',
      (tester) async {
    await seedPending();

    var polls = 0;
    final client = MockClient((request) async {
      if (request.url.path.startsWith('/v1/imports/')) {
        polls++;
        return polls == 1
            ? http.Response(
                _poll(stage: 'transcribing', title: 'Paneer Tikka'), 200)
            : http.Response(_poll(state: 'ready', title: 'Paneer Tikka'), 200);
      }
      return http.Response(_content, 200);
    });

    await tester.pumpWidget(card(client));
    await tester.pump(); // restore reads the record
    await tester.pump(); // first poll

    expect(find.byKey(const ValueKey('import-card')), findsOneWidget);
    expect(find.text('Paneer Tikka'), findsOneWidget);
    expect(find.byKey(const ValueKey('import-card-stage')), findsOneWidget);
    expect(find.text('Reading the audio'), findsOneWidget);

    await tester.pump(ImportTracker.pollInterval);
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('import-card')), findsNothing,
        reason: 'the card goes when the dish arrives');
    expect((await JournalRepository(db).loadDishes()).single.title,
        'Paneer Tikka');
    expect(await PendingImportStore().read(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('without a title it leads with the stage', (tester) async {
    await seedPending();
    final client = MockClient((request) async {
      return http.Response(_poll(stage: 'watching'), 200);
    });

    await tester.pumpWidget(card(client));
    await tester.pump();
    await tester.pump();

    expect(find.text('Watching the video'), findsOneWidget);
    expect(find.byKey(const ValueKey('import-card-stage')), findsNothing,
        reason: 'the stage is the headline, not a subline');

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('before any stage arrives it still says what it is doing',
      (tester) async {
    await seedPending();
    final stuck = Completer<http.Response>();
    final client = MockClient((request) => stuck.future);

    await tester.pumpWidget(card(client));
    await tester.pump();
    await tester.pump();

    expect(find.text('Importing a reel'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a failure becomes one quiet line that can be dismissed',
      (tester) async {
    await seedPending();
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'job_id': 'job1',
          'state': 'failed',
          'shortcode': _shortcode,
          'reason': 'worker_unavailable',
          'progress_stage': 'failed',
          'title': null,
        }),
        200,
      );
    });

    await tester.pumpWidget(card(client));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('import-card-failed')), findsOneWidget);
    expect(find.text('The kitchen did not wake up — try again in a minute'),
        findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(find.byKey(const ValueKey('import-card-failed')), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a job that settles on another tab still writes its dish',
      (tester) async {
    await seedPending();

    var polls = 0;
    final client = MockClient((request) async {
      if (request.url.path.startsWith('/v1/imports/')) {
        polls++;
        return polls == 1
            ? http.Response(_poll(stage: 'transcribing'), 200)
            : http.Response(_poll(state: 'ready'), 200);
      }
      return http.Response(_content, 200);
    });

    await tester.pumpWidget(otherTab(client));
    await tester.pump();
    await tester.pump();

    // The card lives on the Journal and nowhere else.
    expect(find.byKey(const ValueKey('import-card')), findsNothing);
    expect(find.text('Cookbook'), findsOneWidget);

    await tester.pump(ImportTracker.pollInterval);
    await tester.pump();
    await tester.pump();

    expect((await JournalRepository(db).loadDishes()).single.title,
        'Paneer Tikka',
        reason: 'the work finishes whether or not the tab is watched');
    expect(await PendingImportStore().read(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a job adopted by both the tracker and the sheet writes one dish',
      (tester) async {
    await seedPending();

    var jobPolls = 0;
    var contentFetches = 0;
    final client = MockClient((request) async {
      if (request.url.path.startsWith('/v1/imports/')) {
        jobPolls++;
        return http.Response(_poll(state: 'ready', title: 'Paneer Tikka'), 200);
      }
      contentFetches++;
      // Slow enough that both pollers are inside createDish at the same time:
      // the duplicate scan is a read, so this is what it takes to fool it.
      await Future<void>.delayed(const Duration(seconds: 1));
      return http.Response(_content, 200);
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
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
        home: ImportTrackerScope(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showImportSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));

    // The tracker picks the job up on mount and is inside createDish already.
    for (var i = 0; i < 20 && contentFetches == 0; i++) {
      await tester.pump();
    }
    expect(contentFetches, 1, reason: 'the tracker is reading the content');

    // The same job, adopted by the sheet as well.
    await tester.tap(find.text('open'));
    for (var i = 0; i < 20 && jobPolls < 2; i++) {
      await tester.pump();
    }
    expect(jobPolls, 2, reason: 'the sheet resumed the job the tracker holds');
    await tester.pump();
    await tester.pump();

    expect(contentFetches, 1,
        reason: 'the sheet joined the insert already running');

    // The read lands, both callers settle, and the journal has one dish.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final dishes = await JournalRepository(db).loadDishes();
    expect(dishes, hasLength(1));
    expect(dishes.single.title, 'Paneer Tikka');
    expect(await PendingImportStore().read(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('nothing pending means nothing is polled', (tester) async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response(_poll(), 200);
    });

    await tester.pumpWidget(otherTab(client));
    await tester.pump();
    await tester.pump(const Duration(seconds: 30));

    expect(requests, 0, reason: 'no pending import, no traffic');

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the sleeping-worker stage reads as working, not frozen',
      (tester) async {
    await seedPending();
    final client = MockClient((request) async {
      return http.Response(_poll(stage: 'starting'), 200);
    });

    await tester.pumpWidget(card(client));
    await tester.pump();
    await tester.pump();

    expect(find.text('Waking the kitchen…'), findsOneWidget);
    expect(find.text('The first one after a pause takes a minute'),
        findsOneWidget);
    expect(find.byKey(const ValueKey('import-card-failed')), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });
}
