
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

  /// The extraction's own tags. `from video` means the reel was silent and the
  /// amounts are guesses — the dish says so out loud.
  final List<String> tags;

  /// Which ingredients the extractor says each step uses: parallel to [steps],
  /// each entry a list of indices into [ingredients].
  ///
  /// Null means the parse predates the link (or arrived through sync, which does
  /// not carry it). Null renders nothing — the app never guesses which
  /// ingredient a step meant, because a guessed quantity is the app lying about
  /// a recipe.
  final List<List<int>>? stepIngredients;

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
    this.stepIngredients,
    this.tags = const [],
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

  /// The ingredient indices the extractor linked to [stepIndex], or null when
  /// this parse has no links (or none for that step).
  List<int>? stepIngredientLinks(int stepIndex) {
    final links = stepIngredients;
    if (links == null || stepIndex < 0 || stepIndex >= links.length) return null;
    return links[stepIndex];
  }
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

  /// The object key the API owns, for the sync wire. Empty when the photo never
  /// left the phone.
  final String photoKey;

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
    this.photoKey = '',
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

  /// The bundled sample: a local-only dish that leaves on the first sign-in.
  bool get isSample => id.startsWith('sample-');

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

class JournalData {
  /// The demo kitchen's dish ids. The app no longer ships demo recipes; these
  /// are kept only so an install that already has them can lose them once.
  static const List<String> demoDishIds = ['mousse', 'chicken', 'focaccia', 'noodles'];

  const JournalData._();
}
