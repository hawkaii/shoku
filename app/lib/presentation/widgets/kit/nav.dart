import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';

class ShokuTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const ShokuTabItem(this.icon, this.activeIcon, this.label);
}

/// Four destinations plus a centre action. The centre button is the only
/// permanent ingress for import/log, so Home stays a journal, not a toolbar.
class ShokuTabBar extends StatelessWidget {
  final List<ShokuTabItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback? onCenterTap;

  /// Replaces the active tab's marker. The shell passes the sync line, so the
  /// navigation stays the one place that can say "this is still working".
  final Widget? activeUnderline;

  const ShokuTabBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.onCenterTap,
    this.activeUnderline,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final half = (items.length / 2).ceil();

    return Container(
      decoration: BoxDecoration(
        color: c.canvas,
        border: Border(top: BorderSide(color: c.hairline, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < half; i++) _tab(context, i),
              if (onCenterTap != null) _center(context),
              for (var i = half; i < items.length; i++) _tab(context, i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, int i) {
    final c = context.colors;
    final active = i == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(i),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: ShokuMotionConst.tab,
              child: Icon(
                active ? items[i].activeIcon : items[i].icon,
                key: ValueKey(active),
                size: 21,
                color: active ? c.ink : c.inkMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              items[i].label,
              style: ShokuType.label.copyWith(
                fontSize: 9.5,
                color: active ? c.ink : c.inkMuted,
              ),
            ),
            const SizedBox(height: 3),
            if (active && activeUnderline != null)
              activeUnderline!
            else
              AnimatedContainer(
                duration: ShokuMotionConst.tab,
                width: active ? 14 : 4,
                height: 3,
                decoration: BoxDecoration(
                  color: active ? c.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _center(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xs),
      child: GestureDetector(
        onTap: onCenterTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: ShokuGradients.crimsonPress,
            borderRadius: BorderRadius.circular(ShokuRadius.chip),
            border: Border.all(color: c.ink, width: ShokuStroke.brutal),
            boxShadow: [
              BoxShadow(color: c.ink, offset: ShokuStroke.brutalShadow, blurRadius: 0),
            ],
          ),
          child: Icon(Icons.add, color: c.onAccent, size: 22),
        ),
      ),
    );
  }
}

class ShokuMotionConst {
  static const tab = Duration(milliseconds: 180);
  const ShokuMotionConst._();
}
