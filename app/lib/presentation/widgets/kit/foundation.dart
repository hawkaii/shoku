import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';

/// The base surface. No shadows; separation comes from tone and a hairline.
class ShokuSurface extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool border;
  final bool brutal;
  final VoidCallback? onTap;

  const ShokuSurface({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(ShokuSpace.md),
    this.margin,
    this.radius = ShokuRadius.card,
    this.border = false,
    this.brutal = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = color ?? c.surface;

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: border || brutal
            ? Border.all(
                color: brutal ? c.ink : c.hairline,
                width: brutal ? ShokuStroke.brutal : ShokuStroke.hairline,
              )
            : null,
        boxShadow: brutal
            ? [
                BoxShadow(
                  color: c.ink,
                  offset: ShokuStroke.brutalShadow,
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      );
    }

    return margin == null ? content : Padding(padding: margin!, child: content);
  }
}

class ShokuHairline extends StatelessWidget {
  final double indent;
  const ShokuHairline({super.key, this.indent = 0});

  @override
  Widget build(BuildContext context) => Container(
        height: ShokuStroke.hairline,
        margin: EdgeInsets.only(left: indent),
        color: context.colors.hairline,
      );
}

class ShokuLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const ShokuLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: ShokuType.label.copyWith(color: color ?? context.colors.inkMuted),
      );
}

class ShokuStat extends StatelessWidget {
  final String value;
  final String? label;
  final Color? color;
  final bool hero;
  final CrossAxisAlignment align;

  const ShokuStat(
    this.value, {
    super.key,
    this.label,
    this.color,
    this.hero = false,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: (hero ? ShokuType.statHero : ShokuType.stat)
              .copyWith(color: color ?? c.ink),
        ),
        if (label != null) ...[
          const SizedBox(height: ShokuSpace.xxs),
          Text(label!, style: ShokuType.label.copyWith(color: c.inkMuted)),
        ],
      ],
    );
  }
}

/// A tiny status chip: mono label, 6px radius, hairline border.
class ShokuChip extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? background;
  final IconData? icon;
  final bool filled;
  final VoidCallback? onTap;

  const ShokuChip(
    this.text, {
    super.key,
    this.color,
    this.background,
    this.icon,
    this.filled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = color ?? c.inkMuted;
    final bg = background ?? (filled ? fg.withValues(alpha: 0.12) : Colors.transparent);

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(ShokuRadius.chip),
        border: Border.all(
          color: filled ? fg.withValues(alpha: 0.35) : c.hairline,
          width: ShokuStroke.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(text.toUpperCase(), style: ShokuType.label.copyWith(color: fg)),
        ],
      ),
    );

    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}

/// Thin progress rail — used for weekly saves and XP.
class ShokuProgress extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;
  const ShokuProgress({
    super.key,
    required this.value,
    this.color,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(ShokuRadius.pill),
      child: Stack(
        children: [
          Container(height: height, color: c.surfaceAlt),
          FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: Container(height: height, color: color ?? c.accent),
          ),
        ],
      ),
    );
  }
}

/// The pantry readiness meter: 8 ticks, owned ones lit.
class ShokuPantryTicks extends StatelessWidget {
  final int have;
  final int need;
  final double tickHeight;
  const ShokuPantryTicks({
    super.key,
    required this.have,
    required this.need,
    this.tickHeight = 12,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final total = need == 0 ? 1 : need;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final owned = i < have;
        return Container(
          width: 4,
          height: tickHeight,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            color: owned ? c.ready : c.hairline,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}
