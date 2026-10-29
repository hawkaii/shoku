import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';

class ShokuTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const ShokuTabItem(this.icon, this.activeIcon, this.label);
}

/// Five-tab bar: hairline on top, active tab marked by a 4px accent dot.
class ShokuTabBar extends StatelessWidget {
  final List<ShokuTabItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  const ShokuTabBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.canvas,
        border: Border(top: BorderSide(color: c.hairline, width: ShokuStroke.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          i == index ? items[i].activeIcon : items[i].icon,
                          size: 21,
                          color: i == index ? c.ink : c.inkMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: ShokuType.label.copyWith(
                            fontSize: 10,
                            color: i == index ? c.ink : c.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: i == index ? c.accent : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
