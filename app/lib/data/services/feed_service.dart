import '../models/feed_item.dart';
import 'api_client.dart';

class FeedPage {
  const FeedPage({required this.items, this.cursor, required this.hasMore});

  final List<FeedItem> items;
  final String? cursor;
  final bool hasMore;
}

/// The Wall's only door to the API: the feed, and sharing one reel.
class FeedService {
  FeedService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// Report a card. Distinct people only; enough of them hide it for everyone.
  Future<void> report(String shortcode) async {
    await _api.post('/v1/content/$shortcode/report', const {});
  }

  Future<FeedPage> page({String? cursor, int limit = 20}) async {
    final query = Uri(queryParameters: {
      'limit': '$limit',
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    }).query;
    final data = await _api.get('/v1/feed?$query');

    return FeedPage(
      items: [
        for (final raw in (data['items'] as List? ?? const []))
          if (FeedItem.fromJson(raw) case final item?) item,
      ],
      cursor: data['cursor'] as String?,
      hasMore: data['has_more'] == true,
    );
  }
}
