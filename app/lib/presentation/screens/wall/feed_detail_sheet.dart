import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/shoku_text.dart';
import '../../../data/models/feed_item.dart';
import '../../../data/models/recipe_content.dart';
import '../../state/feed_providers.dart';
import '../../state/import_providers.dart';
import '../../state/journal_store.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';

/// Open one reel from the Wall and read it before deciding.
///
/// The same sheet pattern as the rest of the app — no new navigation. What it
/// shows is the extraction and only the extraction: there is no dish behind a
/// Wall card, so there is no version, rating or note to leak in. If you add it
/// to your cookbook, that is a copy on your side, not a view into this one.
Future<void> showFeedDetail(BuildContext context, FeedItem item) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.92,
      child: FeedDetailSheet(item: item),
    ),
  );
}

class FeedDetailSheet extends ConsumerStatefulWidget {
  const FeedDetailSheet({super.key, required this.item});

  final FeedItem item;

  @override
  ConsumerState<FeedDetailSheet> createState() => _FeedDetailSheetState();
}

class _FeedDetailSheetState extends ConsumerState<FeedDetailSheet> {
  RecipeContent? _content;
  bool _failed = false;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _failed = false;
      _content = null;
    });
    try {
      final content =
          await ref.read(importServiceProvider).fetchContent(widget.item.shortcode);
      if (!mounted) return;
      setState(() => _content = content);
      if (content == null) setState(() => _failed = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  Future<void> _addToCookbook() async {
    if (_adding) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _adding = true);
    try {
      // The cached extraction, never the import queue.
      final dish =
          await ref.read(importServiceProvider).createDish(widget.item.shortcode);
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

  Future<void> _openReel() async {
    final raw = _content?.url ?? widget.item.url;
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final imported =
        ref.watch(importedShortcodesProvider).contains(widget.item.shortcode);
    final content = _content;

    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grab handle, so this reads as the sheet it is.
          Padding(
            padding: const EdgeInsets.only(top: ShokuSpace.sm),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                ShokuSpace.lg,
                ShokuSpace.md,
                ShokuSpace.lg,
                ShokuSpace.lg,
              ),
              children: [
                SizedBox(
                  height: 170,
                  child: ShokuDishImage(
                    url: content?.thumbnailUrl ?? widget.item.thumbnailUrl,
                    title: content?.title ?? widget.item.title,
                    radius: ShokuRadius.card,
                  ),
                ),
                const SizedBox(height: ShokuSpace.md),
                Text(
                  content?.title ?? widget.item.title,
                  key: const ValueKey('feed-detail-title'),
                  style: ShokuType.h1.copyWith(color: c.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  content?.byline ?? widget.item.byline,
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: ShokuSpace.sm),

                if (_failed)
                  _QuietFailure(onRetry: _load)
                else if (content == null)
                  _QuietLoading()
                else ...[
                  Text(
                    metaLine([
                      if (content.minutes > 0) '${content.minutes} min',
                      count(content.ingredients.length, 'ingredient'),
                      count(content.steps.length, 'step'),
                    ]),
                    key: const ValueKey('feed-detail-meta'),
                    style: ShokuType.label.copyWith(color: c.inkMuted),
                  ),
                  if (content.tags.isNotEmpty) ...[
                    const SizedBox(height: ShokuSpace.sm),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final tag in content.tags)
                          _Tag(text: tag),
                      ],
                    ),
                  ],
                  const SizedBox(height: ShokuSpace.lg),
                  const ShokuLabel('method'),
                  const SizedBox(height: ShokuSpace.sm),
                  for (var i = 0; i < content.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: ShokuSpace.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 22,
                            child: Text(
                              '${i + 1}',
                              style:
                                  ShokuType.label.copyWith(color: c.inkMuted),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              content.steps[i],
                              style: ShokuType.body.copyWith(color: c.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: ShokuSpace.md),
                Row(
                  children: [
                    Expanded(
                      child: ShokuPressable(
                        key: const ValueKey('feed-detail-open'),
                        onTap: _openReel,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(ShokuRadius.chip),
                            border: Border.all(color: c.hairline),
                          ),
                          child: Center(
                            child: Text(
                              'View the reel',
                              style: ShokuType.title
                                  .copyWith(color: c.ink, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: ShokuSpace.sm),
                    Expanded(
                      flex: 2,
                      child: imported
                          ? Container(
                              key: const ValueKey('feed-detail-imported'),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: c.surfaceAlt,
                                borderRadius:
                                    BorderRadius.circular(ShokuRadius.chip),
                                border: Border.all(color: c.hairline),
                              ),
                              child: Center(
                                child: Text(
                                  'In your cookbook',
                                  style: ShokuType.label.copyWith(
                                    color: c.inkMuted,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            )
                          : ShokuPressable(
                              key: const ValueKey('feed-detail-add'),
                              onTap: _adding || content == null
                                  ? null
                                  : _addToCookbook,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: _adding || content == null
                                      ? null
                                      : ShokuGradients.crimsonPress,
                                  color: _adding || content == null
                                      ? c.surfaceAlt
                                      : null,
                                  borderRadius:
                                      BorderRadius.circular(ShokuRadius.chip),
                                  border: Border.all(
                                      color: c.ink,
                                      width: ShokuStroke.brutal),
                                ),
                                child: Center(
                                  child: Text(
                                    _adding
                                        ? 'Saving…'
                                        : 'Add to cookbook',
                                    style: ShokuType.title.copyWith(
                                      color: _adding || content == null
                                          ? c.inkMuted
                                          : c.onAccent,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuietLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ShokuSpace.lg),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 1.6, color: c.accent),
          ),
          const SizedBox(width: ShokuSpace.sm),
          Text(
            'Reading the reel',
            key: const ValueKey('feed-detail-loading'),
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
        ],
      ),
    );
  }
}

/// Quiet on purpose: a reel that will not load is not a dialog moment.
class _QuietFailure extends StatelessWidget {
  const _QuietFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ShokuSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This reel did not load',
            key: const ValueKey('feed-detail-failed'),
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text('Try again',
                style: ShokuType.label.copyWith(color: c.ink)),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ShokuRadius.chip),
        border: Border.all(color: c.hairline),
      ),
      child: Text(
        text,
        style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted),
      ),
    );
  }
}
