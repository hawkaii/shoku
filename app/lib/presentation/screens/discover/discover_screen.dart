import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/mock_data.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/cards.dart';
import '../../widgets/kit/controls.dart';
import '../../widgets/kit/foundation.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final items = ref.watch(savedItemsProvider);
    final selected = ref.watch(selectedItemProvider) ?? items.first;
    final others = items.where((i) => i.id != selected.id).toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          ShokuSpace.lg,
          ShokuSpace.sm,
          ShokuSpace.lg,
          ShokuSpace.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Discover', style: ShokuType.h1.copyWith(color: c.ink)),
                const Spacer(),
                ShokuChip(
                  selected.kind == ItemKind.recipe ? 'recipe' : 'note',
                  color: selected.kind == ItemKind.recipe ? c.accent : c.reward,
                  filled: true,
                ),
              ],
            ),
            const SizedBox(height: ShokuSpace.md),
            ShokuHairline(),

            // ---- Source provenance --------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: ShokuSpace.md),
              child: Row(
                children: [
                  ShokuChip(
                    selected.sourceLabel,
                    icon: selected.source == ItemSource.instagram
                        ? Icons.camera_alt_outlined
                        : Icons.play_circle_outline,
                  ),
                  const SizedBox(width: ShokuSpace.xs),
                  Text(
                    selected.sourceHandle,
                    style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                  ),
                  const SizedBox(width: ShokuSpace.xs),
                  Text('·', style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                  const SizedBox(width: ShokuSpace.xs),
                  Text(
                    selected.duration,
                    style: ShokuType.stat.copyWith(fontSize: 12, color: c.inkMuted),
                  ),
                  const Spacer(),
                  Text(
                    '+${selected.xp} xp',
                    style: ShokuType.stat.copyWith(fontSize: 12, color: c.reward),
                  ),
                ],
              ),
            ),

            // ---- Title ---------------------------------------------------
            Text(selected.title, style: ShokuType.display.copyWith(color: c.ink)),
            const SizedBox(height: ShokuSpace.sm),
            Text(
              selected.subtitle,
              style: ShokuType.body.copyWith(color: c.inkMuted),
            ),
            const SizedBox(height: ShokuSpace.lg),

            if (selected.kind == ItemKind.recipe) ...[
              Row(
                children: [
                  ShokuPantryTicks(have: selected.pantryHave, need: selected.pantryNeed),
                  const SizedBox(width: ShokuSpace.sm),
                  Text(
                    '${selected.pantryHave} of ${selected.pantryNeed} in your pantry',
                    style: ShokuType.bodySmall.copyWith(color: c.ready),
                  ),
                ],
              ),
              const SizedBox(height: ShokuSpace.lg),
            ],

            ShokuHairline(),
            const SizedBox(height: ShokuSpace.lg),

            // ---- Body ----------------------------------------------------
            ...selected.body.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: ShokuSpace.lg),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            (e.key + 1).toString().padLeft(2, '0'),
                            style: ShokuType.stat.copyWith(fontSize: 12, color: c.inkMuted),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.value,
                            style: ShokuType.body.copyWith(color: c.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            const SizedBox(height: ShokuSpace.sm),
            Row(
              children: [
                Expanded(
                  child: ShokuButton(
                    'Save to stash',
                    icon: Icons.bookmark_add_outlined,
                    onPressed: () {},
                    small: true,
                  ),
                ),
                const SizedBox(width: ShokuSpace.sm),
                Expanded(
                  child: ShokuButton(
                    'Add to list',
                    icon: Icons.playlist_add,
                    variant: ShokuButtonVariant.outline,
                    onPressed: () => context.go('/shopping'),
                    small: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: ShokuSpace.xxl),
            ShokuLabel('next up'),
            const SizedBox(height: ShokuSpace.sm),
            ...others.take(3).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: ShokuSpace.sm),
                    child: ShokuSurface(
                      color: c.surfaceAlt,
                      padding: const EdgeInsets.all(ShokuSpace.md),
                      onTap: () =>
                          ref.read(selectedItemProvider.notifier).state = item,
                      child: Row(
                        children: [
                          Icon(
                            item.kind == ItemKind.recipe
                                ? Icons.restaurant_menu
                                : Icons.lightbulb_outline,
                            size: 17,
                            color: c.inkMuted,
                          ),
                          const SizedBox(width: ShokuSpace.md),
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ShokuType.title.copyWith(color: c.ink, fontSize: 13),
                            ),
                          ),
                          Text(
                            item.duration,
                            style: ShokuType.stat.copyWith(fontSize: 11, color: c.inkMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
