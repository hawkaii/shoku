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
import 'package:food_finder/presentation/screens/add/add_sheet.dart';
import 'package:food_finder/presentation/screens/add/import_sheet.dart';
import 'package:food_finder/presentation/state/import_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _shortcode = 'DZzRs0Jx_v1';
const _url = 'https://www.instagram.com/reel/$_shortcode/';

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
  'prose': {'summary': '', 'creator_note': ''},
  'creator': 'Ravi',
  'creator_handle': '@ravi',
  'platform': 'instagram',
  'thumbnail_url': 'https://example.test/reel.jpg',
  'url': _url,
  'extraction_version': 3,
});

void main() {
  late AppDatabase db;
  late List<String> calls;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    calls = [];
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async => db.close());

  ImportService service(http.Client client) => ImportService(
        api: ApiClient(
          baseUrl: 'https://api.test',
          tokenProvider: () => 'jwt',
          httpClient: client,
        ),
        repository: JournalRepository(db),
      );

  Widget app(ImportService importService, {String? prefill}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        importServiceProvider.overrideWithValue(importService),
      ],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showImportSheet(context, prefill: prefill),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  /// The same sheet, with its two timing knobs turned down so a test can reach
  /// the slow and expired paths without waiting minutes.
  Widget appWithTimings(
    ImportService importService, {
    required Duration slowAfter,
    required int watchSeconds,
    String? prefill,
  }) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        importServiceProvider.overrideWithValue(importService),
      ],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => ImportSheet(
                  prefill: prefill,
                  slowAfter: slowAfter,
                  watchSeconds: watchSeconds,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('a cached reel with no job goes straight to the dish',
      (tester) async {
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path == '/v1/imports') {
        return http.Response(
          jsonEncode({
            'job_id': null,
            'state': 'ready',
            'cached': true,
            'shortcode': _shortcode,
          }),
          200,
        );
      }
      return http.Response(_content, 200);
    });

    await tester.pumpWidget(app(service(client), prefill: _url));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Saved Paneer Tikka'), findsOneWidget);
    expect(calls, ['POST /v1/imports', 'GET /v1/content/$_shortcode']);

    final dishes = await JournalRepository(db).loadDishes();
    expect(dishes.single.title, 'Paneer Tikka');
  });

  testWidgets('a ready parse with no job resumes without a second import',
      (tester) async {
    // The app died after the server had parsed the reel but before the dish was
    // written: only the shortcode survived.
    await PendingImportStore().write(PendingImport(
      url: _url,
      shortcode: _shortcode,
      startedAt: DateTime(2026, 10, 31, 6, 24),
    ));

    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      return http.Response(_content, 200);
    });

    await tester.pumpWidget(app(service(client)));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Saved Paneer Tikka'), findsOneWidget);
    expect(calls, ['GET /v1/content/$_shortcode'],
        reason: 'resuming must never start a second import');
    expect(await PendingImportStore().read(), isNull,
        reason: 'the note is cleared once the dish exists');

    final dishes = await JournalRepository(db).loadDishes();
    expect(dishes.single.title, 'Paneer Tikka');
  });

  testWidgets('a link typed into the add sheet is the link that gets imported',
      (tester) async {
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path == '/v1/imports') {
        return http.Response(
          jsonEncode({
            'job_id': null,
            'state': 'ready',
            'cached': true,
            'shortcode': _shortcode,
          }),
          200,
        );
      }
      return http.Response(_content, 200);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          importServiceProvider.overrideWithValue(service(client)),
        ],
        child: MaterialApp(
          theme: ShokuTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAddSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), _url);
    await tester.tap(find.text('Share from another app'));
    await tester.pumpAndSettle();

    expect(find.text('Saved Paneer Tikka'), findsOneWidget);
    expect(calls.first, 'POST /v1/imports');
  });

  testWidgets('a pending job that is ready is finished, not re-imported',
      (tester) async {
    await PendingImportStore().write(PendingImport(
      url: _url,
      shortcode: _shortcode,
      jobId: 'job1',
      startedAt: DateTime(2026, 10, 31, 6, 24),
    ));

    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path == '/v1/imports/job1') {
        return http.Response(
          jsonEncode({
            'job_id': 'job1',
            'state': 'ready',
            'shortcode': _shortcode,
            'reason': null,
            'progress_stage': 'ready',
            'created_at': '2026-10-31T06:20:00Z',
            'updated_at': '2026-10-31T06:20:01Z',
          }),
          200,
        );
      }
      return http.Response(_content, 200);
    });

    await tester.pumpWidget(app(service(client)));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Saved Paneer Tikka'), findsOneWidget);
    expect(calls, ['GET /v1/imports/job1', 'GET /v1/content/$_shortcode']);
    expect(calls.any((c) => c == 'POST /v1/imports'), isFalse);
  });

  testWidgets('a long job stops saying "reading" and says it is still working',
      (tester) async {
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path == '/v1/imports') {
        return http.Response(
          jsonEncode({
            'job_id': 'job1',
            'state': 'extracting',
            'cached': false,
            'shortcode': _shortcode,
          }),
          202,
        );
      }
      return http.Response(
        jsonEncode({
          'job_id': 'job1',
          'state': 'extracting',
          'shortcode': _shortcode,
          'reason': null,
          'progress_stage': 'transcribing',
          'created_at': '2026-10-31T06:20:00Z',
          'updated_at': '2026-10-31T06:20:01Z',
        }),
        200,
      );
    });

    await tester.pumpWidget(appWithTimings(
      service(client),
      slowAfter: const Duration(milliseconds: 300),
      watchSeconds: 240,
      prefill: _url,
    ));
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Under the threshold it says what the worker is doing.
    expect(find.text('Reading the audio'), findsOneWidget);
    expect(find.text('Still working — this reel is long'), findsNothing);

    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Still working — this reel is long'), findsOneWidget);
    expect(
      find.textContaining('takes a few minutes'),
      findsOneWidget,
      reason: 'the wait is explained, not just spinning',
    );

    // The job is still the server's; the sheet has not called it a failure.
    expect(find.byKey(const ValueKey('import-still-reading')), findsNothing);
    await tester.pumpWidget(const SizedBox());
    // Let the cancelled poll delay drain so the test ends with no timer running.
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a sleeping worker reads as waking the kitchen, not as an error',
      (tester) async {
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path == '/v1/imports') {
        return http.Response(
          jsonEncode({
            'job_id': 'job1',
            'state': 'extracting',
            'cached': false,
            'shortcode': _shortcode,
          }),
          202,
        );
      }
      return http.Response(
        jsonEncode({
          'job_id': 'job1',
          'state': 'extracting',
          'shortcode': _shortcode,
          'reason': null,
          'progress_stage': 'starting',
          'created_at': '2026-10-31T06:20:00Z',
          'updated_at': '2026-10-31T06:20:01Z',
        }),
        200,
      );
    });

    await tester.pumpWidget(app(service(client), prefill: _url));
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Waking the kitchen…'), findsOneWidget);
    expect(find.text('The first one after a pause takes a minute'),
        findsOneWidget);
    // Waiting for the worker is a stage: nothing has gone wrong.
    expect(find.byKey(const ValueKey('import-still-reading')), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('an expired window says it is still reading and keeps the note',
      (tester) async {
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path == '/v1/imports') {
        return http.Response(
          jsonEncode({
            'job_id': 'job1',
            'state': 'extracting',
            'cached': false,
            'shortcode': _shortcode,
          }),
          202,
        );
      }
      return http.Response(
        jsonEncode({
          'job_id': 'job1',
          'state': 'extracting',
          'shortcode': _shortcode,
          'reason': null,
          'progress_stage': 'transcribing',
          'created_at': '2026-10-31T06:20:00Z',
          'updated_at': '2026-10-31T06:20:01Z',
        }),
        200,
      );
    });

    await tester.pumpWidget(appWithTimings(
      service(client),
      slowAfter: const Duration(seconds: 60),
      watchSeconds: 0,
      prefill: _url,
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('import-still-reading')), findsOneWidget);
    expect(find.textContaining('You can leave this'), findsOneWidget);
    // Nothing has failed, so nothing is painted as an error.
    expect(find.textContaining('Could not reach'), findsNothing);
    expect(find.textContaining('Could not read'), findsNothing);

    // The job is persisted, so the next open picks it up.
    final pending = await PendingImportStore().read();
    expect(pending, isNotNull);
    expect(pending!.jobId, 'job1');

    await tester.pumpWidget(const SizedBox());
  });
}
