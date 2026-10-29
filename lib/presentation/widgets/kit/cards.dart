import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/mock_data.dart';
import 'foundation.dart';

/// Dashed rule used by the kitchen-ticket card.
class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 1,
        width: double.infinity,
        child: CustomPaint(painter: _DashPainter(color)),
      );
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 5.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset((x + dash).clamp(0, size.width), 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.color != color;
}

/// Split-stub recipe card: content above, mono metadata stub below a dashed
/// perforation. The signature element of the design language.
class ShokuTicketCard extends StatelessWidget {
  final SavedItem item;
  final VoidCallback? onTap;

  const ShokuTicketCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ShokuSurface(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ShokuSpace.md,
              ShokuSpace.md,
              ShokuSpace.md,
              ShokuSpace.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShokuChip(
                      item.sourceLabel,
                      icon: item.source == ItemSource.instagram
                          ? Icons.camera_alt_outlined
                          : Icons.play_circle_outline,
                    ),
                    const SizedBox(width: ShokuSpace.xs),
                    ShokuChip(item.duration),
                    const Spacer(),
                    Text(
                      '${item.minutesAgo}m',
                      style: ShokuType.label.copyWith(color: c.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: ShokuSpace.sm),
                Text(item.title, style: ShokuType.h2.copyWith(color: c.ink)),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md),
            child: _DashedLine(color: c.hairline),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ShokuSpace.md,
              vertical: ShokuSpace.sm,
            ),
            child: Row(
              children: [
                _StubCell(
                  label: 'pantry',
                  child: Row(
                    children: [
                      ShokuPantryTicks(have: item.pantryHave, need: item.pantryNeed),
                      const SizedBox(width: 5),
                      Text(
                        '${item.pantryHave}/${item.pantryNeed}',
                        style: ShokuType.stat.copyWith(
                          fontSize: 12,
                          color: item.pantryHave >= item.pantryNeed && item.pantryNeed > 0
                              ? c.ready
                              : c.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _StubCell(
                  label: 'xp',
                  child: Text(
                    '+${item.xp}',
                    style: ShokuType.stat.copyWith(fontSize: 12, color: c.reward),
                  ),
                ),
                _StubCell(
                  label: item.progressTotal != null ? 'steps' : 'kind',
                  child: Text(
                    item.progressTotal != null
                        ? '${item.progressDone}/${item.progressTotal}'
                        : 'note',
                    style: ShokuType.stat.copyWith(fontSize: 12, color: c.ink),
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

class _StubCell extends StatelessWidget {
  final String label;
  final Widget child;
  const _StubCell({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: ShokuType.label.copyWith(color: c.inkMuted)),
          const SizedBox(height: 3),
          child,
        ],
      ),
    );
  }
}

/// Index-card treatment for saved notes: no photo, saffron double rule.
class ShokuWisdomCard extends StatelessWidget {
  final SavedItem item;
  final int index;
  final VoidCallback? onTap;

  const ShokuWisdomCard({
    super.key,
    required this.item,
    this.index = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuSurface(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 2, color: c.reward),
          Container(height: 1, color: c.reward.withValues(alpha: 0.35)),
          Padding(
            padding: const EdgeInsets.all(ShokuSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShokuLabel(
                      'note // ${index.toString().padLeft(3, '0')}',
                      color: c.reward,
                    ),
                    const Spacer(),
                    ShokuChip(item.sourceLabel, icon: Icons.link),
                  ],
                ),
                const SizedBox(height: ShokuSpace.sm),
                Text(
                  item.title,
                  style: ShokuType.quote.copyWith(color: c.ink),
                ),
                const SizedBox(height: ShokuSpace.sm),
                Row(
                  children: [
                    Text(
                      item.sourceHandle,
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                    ),
                    const Spacer(),
                    Text(
                      '+${item.xp} xp',
                      style: ShokuType.stat.copyWith(fontSize: 12, color: c.reward),
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

class ShokuCollectionCard extends StatelessWidget {
  final StashCollection collection;
  final VoidCallback? onTap;

  const ShokuCollectionCard({super.key, required this.collection, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuSurface(
      onTap: onTap,
      color: c.surfaceAlt,
      padding: const EdgeInsets.all(ShokuSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(collection.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: ShokuSpace.sm),
          Text(
            collection.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            '${collection.count} saved',
            style: ShokuType.label.copyWith(color: c.inkMuted),
          ),
        ],
      ),
    );
  }
}
