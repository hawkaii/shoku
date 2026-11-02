import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';

enum ShokuButtonVariant { primary, outline, ghost }

class ShokuButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ShokuButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;
  final bool small;

  const ShokuButton(
    this.label, {
    super.key,
    this.onPressed,
    this.variant = ShokuButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
    this.loading = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final disabled = onPressed == null || loading;

    late final Color bg;
    late final Color fg;
    Gradient? gradient;
    Border? border;

    switch (variant) {
      case ShokuButtonVariant.primary:
        bg = disabled ? c.surfaceAlt : c.accent;
        fg = disabled ? c.inkMuted : c.onAccent;
        gradient = disabled ? null : ShokuGradients.crimsonPress;
        border = Border.all(color: disabled ? c.hairline : c.ink, width: ShokuStroke.brutal);
      case ShokuButtonVariant.outline:
        bg = Colors.transparent;
        fg = disabled ? c.inkMuted : c.ink;
        border = Border.all(color: disabled ? c.hairline : c.ink, width: ShokuStroke.hairline);
      case ShokuButtonVariant.ghost:
        bg = Colors.transparent;
        fg = disabled ? c.inkMuted : c.ink;
    }

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (loading)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else if (icon != null)
          Icon(icon, size: small ? 15 : 17, color: fg),
        if (loading || icon != null) const SizedBox(width: ShokuSpace.sm),
        Text(
          label,
          style: ShokuType.title.copyWith(
            color: fg,
            fontSize: small ? 13 : 15,
          ),
        ),
      ],
    );

    final button = Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? ShokuSpace.md : ShokuSpace.lg,
        vertical: small ? 9 : 13,
      ),
      decoration: BoxDecoration(
        color: gradient == null ? bg : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(ShokuRadius.chip),
        border: border,
        boxShadow: variant == ShokuButtonVariant.primary && !disabled
            ? [
                BoxShadow(
                  color: c.ink,
                  offset: ShokuStroke.brutalShadow,
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: content,
    );

    return GestureDetector(
      onTap: disabled ? null : onPressed,
      behavior: HitTestBehavior.opaque,
      child: fullWidth
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}

class ShokuIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;
  final double size;

  const ShokuIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.filled = false,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? c.surfaceAlt : Colors.transparent,
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
          border: Border.all(color: c.hairline, width: ShokuStroke.hairline),
        ),
        child: Icon(icon, size: size * 0.48, color: c.ink),
      ),
    );
  }
}

/// Segmented filter. Active segment fills with ink and inverts text.
class ShokuSegmented extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final bool dense;

  const ShokuSegmented({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.chip),
        border: Border.all(color: c.hairline, width: ShokuStroke.hairline),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(vertical: dense ? 7 : 9),
                  decoration: BoxDecoration(
                    color: i == selected ? c.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(ShokuRadius.chip - 1),
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: ShokuType.label.copyWith(
                        color: i == selected ? c.canvas : c.inkMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ShokuSearchField extends StatelessWidget {
  final String? hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const ShokuSearchField({
    super.key,
    this.hint,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.chip),
        border: Border.all(color: c.hairline, width: ShokuStroke.hairline),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: c.inkMuted),
          const SizedBox(width: ShokuSpace.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: ShokuType.bodySmall.copyWith(color: c.ink),
              cursorColor: c.accent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint ?? context.l10n.searchHint,
                hintStyle: ShokuType.bodySmall.copyWith(color: c.inkMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
