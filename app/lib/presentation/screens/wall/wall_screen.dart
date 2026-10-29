import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../state/journal_providers.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';

/// Your wall: every night you actually cooked. Private, chronological, no feed.
class WallScreen extends ConsumerWidget {
  const WallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final dishes = ref.watch(dishesProvider);

    final entries = <({Dish dish, CookLog log})>[];
    for (final dish in dishes) {
      for (final log in dish.cooks) {
        entries.add((dish: dish, log: log));
      }
    }
    entries.sort((a, b) => b.log.cookedAt.compareTo(a.log.cookedAt));

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              ShokuSpace.lg,
              ShokuSpace.sm,
              ShokuSpace.lg,
              ShokuSpace.md,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wall', style: ShokuType.h1.copyWith(color: c.ink)),
                      const SizedBox(height: 2),
                      Text(
                        '${entries.length} nights in your kitchen',
                        style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ShokuChip('private', icon: Icons.lock_outline),
                ],
              ),
            ),
          ),
          if (entries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('Nothing on the wall yet.',
                    style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                ShokuSpace.lg,
                0,
                ShokuSpace.lg,
                ShokuSpace.xxxl,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: ShokuSpace.sm,
                  crossAxisSpacing: ShokuSpace.sm,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final entry = entries[i];
                    return ShokuEntrance(
                      index: i,
                      child: _WallTile(dish: entry.dish, log: entry.log),
                    );
                  },
                  childCount: entries.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WallTile extends StatelessWidget {
  final Dish dish;
  final CookLog log;
  const _WallTile({required this.dish, required this.log});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuPressable(
      onTap: () => context.push('/dish/${dish.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ShokuRadius.media),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ShokuDishImage(
              url: log.photoUrl,
              title: dish.title,
              radius: ShokuRadius.media,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(ShokuSpace.sm),
                decoration: const BoxDecoration(
                  gradient: ShokuGradients.photoScrim,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ShokuType.title.copyWith(color: Colors.white, fontSize: 12.5),
                    ),
                    Text(
                      'v${log.versionNumber} · ${log.mood.name}',
                      style: ShokuType.label.copyWith(
                        fontSize: 8.5,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: ShokuSpace.sm,
              right: ShokuSpace.sm,
              child: Text(
                log.rating.toString(),
                style: ShokuType.stat.copyWith(fontSize: 11, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
