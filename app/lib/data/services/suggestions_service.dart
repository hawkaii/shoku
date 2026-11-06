import '../../core/utils/failure_log.dart';
import '../models/feed_item.dart';
import 'api_client.dart';

/// One Wall reel scored against this pantry.
///
/// The server matches names only — quantities never leave the phone. Until the
/// endpoint is deployed the shelf is simply empty, not broken.
class FeedSuggestion {
  const FeedSuggestion({
    required this.shortcode,
    required this.title,
    required this.thumbnailUrl,
    required this.creator,
    required this.platform,
    required this.ingredients,
    required this.have,
    required this.total,
    required this.missing,
  });

  final String shortcode;
  final String title;
  final String thumbnailUrl;
  final String? creator;
  final String? platform;
  final List<String> ingredients;
  final int have;
  final int total;
  final List<String> missing;

  String get scoreLabel => '$have of $total';

  FeedItem get asFeedItem => FeedItem(
        shortcode: shortcode,
        title: title,
        thumbnailUrl: thumbnailUrl,
        creator: creator,
        creatorHandle: null,
        platform: platform,
        steps: const [],
        tags: const [],
        url: null,
      );

  static FeedSuggestion? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final shortcode = raw['shortcode'];
    if (shortcode is! String || shortcode.isEmpty) return null;
    final m = raw['match'] is Map ? raw['match'] as Map : const {};
    return FeedSuggestion(
      shortcode: shortcode,
      title: (raw['title'] as String?) ?? 'Untitled reel',
      thumbnailUrl: (raw['thumbnail_url'] as String?) ?? '',
      creator: raw['creator'] as String?,
      platform: raw['platform'] as String?,
      ingredients: [
        for (final line in (raw['ingredients'] as List? ?? const []))
          line.toString(),
      ],
      have: (m['have'] as num?)?.toInt() ?? 0,
      total: (m['total'] as num?)?.toInt() ?? 0,
      missing: [
        for (final line in (m['missing'] as List? ?? const [])) line.toString(),
      ],
    );
  }
}

/// `/v1/feed/suggestions`: what the Wall can cook with what is on the shelf.
class SuggestionsService {
  SuggestionsService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<List<FeedSuggestion>> fetch({int limit = 6}) async {
    try {
      final data = await _api.get('/v1/feed/suggestions?limit=$limit');
      return [
        for (final raw in (data['items'] as List? ?? const []))
          if (FeedSuggestion.fromJson(raw) case final suggestion?) suggestion,
      ];
    } catch (error, stack) {
      // Not deployed yet, or offline: the shelf shows its empty state, and the
      // line says which of the two it was.
      logFailure('feed suggestions', error, stack);
      return const [];
    }
  }
}
