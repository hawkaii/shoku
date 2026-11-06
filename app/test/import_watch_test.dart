import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/import_service.dart';
import 'package:food_finder/l10n/app_localizations_en.dart';
import 'package:food_finder/presentation/screens/journal/import_card.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final l10n = AppLocalizationsEn();
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

  group('the watch window', () {
    test('waits four minutes, not two', () {
      // A real reel spends ~90 s transcribing, and a healthy import has been
      // seen at 184 s end to end.
      expect(ImportService.defaultWatchSeconds, 240);
    });

    test('a job that is still running is not called a timeout', () async {
      final client = MockClient((request) async {
        requests++;
        return pollResponse('extracting', detail: 'transcribing');
      });

      final seen = <ImportProgress>[];
      final sub = service(client).watch('job1').listen(seen.add);
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      await sub.cancel();

      expect(seen, isNotEmpty, reason: 'it keeps reading');
      expect(seen.every((p) => p.reason != 'timed_out'), isTrue);
    });

    test('when the window runs out it says timed_out, not failed', () async {
      final client = MockClient((request) async {
        requests++;
        return pollResponse('extracting', detail: 'transcribing');
      });

      final seen = await service(client).watch('job1', seconds: 0).toList();

      expect(seen.single.stage, ImportStage.failed);
      expect(seen.single.reason, 'timed_out');
      expect(reasonText(l10n, 'timed_out'), contains('You can leave this'));
    });
  });

  group('a sleeping worker', () {
    test('starting is a stage with its own words, not a failure', () {
      const waking = ImportProgress(
        stage: ImportStage.extracting,
        detail: 'starting',
        shortcode: 'SC',
      );
      expect(stageText(l10n, waking), l10n.importWaking);
      // The hint under a waking worker is fixed copy, not derived from the
      // stage; the sheet reads the key directly.
      expect(l10n.importWaitingHint, isNotEmpty);
      expect(waking.stage, isNot(ImportStage.failed));

      // Whichever job state the server pairs it with, the copy holds.
      const queued = ImportProgress(
        stage: ImportStage.queued,
        detail: 'starting',
        shortcode: 'SC',
      );
      expect(stageText(l10n, queued), l10n.importWaking);
    });

    test('the other stages read exactly as they did', () {
      String? label(String detail,
              {ImportStage stage = ImportStage.extracting}) =>
          stageText(
              l10n,
              ImportProgress(
                  stage: stage, detail: detail, shortcode: 'SC'));

      expect(label('extracting'), 'Reading the reel');
      expect(label('transcribing'), 'Reading the audio');
      expect(label('watching'), 'Watching the video');
      expect(label('structuring'), 'Writing the recipe');
      expect(label('caption_only'), 'Reading the caption');
      expect(
        stageText(
            l10n, const ImportProgress(stage: ImportStage.queued, shortcode: 'SC')),
        l10n.importQueued,
      );
      expect(
        stageText(
            l10n, const ImportProgress(stage: ImportStage.ready, shortcode: 'SC')),
        l10n.importReady,
      );
    });

    test('a kitchen that would not wake says so, in its own sentence', () {
      final text = reasonText(l10n, 'worker_unavailable');

      expect(text, 'The kitchen did not wake up — try again in a minute');
      expect(text, isNot(reasonText(l10n, null)));
      expect(text, isNot(contains('Could not read this one')));
    });
  });

  group('failure copy', () {
    test('a client timeout is not the generic message', () {
      final text = reasonText(l10n, 'timed_out');

      expect(text, contains('Still reading'));
      expect(text, isNot(reasonText(l10n, null)));
      expect(text, isNot(reasonText(l10n, 'failed')));
    });

    test('the server timeout keeps its own words', () {
      expect(reasonText(l10n, 'timeout'), contains('took too long'));
      expect(reasonText(l10n, 'timed_out'), isNot(reasonText(l10n, 'timeout')));
    });

    test('a job the server forgot says so', () {
      expect(reasonText(l10n, 'gone'), contains('no longer on the server'));
    });
  });
}
