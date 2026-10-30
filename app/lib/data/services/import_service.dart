import 'dart:async';

import '../db/journal_repository.dart';
import '../mock/journal_data.dart';
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
    );
  }

  Future<ImportProgress> poll(String jobId) async {
    final response = await _api.get('/v1/imports/$jobId');
    return ImportProgress(
      stage: _stage(response['state'] as String?),
      detail: response['progress_stage'] as String?,
      reason: response['reason'] as String?,
      shortcode: response['shortcode'] as String? ?? '',
    );
  }

  /// Polls until the job settles. Bounded by a deadline so a stuck worker can't
  /// leave the sheet spinning forever.
  Stream<ImportProgress> watch(String jobId, {int seconds = 120}) async* {
    final deadline = DateTime.now().add(Duration(seconds: seconds));
    var delay = const Duration(seconds: 1);
    while (DateTime.now().isBefore(deadline)) {
      final progress = await poll(jobId);
      yield progress;
      if (progress.stage == ImportStage.ready || progress.stage == ImportStage.failed) {
        return;
      }
      await Future<void>.delayed(delay);
      // Ease off: 1s, 2s, 4s, then every 5s.
      delay = Duration(seconds: delay.inSeconds >= 5 ? 5 : delay.inSeconds * 2);
    }
    yield const ImportProgress(stage: ImportStage.failed, reason: 'timed_out', shortcode: '');
  }

  /// Turns a cached extraction into a dish in the journal, with the creator
  /// attached to the version. Imports land as `To cook`.
  Future<Dish?> createDish(String shortcode) async {
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
      coverUrl: '',
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
          kcal: (recipe['kcal'] as num?)?.toInt() ?? 0,
          protein: (recipe['protein'] as num?)?.toInt() ?? 0,
          originKind: 'import',
          originCreator: content['creator'] as String?,
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
}

class ImportStart {
  const ImportStart({
    required this.jobId,
    required this.shortcode,
    required this.stage,
    required this.cached,
  });

  final String? jobId;
  final String shortcode;
  final ImportStage stage;
  final bool cached;
}

class ImportProgress {
  const ImportProgress({
    required this.stage,
    this.detail,
    this.reason,
    required this.shortcode,
  });

  final ImportStage stage;
  final String? detail;
  final String? reason;
  final String shortcode;

  String get label => switch (stage) {
        ImportStage.queued => 'Queued',
        ImportStage.extracting => switch (detail) {
            'transcribing' => 'Reading the audio',
            'structuring' => 'Writing the recipe',
            'caption_only' => 'Reading the caption',
            _ => 'Reading the reel',
          },
        ImportStage.ready => 'Ready',
        ImportStage.failed => 'Could not read this one',
      };
}
