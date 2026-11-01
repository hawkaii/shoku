import 'dart:async';

import '../db/journal_repository.dart';
import '../mock/journal_data.dart';
import '../models/recipe_content.dart';
import '../services/api_client.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum ImportStage { queued, extracting, ready, failed }

/// Drives one import: ask the server to read a link, wait, then write a dish.
///
/// The waiting is intentionally visible. A reel takes 20–60 seconds, and the
/// alternative — an optimistic empty dish that fills in later — leaves junk in
/// the cookbook when extraction fails.
class ImportService {
  ImportService({required ApiClient api, required JournalRepository repository})
      : _api = api,
        _repository = repository;

  final ApiClient _api;
  final JournalRepository _repository;

  Future<ImportStart> start(String url) async {
    final response = await _api.post('/v1/imports', {'url': url.trim()});
    return ImportStart(
      jobId: response['job_id'] as String?,
      shortcode: response['shortcode'] as String? ?? '',
      stage: _stage(response['state'] as String?),
      cached: response['cached'] == true,
      reason: response['reason'] as String?,
    );
  }

  Future<ImportProgress> poll(String jobId) async {
    final response = await _api.get('/v1/imports/$jobId');
    return ImportProgress(
      stage: _stage(response['state'] as String?),
      detail: response['progress_stage'] as String?,
      reason: response['reason'] as String?,
      shortcode: response['shortcode'] as String? ?? '',
      // Optional: the server fills it once extraction knows the reel's name.
      // Absent is normal, and never becomes a title made up from the URL.
      title: (response['title'] as String?)?.trim(),
    );
  }

  /// How long the sheet waits before it stops looking at a running job.
  ///
  /// A real reel spends ~90 seconds in transcription alone, and with the
  /// download and the model a healthy import has been seen at 184 seconds.
  /// The old 120 s window timed out on ordinary reels.
  static const int defaultWatchSeconds = 240;

  /// Polls until the job settles. Bounded by a deadline so a stuck worker can't
  /// leave the sheet spinning forever.
  Stream<ImportProgress> watch(String jobId, {int? seconds}) async* {
    final deadline =
        DateTime.now().add(Duration(seconds: seconds ?? defaultWatchSeconds));
    var delay = const Duration(seconds: 1);
    while (DateTime.now().isBefore(deadline)) {
      final progress = await pollOnce(jobId);
      yield progress;
      if (progress.stage == ImportStage.ready || progress.stage == ImportStage.failed) {
        return;
      }
      await Future<void>.delayed(delay);
      // Ease off: 1s, 2s, 4s, then every 5s.
      delay = Duration(seconds: delay.inSeconds >= 5 ? 5 : delay.inSeconds * 2);
    }
    // Still ours to lose: the record the sheet keeps is what lets a client
    // timeout be picked up again instead of thrown away.
    yield const ImportProgress(stage: ImportStage.failed, reason: 'timed_out', shortcode: '');
  }

  /// One poll, retried.
  ///
  /// A dropped request says nothing about the import — the worker is on a server
  /// with its own copy of the job — so a single blip must never be reported as a
  /// failed import. Three attempts with backoff, then it really is unreachable.
  static const List<Duration> pollBackoff = [
    Duration(milliseconds: 400),
    Duration(milliseconds: 900),
  ];

  Future<ImportProgress> pollOnce(String jobId) async {
    Object? lastError;
    for (var attempt = 0; attempt <= pollBackoff.length; attempt++) {
      try {
        return await poll(jobId);
      } on ApiUnauthenticated {
        rethrow; // No token will not heal by waiting.
      } catch (error) {
        lastError = error;
        if (attempt == pollBackoff.length) break;
        await Future<void>.delayed(pollBackoff[attempt]);
      }
    }
    throw lastError!;
  }

  /// The reel as the server read it, without writing anything.
  ///
  /// The Wall's detail view reads this and nothing else: no dish, no version, no
  /// rating — only what `/v1/content/{shortcode}` returned.
  Future<RecipeContent?> fetchContent(String shortcode) async {
    final content = await _api.get('/v1/content/$shortcode');
    return RecipeContent.fromJson(content);
  }

