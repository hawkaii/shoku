import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../state/journal_providers.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final dishes = ref.watch(dishesProvider);
    final filter = ref.watch(libraryFilterProvider);

    final visible = switch (filter) {
      LibraryFilter.all => dishes,
      LibraryFilter.wantToTry => dishes.where((d) => d.status == DishStatus.wantToTry).toList(),
      LibraryFilter.inProgress => dishes.where((d) => d.status == DishStatus.inProgress).toList(),
      LibraryFilter.signature => dishes.where((d) => d.status == DishStatus.signature).toList(),
    };

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
                '${dishes.length} dishes',
                style: ShokuType.stat.copyWith(fontSize: 11, color: c.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: ShokuSpace.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in LibraryFilter.values) ...[
                  _FilterPill(
                    label: switch (f) {
                      LibraryFilter.all => 'ALL',
                      LibraryFilter.wantToTry => 'TO TRY',
                      LibraryFilter.inProgress => 'IN PROGRESS',
                      LibraryFilter.signature => 'SIGNATURE',
                    },
                    selected: filter == f,
                    onTap: () => ref.read(libraryFilterProvider.notifier).state = f,
                  ),
                  const SizedBox(width: ShokuSpace.xs),
                ],
              ],
            ),
          ),
          const SizedBox(height: ShokuSpace.lg),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: ShokuSpace.md,
            crossAxisSpacing: ShokuSpace.md,
            childAspectRatio: 0.72,
            children: [
              for (var i = 0; i < visible.length; i++)
                ShokuEntrance(
                  index: i,
                  child: _DishTile(dish: visible[i]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: ShokuMotion.toggle,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? c.ink : c.surface,
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
          border: Border.all(color: selected ? c.ink : c.hairline),
        ),
        child: Text(
          label,
          style: ShokuType.label.copyWith(color: selected ? c.canvas : c.inkMuted),
        ),
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
                  left: ShokuSpace.sm,
                  top: ShokuSpace.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.canvas.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                    ),
                    child: Text(
                      'v${dish.currentVersion}',
                      style: ShokuType.stat.copyWith(fontSize: 10, color: c.accent),
                    ),
                  ),
                ),
                if (dish.status == DishStatus.signature)
                  Positioned(
                    right: ShokuSpace.sm,
                    top: ShokuSpace.sm,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: c.reward,
                        borderRadius: BorderRadius.circular(ShokuRadius.chip),
                      ),
                      child: Icon(Icons.star_rounded, size: 12, color: c.canvas),
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
            dish.cookCount == 0 ? 'Not cooked yet' : '${dish.cookCount} cooks · ${dish.outcomeLabel}',
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
