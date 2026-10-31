import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/shoku_text.dart';
import '../../../data/models/feed_item.dart';
import '../../state/feed_providers.dart';
import '../../state/import_providers.dart';
import '../../state/journal_store.dart';
import '../add/import_sheet.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/plate_mark.dart';

/// The Wall: reels other people chose to share, ready to read and cook.
///
/// It is a discovery surface, not a record of anybody's cooking — that is the
/// Journal. Nothing here belongs to a person: the feed carries the extraction
/// and the creator, never a user id or a cook count.
class WallScreen extends ConsumerStatefulWidget {
  const WallScreen({super.key});

  @override
  ConsumerState<WallScreen> createState() => _WallScreenState();
}

class _WallScreenState extends ConsumerState<WallScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll.removeListener(_maybeLoadMore);
    _scroll.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.extentAfter > 320) return;
    ref.read(feedStoreProvider.notifier).more();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final feed = ref.watch(feedStoreProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: c.accent,
        onRefresh: () => ref.read(feedStoreProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                ShokuSpace.lg,
                ShokuSpace.sm,
                ShokuSpace.lg,
                ShokuSpace.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wall', style: ShokuType.h1.copyWith(color: c.ink)),
                        const SizedBox(height: 2),
                        Text(
                          feed.items.isEmpty
                              ? 'Reels people chose to share'
                              : count(feed.items.length, 'reel') +
                                  (feed.hasMore ? ' · more below' : ''),
                          style:
                              ShokuType.bodySmall.copyWith(color: c.inkMuted),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const ShokuChip('shared', icon: Icons.public),
                  ],
                ),
              ),
            ),
            if (feed.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyWall(
                  failed: feed.failed,
                  loading: feed.loading,
                  onRetry: () => ref.read(feedStoreProvider.notifier).load(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  ShokuSpace.lg,
                  0,
                  ShokuSpace.lg,
                  ShokuSpace.xl,
                ),
                sliver: SliverList.builder(
                  itemCount: feed.items.length + 1,
                  itemBuilder: (context, i) {
                    if (i == feed.items.length) {
                      return _FeedFooter(
                        loading: feed.loadingMore,
                        failed: feed.failed,
                        hasMore: feed.hasMore,
                        onMore: () => ref.read(feedStoreProvider.notifier).more(),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: ShokuSpace.md),
                      child: ShokuEntrance(
                        index: i,
                        child: FeedCard(item: feed.items[i]),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FeedCard extends ConsumerStatefulWidget {
  const FeedCard({super.key, required this.item});

  final FeedItem item;

  @override
  ConsumerState<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends ConsumerState<FeedCard> {
  bool _adding = false;

  /// Takes the cached extraction and writes a dish.
  ///
  /// Deliberately not an import: the reel is already parsed, so entering the
  /// queue would duplicate the dish and spend a worker on work that is done.
  Future<void> _addToCookbook() async {
    if (_adding) return;
    setState(() => _adding = true);
    final service = ref.read(importServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final dish = await service.createDish(widget.item.shortcode);
      await ref.read(journalStoreProvider.notifier).refresh();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(dish == null
            ? 'That reel is no longer on the server'
            : 'Saved ${dish.title} to your cookbook'),
      ));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not reach the server')),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final item = widget.item;

    return Container(
      padding: const EdgeInsets.all(ShokuSpace.sm),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.card),
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: ShokuDishImage(
              url: item.thumbnailUrl,
              title: item.title,
              radius: ShokuRadius.media,
            ),
          ),
          const SizedBox(width: ShokuSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  item.byline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  count(item.steps.length, 'step'),
                  style: ShokuType.label.copyWith(
                    fontSize: 9,
                    color: c.inkMuted,
                    letterSpacing: 0.6,
                  ),
                ),
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final tag in item.tags.take(3))
                        ShokuChip(tag, color: c.inkMuted),
                    ],
                  ),
                ],
                const SizedBox(height: ShokuSpace.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ShokuPressable(
                    key: const ValueKey('feed-add-to-cookbook'),
                    onTap: _adding ? null : _addToCookbook,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: c.surfaceAlt,
                        borderRadius: BorderRadius.circular(ShokuRadius.chip),
                        border: Border.all(color: c.hairline),
                      ),
                      child: Text(
                        _adding ? 'Saving…' : 'Add to cookbook',
                        style: ShokuType.label.copyWith(
                          fontSize: 9.5,
                          color: c.ink,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty is normal: the Wall shows what has been imported, and nothing has.
class _EmptyWall extends StatelessWidget {
  const _EmptyWall({
    required this.failed,
    required this.loading,
    required this.onRetry,
  });

  final bool failed;
  final bool loading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (loading) {
      return Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 1.6, color: c.accent),
        ),
      );
    }

    if (failed) {
      // Quiet: a feed that will not load is not an error the user must dismiss.
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The Wall did not load',
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
            ),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again',
                  style: ShokuType.label.copyWith(color: c.ink)),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PlateMark(size: 110),
            const SizedBox(height: ShokuSpace.sm),
            Text(
              'Nothing has been imported yet',
              key: const ValueKey('wall-empty-title'),
              textAlign: TextAlign.center,
              style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              'Import a reel and it lands here, for everyone.',
              textAlign: TextAlign.center,
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
            ),
            const SizedBox(height: ShokuSpace.md),
            ShokuPressable(
              key: const ValueKey('wall-empty-import'),
              onTap: () => showImportSheet(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: c.surfaceAlt,
                  borderRadius: BorderRadius.circular(ShokuRadius.chip),
                  border: Border.all(color: c.ink),
                ),
                child: Text(
                  'Import a reel',
                  style: ShokuType.label.copyWith(
                    fontSize: 10,
                    color: c.ink,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedFooter extends StatelessWidget {
  const _FeedFooter({
    required this.loading,
    required this.failed,
    required this.hasMore,
    required this.onMore,
  });

  final bool loading;
  final bool failed;
  final bool hasMore;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: ShokuSpace.lg),
        child: Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 1.4, color: c.accent),
          ),
        ),
      );
    }
    if (failed && hasMore) {
      return Center(
        child: TextButton(
          onPressed: onMore,
          child: Text('Could not load more — try again',
              style: ShokuType.label.copyWith(color: c.inkMuted)),
        ),
      );
    }
    if (hasMore) {
      return Center(
        child: TextButton(
          onPressed: onMore,
          child: Text('More reels',
              style: ShokuType.label.copyWith(color: c.inkMuted)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ShokuSpace.lg),
      child: Center(
        child: Text(
          'That is everything shared today',
          style: ShokuType.label.copyWith(color: c.inkMuted),
        ),
      ),
    );
  }
}
