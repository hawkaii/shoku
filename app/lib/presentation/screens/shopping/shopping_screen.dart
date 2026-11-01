import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/mock_data.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/controls.dart';
import '../../widgets/kit/foundation.dart';

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ShokuSpace.lg,
              ShokuSpace.sm,
              ShokuSpace.lg,
              ShokuSpace.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Groceries', style: ShokuType.h1.copyWith(color: c.ink)),
                const SizedBox(height: ShokuSpace.md),
                ShokuSegmented(
                  labels: const ['TO BUY', 'PANTRY'],
                  selected: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tab == 0 ? const _ShoppingList() : const _PantryList(),
          ),
        ],
      ),
    );
  }
}

class _ShoppingList extends ConsumerWidget {
  const _ShoppingList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final items = ref.watch(shoppingProvider);
    final notifier = ref.read(shoppingProvider.notifier);

    final remaining = items.where((i) => !i.done).length;
    final grouped = <String, List<int>>{};
    for (var i = 0; i < items.length; i++) {
      grouped.putIfAbsent(items[i].category, () => []).add(i);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ShokuSpace.lg,
        0,
        ShokuSpace.lg,
        ShokuSpace.xxl,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ShokuStat(
              '$remaining',
              label: 'to buy',
              hero: true,
              color: c.accent,
            ),
            const SizedBox(width: ShokuSpace.lg),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '${items.length - remaining} of ${items.length} in the basket',
                style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: ShokuSpace.md),
        ShokuProgress(value: (items.length - remaining) / items.length),
        const SizedBox(height: ShokuSpace.xl),
        for (final entry in grouped.entries) ...[
          ShokuLabel(entry.key),
          const SizedBox(height: ShokuSpace.xs),
          ...entry.value.map(
            (i) => _ShoppingRow(
              item: items[i],
              onToggle: () => notifier.toggle(i),
              onRemove: () => notifier.remove(i),
            ),
          ),
          const SizedBox(height: ShokuSpace.md),
        ],
        const SizedBox(height: ShokuSpace.sm),
        ShokuButton(
          'Add item',
          icon: Icons.add,
          variant: ShokuButtonVariant.outline,
          onPressed: () => notifier.add(
            ShoppingItem('New item', '1', 'Other'),
          ),
        ),
      ],
    );
  }
}

class _ShoppingRow extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  const _ShoppingRow({
    required this.item,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onToggle,
      onLongPress: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.hairline, width: ShokuStroke.hairline)),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: item.done ? c.ready : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: item.done ? c.ready : c.inkMuted,
                  width: ShokuStroke.hairline,
                ),
              ),
              child: item.done
                  ? Icon(Icons.check, size: 12, color: c.canvas)
                  : null,
            ),
            const SizedBox(width: ShokuSpace.md),
            Expanded(
              child: Text(
                item.name,
                style: ShokuType.body.copyWith(
                  color: item.done ? c.inkMuted : c.ink,
                  decoration: item.done ? TextDecoration.lineThrough : null,
                  decorationColor: c.inkMuted,
                ),
              ),
            ),
            Text(
              item.quantity,
              style: ShokuType.stat.copyWith(fontSize: 12, color: c.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _PantryList extends ConsumerWidget {
  const _PantryList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final pantry = ref.watch(pantryProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ShokuSpace.lg,
        0,
        ShokuSpace.lg,
        ShokuSpace.xxl,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ShokuStat('${pantry.length}', label: 'items', hero: true),
            const SizedBox(width: ShokuSpace.lg),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                'what you can cook tonight',
                style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: ShokuSpace.lg),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: ShokuSpace.sm,
          crossAxisSpacing: ShokuSpace.sm,
          childAspectRatio: 2.1,
          children: [
            for (final item in pantry)
              ShokuSurface(
                color: c.surface,
                border: true,
                padding: const EdgeInsets.all(ShokuSpace.md),
                child: Row(
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: ShokuSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ShokuType.title.copyWith(color: c.ink, fontSize: 13),
                          ),
                          Text(
                            item.quantity,
                            style: ShokuType.stat.copyWith(fontSize: 11, color: c.inkMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: ShokuSpace.lg),
        ShokuButton(
          'Scan a barcode',
          icon: Icons.qr_code_scanner,
          onPressed: () {},
        ),
        const SizedBox(height: ShokuSpace.sm),
        Center(
          child: Text(
            'Barcode scanning lands with the backend phase.',
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
        ),
      ],
    );
  }
}
