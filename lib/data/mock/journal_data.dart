import 'package:flutter/material.dart';

/// The journal model: a Dish you cook repeatedly, each attempt a version,
/// each night a cook log. This is the whole product.
enum DishStatus {
  toCook,
  cooked,
  signature;

  String get label => switch (this) {
        DishStatus.toCook => 'TO COOK',
        DishStatus.cooked => 'COOKED',
        DishStatus.signature => 'SIGNATURE',
      };
}

enum CookOutcome {
  needsWork,
  good,
  nailedIt;

  String get label => switch (this) {
        CookOutcome.nailedIt => 'Nailed it',
        CookOutcome.good => 'Good',
        CookOutcome.needsWork => 'Needs work',
      };

  String get upper => switch (this) {
        CookOutcome.nailedIt => 'NAILED IT',
        CookOutcome.good => 'GOOD',
        CookOutcome.needsWork => 'NEEDS WORK',
      };
}

class RecipeVersion {
  /// Client-generated UUID. Empty on rows built from seed/mock data; the
  /// repository assigns one the first time the row is written.
  final String id;
  final int number;
  final List<String> changes;
  final List<String> ingredients;
  final DateTime createdAt;
  final List<String> steps;
  final int kcal;
  final int protein;

  /// `mine` or `import`. An import is an immutable snapshot of someone else's
  /// reel; editing it forks a `mine` version rather than mutating the original.
  final String originKind;
  final String? originCreator;
  final String? originHandle;
  final String? originPlatform;
  final String? originUrl;
  final String? originShortcode;
  final String? parentVersionId;

  const RecipeVersion({
    this.id = '',
    required this.number,
    required this.changes,
    required this.ingredients,
    required this.createdAt,
    this.steps = const [],
    this.kcal = 0,
    this.protein = 0,
    this.originKind = 'mine',
    this.originCreator,
    this.originHandle,
    this.originPlatform,
    this.originUrl,
    this.originShortcode,
    this.parentVersionId,
  });

  bool get isImport => originKind == 'import';
}

/// What mood a cook belonged to — captured at debrief, never inferred.
enum CookMood { quick, project, comfort }

class CookLog {
  final String id;
  final DateTime cookedAt;
  final int versionNumber;

  /// Which version was actually cooked. Cooks are tied to a version by id, not
  /// by ordinal, so renumbering a lineage can't mis-attribute a photo.
  final String? versionId;
  final String photoUrl;

  /// `none` | `local` | `synced`. Sync uses this to decide what still needs
  /// uploading; a local file path is not a remote URL.
  final String photoState;
  final CookOutcome outcome;
  final String note;
  final List<String> changes;
  final CookMood mood;
  final int rating;

  const CookLog({
    required this.id,
    required this.cookedAt,
    required this.versionNumber,
    this.versionId,
    this.photoState = '',
    required this.photoUrl,
    required this.outcome,
    required this.note,
    required this.changes,
    this.mood = CookMood.comfort,
    this.rating = 3,
  });
}

class Dish {
  final String id;
  final String title;
  final String subtitle;
  final String coverUrl;
  final String sourceHandle;
  final DishStatus status;
  final List<RecipeVersion> versions;
  final List<CookLog> cooks;
  final int minutes;
  final int baselineKcal;
  final int baselineProtein;
  final List<String> steps;

  const Dish({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coverUrl,
    required this.sourceHandle,
    required this.status,
    required this.versions,
    required this.cooks,
    required this.minutes,
    this.baselineKcal = 0,
    this.baselineProtein = 0,
    this.steps = const [],
  });

  Dish copyWith({
    String? title,
    String? subtitle,
    String? coverUrl,
    DishStatus? status,
    List<RecipeVersion>? versions,
    List<CookLog>? cooks,
  }) =>
      Dish(
        id: id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        coverUrl: coverUrl ?? this.coverUrl,
        sourceHandle: sourceHandle,
        status: status ?? this.status,
        versions: versions ?? this.versions,
        cooks: cooks ?? this.cooks,
        minutes: minutes,
        baselineKcal: baselineKcal,
        baselineProtein: baselineProtein,
        steps: steps,
      );

  int get cookCount => cooks.length;
  int get currentVersion => versions.length;
  CookLog? get lastCook => cooks.isEmpty ? null : cooks.first;
  bool get hasPhoto => coverUrl.isNotEmpty;

  String get outcomeLabel => switch (lastCook?.outcome) {
        CookOutcome.nailedIt => 'Nailed it',
        CookOutcome.good => 'Good',
        CookOutcome.needsWork => 'Needs work',
        null => 'Not cooked yet',
      };
}

const _u = 'https://images.unsplash.com/';
const _q = '?auto=format&fit=crop&w=900&q=70';

class JournalData {
  /// The demo kitchen's dish ids. The app no longer ships demo recipes; these
  /// are kept only so an install that already has them can lose them once.
  static const List<String> demoDishIds = ['mousse', 'chicken', 'focaccia', 'noodles'];

  const JournalData._();
}
