/// A reel as the server read it — the extraction, and nothing else.
///
/// Deliberately not a `Dish`: the Wall shows other people's reels, so there is
/// no place here for a cook count, a rating, a note or a version. If a field is
/// not in `GET /v1/content/{shortcode}`, it does not belong on this screen.
class RecipeContent {
  const RecipeContent({
    required this.shortcode,
    required this.title,
    required this.creator,
    required this.creatorHandle,
    required this.platform,
    required this.thumbnailUrl,
    required this.url,
    required this.steps,
    required this.ingredients,
    required this.tags,
    required this.minutes,
  });

  final String shortcode;
  final String title;
  final String? creator;
  final String? creatorHandle;
  final String? platform;
  final String thumbnailUrl;
  final String? url;
  final List<String> steps;
  final List<String> ingredients;
  final List<String> tags;
  final int minutes;

  static RecipeContent? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final recipe = raw['recipe'];
    if (recipe is! Map) return null;

    final shortcode = raw['shortcode'];
    return RecipeContent(
      shortcode: shortcode is String ? shortcode : '',
      title: (recipe['title'] as String?)?.trim().isNotEmpty == true
          ? recipe['title'] as String
          : 'Imported recipe',
      creator: raw['creator'] as String?,
      creatorHandle: raw['creator_handle'] as String?,
      platform: raw['platform'] as String?,
      thumbnailUrl: raw['thumbnail_url'] as String? ?? '',
      url: raw['url'] as String?,
      steps: [
        for (final step in (recipe['steps'] as List? ?? const []))
          step.toString(),
      ],
      ingredients: [
        for (final raw in (recipe['ingredients'] as List? ?? const []))
          if (raw is Map)
            [
              if ((raw['amount'] as String?)?.trim().isNotEmpty ?? false)
                raw['amount'],
              raw['name'],
            ].whereType<Object>().join(' ').trim(),
      ],
      tags: [
        for (final tag in (recipe['tags'] as List? ?? const [])) tag.toString(),
      ],
      minutes: (recipe['minutes'] as num?)?.toInt() ?? 0,
    );
  }

  /// `creator · platform`, leaving out whatever the extraction does not have.
  String get byline {
    final name = creator?.trim().isNotEmpty == true
        ? creator!.trim()
        : (creatorHandle?.trim().isNotEmpty == true
            ? creatorHandle!.trim()
            : null);
    final where = switch ((platform ?? '').toLowerCase()) {
      'instagram' => 'Instagram',
      'youtube' => 'YouTube',
      '' => null,
      _ => platform,
    };
    final parts = [if (name != null) name, if (where != null) where];
    return parts.isEmpty ? 'a Shoku cook' : parts.join(' · ');
  }
}
