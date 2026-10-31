import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/import_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late AppDatabase db;
  var requests = 0;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    requests = 0;
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

  http.Response pollResponse(String state, {String? detail}) => http.Response(
        jsonEncode({
          'job_id': 'job1',
          'state': state,
          'shortcode': 'DZzRs0Jx_v1',
          'reason': null,
          'progress_stage': detail ?? state,
          'created_at': '2026-10-31T06:20:00Z',
          'updated_at': '2026-10-31T06:20:01Z',
        }),
        200,
      );

  test('one dropped poll is retried instead of failing the import', () async {
    final client = MockClient((request) async {
      requests++;
      return switch (requests) {
        1 => http.Response('{"error":"boom"}', 502),
        2 => pollResponse('extracting', detail: 'watching'),
        _ => pollResponse('ready'),
      };
    });

    final seen = await service(client).watch('job1', seconds: 30).toList();

    expect(seen.map((p) => p.stage), [ImportStage.extracting, ImportStage.ready]);
    expect(requests, 3, reason: 'the blip cost an attempt, not the import');
  });

  test('three failures in a row are a real failure, and it says so', () async {
    final client = MockClient((request) async {
      requests++;
      return http.Response('{"error":"boom"}', 502);
    });

    await expectLater(
      service(client).watch('job1', seconds: 30).toList(),
      throwsA(isA<ApiError>()),
    );
    expect(requests, 3, reason: 'three attempts, then it gives up');
  });

  test('being signed out is not worth retrying', () async {
    final client = MockClient((request) async {
      requests++;
      return http.Response('{}', 401);
    });

    await expectLater(
      service(client).watch('job1', seconds: 30).toList(),
      throwsA(isA<ApiUnauthenticated>()),
    );
    expect(requests, 1);
  });

  group('failure copy', () {
    test('a client timeout is not the generic message', () {
      final text = importReasonText('timed_out');

      expect(text, contains('Still reading'));
      expect(text, isNot(importReasonText(null)));
      expect(text, isNot(importReasonText('failed')));
    });

    test('the server timeout keeps its own words', () {
      expect(importReasonText('timeout'), contains('took too long'));
      expect(importReasonText('timed_out'), isNot(importReasonText('timeout')));
    });

    test('a job the server forgot says so', () {
      expect(importReasonText('gone'), contains('no longer on the server'));
    });
  });
}
