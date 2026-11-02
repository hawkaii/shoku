import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import 'foundation.dart';

class ShokuEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ShokuEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: ShokuSpace.lg),
        padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xl, vertical: ShokuSpace.xxl),
        decoration: BoxDecoration(
          gradient: context.isDark ? ShokuGradients.emberCellar : ShokuGradients.warmVellum,
          borderRadius: BorderRadius.circular(ShokuRadius.card),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(ShokuRadius.card),
                border: Border.all(color: c.hairline, width: ShokuStroke.hairline),
              ),
              child: Icon(icon, color: c.inkMuted, size: 24),
            ),
            const SizedBox(height: ShokuSpace.lg),
            Text(title, textAlign: TextAlign.center, style: ShokuType.h1.copyWith(color: c.ink)),
            const SizedBox(height: ShokuSpace.sm),
            Text(
              body,
              textAlign: TextAlign.center,
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: ShokuSpace.lg),
              SizedBox(
                width: 220,
                child: _GhostAction(label: actionLabel!, onTap: onAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GhostAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _GhostAction({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
          border: Border.all(color: c.ink, width: ShokuStroke.hairline),
        ),
        child: Center(
          child: Text(label, style: ShokuType.title.copyWith(color: c.ink, fontSize: 14)),
        ),
      ),
    );
  }
}

class ShokuSkeleton extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;
  const ShokuSkeleton({
    super.key,
    this.height = 14,
    this.width,
    this.radius = ShokuRadius.chip,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Compact gamification badge: streak + level as stamped metal.
class ShokuBrassHud extends StatelessWidget {
  final int streak;
  final int level;
  final VoidCallback? onTap;

  const ShokuBrassHud({
    super.key,
    required this.streak,
    required this.level,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: c.reward.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
          border: Border.all(color: c.reward.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.hudStreakDays(streak),
              style: ShokuType.stat.copyWith(fontSize: 12, color: c.reward),
            ),
            Container(
              width: 1,
              height: 11,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: c.reward.withValues(alpha: 0.4),
            ),
            Text(
              l10n.hudLevel(NumberFormat('00', locale).format(level)),
              style: ShokuType.stat.copyWith(fontSize: 12, color: c.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashed call-to-action row, e.g. "Do your first simmr  +5".
class ShokuDashedRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String reward;
  final VoidCallback? onTap;

  const ShokuDashedRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.reward,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: _DashedBorderPainter(c.hairline),
        child: Padding(
          padding: const EdgeInsets.all(ShokuSpace.md),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c.surfaceAlt,
                  borderRadius: BorderRadius.circular(ShokuRadius.chip),
                ),
                child: Icon(icon, size: 17, color: c.accent),
              ),
              const SizedBox(width: ShokuSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ShokuType.title.copyWith(color: c.ink, fontSize: 14)),
                    const SizedBox(height: 1),
                    Text(subtitle, style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                  ],
                ),
              ),
              const SizedBox(width: ShokuSpace.sm),
              ShokuChip(reward, color: c.reward, filled: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(ShokuRadius.card),
    );
    final path = Path()..addRRect(rrect);
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, (distance + dash).clamp(0, metric.length)),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}

class ShokuListRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const ShokuListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 19, color: c.inkMuted),
            const SizedBox(width: ShokuSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ShokuType.title.copyWith(color: c.ink, fontSize: 15)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(subtitle!, style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (showChevron) ...[
              const SizedBox(width: ShokuSpace.sm),
              Icon(Icons.chevron_right, size: 18, color: c.inkMuted),
            ],
          ],
        ),
      ),
    );
  }
}

class ShokuSheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  const ShokuSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: ShokuSpace.lg),
            decoration: BoxDecoration(
              color: c.hairline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: Text(title, style: ShokuType.h1.copyWith(color: c.ink))),
            if (onClose != null)
              GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, size: 20, color: c.inkMuted),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
        ],
      ],
    );
  }
}
