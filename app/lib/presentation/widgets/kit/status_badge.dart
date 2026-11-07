import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';

/// Status has to be readable over a photograph, not just on paper, so the badge
/// is filled, larger than a hairline chip, and always in the same corner.
class StatusBadge extends StatelessWidget {
  final DishStatus status;
  final int cookCount;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.cookCount = 0,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;

    final (Color bg, Color fg, IconData icon, String text) = switch (status) {
      DishStatus.toCook => (
          c.reward,
          c.canvas,
          Icons.schedule,
          l10n.badgeToCook
        ),
      DishStatus.cooked => (
          c.ready,
          c.canvas,
          Icons.check,
          cookCount > 0 ? l10n.badgeCookedCount(cookCount) : l10n.badgeCooked
        ),
      DishStatus.signature => (
          c.ink,
          c.canvas,
          Icons.star_rounded,
          l10n.badgeSignature
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(ShokuRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 9 : 11, color: fg),
          SizedBox(width: compact ? 3 : 4),
          Text(
            text,
            style: ShokuType.label.copyWith(
              fontSize: compact ? 8 : 9,
              color: fg,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// The two-state control at the top of the Cookbook. Big, counted, and the
/// default landing state is whatever you still have to cook.
class StatusToggle extends StatelessWidget {
  final int toCookCount;
  final int cookedCount;
  final bool showingToCook;
  final ValueChanged<bool> onChanged;

  const StatusToggle({
    super.key,
    required this.toCookCount,
    required this.cookedCount,
    required this.showingToCook,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;

    Widget side({
      required bool active,
      required String label,
      required int count,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: active ? c.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(ShokuRadius.chip - 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 15, color: active ? c.canvas : c.inkMuted),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: ShokuType.title.copyWith(
                    fontSize: 13,
                    color: active ? c.canvas : c.inkMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: active
                        ? c.canvas.withValues(alpha: 0.18)
                        : c.surfaceAlt,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$count',
                    style: ShokuType.stat.copyWith(
                      fontSize: 10,
                      color: active ? c.canvas : c.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.chip),
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        children: [
          side(
            active: showingToCook,
            label: l10n.cookbookToCook,
            count: toCookCount,
            icon: Icons.schedule,
            onTap: () => onChanged(true),
          ),
          side(
            active: !showingToCook,
            label: l10n.cookbookCooked,
            count: cookedCount,
            icon: Icons.check_circle_outline,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}
