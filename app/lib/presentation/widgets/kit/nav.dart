import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';

class ShokuTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const ShokuTabItem(this.icon, this.activeIcon, this.label);
}

/// Four destinations around a centre door. The centre is the fridge, not a
/// button that pushes a page: it is a destination like the others, so it keeps
/// the bar and the back button's history honest.
class ShokuTabBar extends StatelessWidget {
  final List<ShokuTabItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  /// Which of [items] is drawn as the raised door. It still selects a branch.
  final int? centerIndex;

  /// Replaces the active tab's marker. The shell passes the sync line, so the
  /// navigation stays the one place that can say "this is still working".
  final Widget? activeUnderline;

  const ShokuTabBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.centerIndex,
    this.activeUnderline,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

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
              for (var i = 0; i < items.length; i++)
                if (i == centerIndex) _center(context, i) else _tab(context, i),
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

  Widget _center(BuildContext context, int i) {
    final c = context.colors;
    final active = i == index;
    final item = items[i];
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xs),
        child: GestureDetector(
          key: const ValueKey('tab-center'),
          onTap: () => onChanged(i),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: active ? null : ShokuGradients.crimsonPress,
              color: active ? c.surfaceAlt : null,
              borderRadius: BorderRadius.circular(ShokuRadius.chip),
              border: Border.all(
                color: active ? c.accent : c.ink,
                width: ShokuStroke.brutal,
              ),
              boxShadow: [
                BoxShadow(
                  color: c.ink,
                  offset: ShokuStroke.brutalShadow,
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(
              active ? item.activeIcon : item.icon,
              color: active ? c.accent : c.onAccent,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class ShokuMotionConst {
  static const tab = Duration(milliseconds: 180);
  const ShokuMotionConst._();
}
