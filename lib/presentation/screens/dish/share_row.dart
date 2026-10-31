import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../state/feed_providers.dart';
import '../../widgets/kit/motion.dart';

/// Put this reel's extraction on the Wall — or take it back off.
///
/// Only ever shown for a dish whose version came from a reel: there is nothing
/// to publish without a shortcode, so there is no affordance either.
class ShareOnWallRow extends ConsumerStatefulWidget {
  const ShareOnWallRow({super.key, required this.shortcode});

  final String shortcode;

  @override
  ConsumerState<ShareOnWallRow> createState() => _ShareOnWallRowState();
}

class _ShareOnWallRowState extends ConsumerState<ShareOnWallRow> {
  bool _busy = false;

  Future<void> _publish() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final c = context.colors;
        return Dialog(
          backgroundColor: c.canvas,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShokuRadius.card),
            side: BorderSide(color: c.ink, width: ShokuStroke.brutal),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ShokuSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Put this reel on the Wall?',
                    style: ShokuType.h2.copyWith(color: c.ink)),
                const SizedBox(height: ShokuSpace.xs),
                Text(
                  // The consequence, named: who sees it, what they see, and
                  // that it is reversible.
                  'Visible to every Shoku user · you can remove it any time. '
                  'What is shared is the reel as Shoku read it — never your edits, '
                  'your versions or your cooks.',
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: ShokuSpace.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(ShokuRadius.chip),
                            side: BorderSide(color: c.hairline),
                          ),
                        ),
                        child: Text('Not now',
                            style: ShokuType.title
                                .copyWith(color: c.ink, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: ShokuSpace.sm),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          backgroundColor: c.ink,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(ShokuRadius.chip),
                          ),
                        ),
                        child: Text('Share it',
                            style: ShokuType.title
                                .copyWith(color: c.canvas, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true || !mounted) return;

    await _run(
      publish: true,
      done: 'On the Wall',
      failed: 'Could not share this reel',
    );
  }

  Future<void> _unpublish() => _run(
        publish: false,
        done: 'Removed from the Wall',
        failed: 'Could not remove it',
      );

  Future<void> _run({
    required bool publish,
    required String done,
    required String failed,
  }) async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    HapticFeedback.selectionClick();
    try {
      final service = ref.read(feedServiceProvider);
      if (publish) {
        await service.publish(widget.shortcode);
      } else {
        await service.unpublish(widget.shortcode);
      }
      await ref
          .read(publishedShortcodesProvider.notifier)
          .mark(widget.shortcode, published: publish);
      // The Wall should not need a reload to show what just changed.
      await ref.read(feedStoreProvider.notifier).refresh();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final published =
        ref.watch(publishedShortcodesProvider).contains(widget.shortcode);

    return Container(
      padding: const EdgeInsets.all(ShokuSpace.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.card),
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        children: [
          Icon(
            published ? Icons.public : Icons.ios_share,
            size: 18,
            color: published ? c.ready : c.ink,
          ),
          const SizedBox(width: ShokuSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  published ? 'On the Wall' : 'Share this reel on the Wall',
                  key: const ValueKey('share-wall-label'),
                  style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                ),
                Text(
                  published
                      ? 'Everyone can see the reel. Your edits stay yours.'
                      : 'The reel, not your version of it.',
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: ShokuSpace.sm),
          ShokuPressable(
            key: ValueKey(published ? 'unshare-wall' : 'share-wall'),
            onTap: _busy ? null : (published ? _unpublish : _publish),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.hairline),
              ),
              child: Text(
                _busy ? '…' : (published ? 'Remove' : 'Share'),
                style: ShokuType.label.copyWith(
                  fontSize: 9.5,
                  color: c.ink,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
