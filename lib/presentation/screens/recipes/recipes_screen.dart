import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../state/journal_providers.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/status_badge.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final dishes = ref.watch(dishesProvider);
    final filter = ref.watch(libraryFilterProvider);

    final toCook = dishes.where((d) => d.status == DishStatus.toCook).toList();
    final cooked = dishes.where((d) => d.status != DishStatus.toCook).toList();
    final visible = filter == LibraryFilter.toCook ? toCook : cooked;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          ShokuSpace.lg,
          ShokuSpace.sm,
          ShokuSpace.lg,
          ShokuSpace.xxxl,
        ),
        children: [
          Row(
            children: [
              Text('Cookbook', style: ShokuType.h1.copyWith(color: c.ink)),
              const Spacer(),
              Text(
                '${cooked.length} cooked',
                style: ShokuType.stat.copyWith(fontSize: 11, color: c.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: ShokuSpace.md),
          StatusToggle(
            toCookCount: toCook.length,
            cookedCount: cooked.length,
            showingToCook: filter == LibraryFilter.toCook,
            onChanged: (showToCook) => ref.read(libraryFilterProvider.notifier).state =
                showToCook ? LibraryFilter.toCook : LibraryFilter.cooked,
          ),
          const SizedBox(height: ShokuSpace.lg),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: ShokuSpace.xxl),
              child: Center(
                child: Text(
                  filter == LibraryFilter.toCook
                      ? 'Nothing waiting to be cooked.'
                      : 'No cooks yet. Pick something from To cook.',
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
              ),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: ShokuSpace.md,
              crossAxisSpacing: ShokuSpace.md,
              childAspectRatio: 0.70,
              children: [
                for (var i = 0; i < visible.length; i++)
                  ShokuEntrance(index: i, child: _DishTile(dish: visible[i])),
              ],
            ),
        ],
      ),
    );
  }
}

class _DishTile extends StatelessWidget {
  final Dish dish;
  const _DishTile({required this.dish});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuPressable(
      onTap: () => context.push('/dish/${dish.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ShokuDishImage(
                  url: dish.coverUrl,
                  title: dish.title,
                  radius: ShokuRadius.media,
                  heroTag: true,
                ),
                Positioned(
                  left: ShokuSpace.xs,
                  top: ShokuSpace.xs,
                  child: StatusBadge(
                    status: dish.status,
                    cookCount: dish.cookCount,
                    compact: true,
                  ),
                ),
                Positioned(
                  right: ShokuSpace.xs,
                  top: ShokuSpace.xs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.ink.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                    ),
                    child: Text(
                      'v${dish.currentVersion}',
                      style: ShokuType.stat.copyWith(fontSize: 10, color: c.canvas),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShokuSpace.sm),
          Text(
            dish.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            dish.cookCount == 0
                ? '${dish.minutes} min · never cooked'
                : '${dish.minutes} min · last ${dish.outcomeLabel.toLowerCase()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
