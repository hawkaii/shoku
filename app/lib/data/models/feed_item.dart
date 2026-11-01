/// One reel somebody chose to put on the Wall.
///
/// It carries nothing from anyone's journal: no cook counts, no edits, no
/// ratings. What is shared is the extraction — the reading of a public reel —
/// never the user's work on it.
class FeedItem {
  const FeedItem({
    required this.shortcode,
    required this.title,
    required this.thumbnailUrl,
    required this.creator,
    required this.creatorHandle,
    required this.platform,
    required this.steps,
    required this.tags,
    required this.url,
  });

  final String shortcode;
  final String title;
  final String thumbnailUrl;
  final String? creator;
  final String? creatorHandle;
  final String? platform;
  final List<String> steps;
  final List<String> tags;
  final String? url;

  static FeedItem? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final shortcode = raw['shortcode'];
    if (shortcode is! String || shortcode.isEmpty) return null;
    return FeedItem(
      shortcode: shortcode,
      title: (raw['title'] as String?)?.trim().isNotEmpty == true
          ? raw['title'] as String
          : 'Untitled reel',
      thumbnailUrl: raw['thumbnail_url'] as String? ?? '',
      creator: raw['creator'] as String?,
      creatorHandle: raw['creator_handle'] as String?,
      platform: raw['platform'] as String?,
      steps: [
        for (final step in (raw['steps'] as List? ?? const [])) step.toString(),
      ],
      tags: [
        for (final tag in (raw['tags'] as List? ?? const [])) tag.toString(),
      ],
      url: raw['url'] as String?,
    );
  }

  /// `creator · platform`, with whatever is missing left out rather than filled
  /// in with a guess.
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
