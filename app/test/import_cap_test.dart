import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/import_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// The import allowance reaches the sheet as a state, not as "unreachable".
void main() {
  late AppDatabase db;
  late ImportService service;

  ImportService build(int status, Map<String, dynamic> body) {
    return ImportService(
      api: ApiClient(
        baseUrl: 'https://api.test',
        tokenProvider: () => 'jwt',
        httpClient:
            MockClient((_) async => http.Response(jsonEncode(body), status)),
      ),
      repository: JournalRepository(db),
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  test('a 429 is the daily import allowance, not a failure', () async {
    service = build(429, {
      'error': 'daily_cap_reached',
      'detail': 'daily import limit of 5 reached',
      'reset_at': '2026-11-07T00:00:00Z',
    });

    expect(
      () => service.start('https://www.instagram.com/reel/abc123/'),
      throwsA(isA<ImportCapReached>()),
    );
  });

  test('a queued import carries what is left today', () async {
    service = build(202, {
      'job_id': 'job-1',
      'state': 'queued',
      'cached': false,
      'shortcode': 'abc123',
      'remaining': 4,
      'reset_at': '2026-11-07T00:00:00Z',
    });

    final started =
        await service.start('https://www.instagram.com/reel/abc123/');

    expect(started.stage, ImportStage.queued);
    expect(started.remaining, 4);
    expect(started.resetAt, isNotNull);
  });
}