  /// Turns a cached extraction into a dish in the journal, with the creator
  /// attached to the version. Imports land as `To cook`.
  Future<Dish?> createDish(String shortcode) async {
    // One reel, one dish. The sheet, the Journal card and a second tap can all
    // ask for the same shortcode within seconds; an existing dish wins.
    for (final dish in await _repository.loadDishes()) {
      for (final version in dish.versions) {
        if (version.originShortcode == shortcode) return dish;
      }
    }

    final content = await _api.get('/v1/content/$shortcode');
    final recipe = content['recipe'] as Map<String, dynamic>?;
    if (recipe == null) return null;

    final dishId = _uuid.v4();
    final ingredients = [
      for (final raw in (recipe['ingredients'] as List? ?? const []))
        if (raw is Map)
          [
            if ((raw['amount'] as String?)?.trim().isNotEmpty ?? false) raw['amount'],
            raw['name'],
          ].whereType<Object>().join(' ').trim(),
    ];
    final steps = [
      for (final raw in (recipe['steps'] as List? ?? const [])) raw.toString(),
    ];

    final dish = Dish(
      id: dishId,
      title: (recipe['title'] as String?)?.trim().isNotEmpty == true
          ? recipe['title'] as String
          : 'Imported recipe',
      subtitle: (content['creator'] as String?)?.trim().isNotEmpty == true
          ? 'From ${content['creator']}'
          : 'Imported',
      // The reel's own cover. When the platform doesn't expose one, the
      // on-brand fallback in ShokuDishImage takes over — never a stock photo
      // of a different dish.
      coverUrl: content['thumbnail_url'] as String? ?? '',
      sourceHandle: content['creator'] as String? ?? '',
      status: DishStatus.toCook,
      minutes: (recipe['minutes'] as num?)?.toInt() ?? 30,
      baselineKcal: (recipe['kcal'] as num?)?.toInt() ?? 0,
      baselineProtein: (recipe['protein'] as num?)?.toInt() ?? 0,
      steps: steps,
      versions: [
        RecipeVersion(
          id: _uuid.v4(),
          number: 0, // imports are identified by creator, not by an ordinal
          changes: const [],
          ingredients: ingredients,
          createdAt: DateTime.now(),
          steps: steps,
          // Parallel to `steps`; null for a parse that predates the extractor's
          // per-step links. Stored locally only — sync never carries it.
          stepIngredients: _stepLinks(recipe['step_ingredients']),
          tags: [
            for (final tag in (recipe['tags'] as List? ?? const []))
              tag.toString(),
          ],
          kcal: (recipe['kcal'] as num?)?.toInt() ?? 0,
          protein: (recipe['protein'] as num?)?.toInt() ?? 0,
          originKind: 'import',
          originCreator: content['creator'] as String?,
          originHandle: content['creator_handle'] as String?,
          originPlatform: content['platform'] as String?,
          originUrl: content['url'] as String?,
          originShortcode: shortcode,
        ),
      ],
      cooks: const [],
    );

    await _repository.upsertDish(dish);
    return dish;
  }

  static ImportStage _stage(String? state) => switch (state) {
        'ready' => ImportStage.ready,
        'failed' => ImportStage.failed,
        'extracting' => ImportStage.extracting,
        _ => ImportStage.queued,
      };

  /// `step_ingredients` is parallel to `steps`: each entry is a list of indices
  /// into `ingredients`, or null for a parse that predates it.
  ///
  /// Anything that is not a list of numbers is dropped rather than repaired:
  /// a half-understood link would put the wrong ingredient under a step.
  static List<List<int>>? _stepLinks(Object? raw) {
    if (raw is! List) return null;
    return [
      for (final entry in raw)
        if (entry is List)
          [for (final index in entry) if (index is num) index.toInt()]
        else
          const <int>[],
    ];
  }
}

class ImportStart {
  const ImportStart({
    required this.jobId,
    required this.shortcode,
    required this.stage,
    required this.cached,
    this.reason,
  });

  final String? jobId;
  final String shortcode;
  final ImportStage stage;
  final bool cached;
  final String? reason;
}

class ImportProgress {
  const ImportProgress({
    required this.stage,
    this.detail,
    this.reason,
    required this.shortcode,
    this.title,
  });

  final ImportStage stage;
  final String? detail;
  final String? reason;
  final String shortcode;

  /// The reel's own name, when the server has one. Null until it does.
  final String? title;

  String get label => switch (detail) {
        // The worker VM sleeps when idle; the first import after a pause waits
        // for it to boot. It is a stage, not a failure.
        'starting' => 'Waking the kitchen…',
        _ => switch (stage) {
            ImportStage.queued => 'Queued',
            ImportStage.extracting => switch (detail) {
                'transcribing' => 'Reading the audio',
                'structuring' => 'Writing the recipe',
                'watching' => 'Watching the video',
                'caption_only' => 'Reading the caption',
                _ => 'Reading the reel',
              },
            ImportStage.ready => 'Ready',
            ImportStage.failed => 'Could not read this one',
          },
      };

  /// The second line, when the wait needs explaining rather than filling.
  String? get waitingHint => detail == 'starting'
      ? 'The first one after a pause takes a minute'
      : null;
}

/// What a failure reason becomes on screen.
///
/// Every reason the contract lists has words, and `timed_out` — the client's own
/// reason for "I stopped waiting" — is not the same event as the server's
/// `timeout`. Falling through to the generic line hides the one thing the user
/// can do about it.
String importReasonText(String? reason) => switch (reason) {
      'unsupported_url' => 'That link is not a reel or video we can read',
      'source_blocked' =>
        'YouTube is blocking our server right now — try again later or paste the recipe',
      'timeout' => 'That took too long — try again',
      'worker_unavailable' =>
        'The kitchen did not wake up — try again in a minute',
      'timed_out' =>
        'Still reading — this can take a few minutes. You can leave this and the dish will be here when it is ready',
      'gone' => 'That import is no longer on the server — try the link again',
      'invalid_recipe' => 'We could not find a recipe in that one',
      'no_audio' => 'That video has nothing to listen to',
      'no_text' => 'That reel has no caption and no speech we could read',
      'no_recipe' => 'That video does not show a recipe',
      'vision_failed' => 'We could not read that video — paste the recipe instead',
      'taken_down' => 'That recipe was removed',
      null => 'Could not read this one — paste the recipe instead',
      _ => 'Could not read this one — paste the recipe instead',
    };
