import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/feed_item.dart';
import '../../data/services/api_client.dart';
import '../../data/services/feed_service.dart';
import 'published_store.dart';
import 'sync_providers.dart';

/// The Wall's state. Read-only, quietly failing, and never in the way of the
/// journal: a feed that will not load is a muted line with a retry, not a dialog.
class FeedState {
  const FeedState({
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.loading = false,
    this.loadingMore = false,
    this.failed = false,
  });

  final List<FeedItem> items;
  final String? cursor;
  final bool hasMore;

  /// The first page is in flight (or the store is refreshing).
  final bool loading;

  /// A further page is in flight.
  final bool loadingMore;

  /// The last attempt failed. Distinct from "empty", which is a normal state.
  final bool failed;

  FeedState copyWith({
    List<FeedItem>? items,
    String? cursor,
    bool clearCursor = false,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    bool? failed,
  }) =>
      FeedState(
        items: items ?? this.items,
        cursor: clearCursor ? null : (cursor ?? this.cursor),
        hasMore: hasMore ?? this.hasMore,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        failed: failed ?? this.failed,
      );
}

class FeedStore extends StateNotifier<FeedState> {
  FeedStore(this._service) : super(const FeedState()) {
    load();
  }

  final FeedService _service;

  /// Fetches the first page, replacing whatever is on screen.
  Future<void> load({bool quiet = false}) async {
    if (state.loading) return;
    state = state.copyWith(loading: !quiet, failed: false);
    try {
      final page = await _service.page();
      state = FeedState(
        items: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
    } catch (_) {
      state = state.copyWith(loading: false, failed: true);
    }
  }

  /// Pull to refresh. Same as a first load, without the "Opening" state.
  Future<void> refresh() async {
    state = const FeedState();
    await load(quiet: true);
  }

  /// The next page. Never called twice at once.
  Future<void> more() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    if (state.cursor == null) return;
    state = state.copyWith(loadingMore: true, failed: false);
    try {
      final page = await _service.page(cursor: state.cursor);
      state = state.copyWith(
        items: [...state.items, ...page.items],
        cursor: page.cursor,
        hasMore: page.hasMore,
        loadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(loadingMore: false, failed: true);
    }
  }
}

final feedServiceProvider = Provider<FeedService>(
  (ref) => FeedService(api: ApiClient(auth: ref.watch(authServiceProvider))),
);

final feedStoreProvider = StateNotifierProvider<FeedStore, FeedState>(
  (ref) => FeedStore(ref.watch(feedServiceProvider)),
);

final publishedShortcodesProvider =
    StateNotifierProvider<PublishedStore, Set<String>>(
  (ref) => PublishedStore(),
);
