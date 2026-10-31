import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/shoku_text.dart';
import '../../../data/mock/journal_data.dart';
import '../../state/journal_providers.dart';
import '../../widgets/kit/dish_image.dart';
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
            // Two columns, always. The tile's height is derived from the photo
            // and the text is reserved underneath it, so a long title or a big
            // text scale can never push words onto the image.
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = ShokuSpace.md;
                final tileWidth = (constraints.maxWidth - gap) / 2;
                final imageHeight = tileWidth * (3 / 4);
                final scaler = MediaQuery.textScalerOf(context);
                final titleHeight = scaler.scale(14) * 1.3 * 2;
                final metaHeight = scaler.scale(11.5) * 1.45;

                return GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visible.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: gap,
                    crossAxisSpacing: gap,
                    mainAxisExtent: imageHeight +
                        ShokuSpace.sm +
                        titleHeight +
                        2 +
                        metaHeight,
                  ),
                  itemBuilder: (context, i) => ShokuEntrance(
                    index: i,
                    child: _DishTile(dish: visible[i]),
                  ),
                );
              },
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
    final meta = metaLine([
      minutesLabel(dish.minutes),
      dish.cookCount == 0
          ? 'never cooked'
          : 'last ${dish.outcomeLabel.toLowerCase()}',
    ]);

    return ShokuPressable(
      onTap: () => context.push('/dish/${dish.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Own aspect ratio, cover crop, clipped to the tile radius. The photo
          // is the card; it does not stretch to fill whatever space is left.
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
            meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}
