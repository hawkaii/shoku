import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/labels.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/shoku_text.dart';
import '../../../data/mock/journal_data.dart';
import '../../state/journal_providers.dart';
import '../../state/sync_providers.dart';
import '../profile/sign_in_sheet.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/status_badge.dart';
import 'dish_actions.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l10n = context.l10n;
    final dishes = ref.watch(dishesProvider);
    final filter = ref.watch(libraryFilterProvider);
    final status = ref.watch(syncStatusProvider);

    final toCook = dishes.where((d) => d.status == DishStatus.toCook).toList();
    final cooked = dishes.where((d) => d.status != DishStatus.toCook).toList();
    final visible = filter == LibraryFilter.toCook ? toCook : cooked;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          ShokuSpace.lg,
          ShokuSpace.sm,
          ShokuSpace.lg,
          ShokuSpace.tabBarClearance(context),
        ),
        children: [
          Row(
            children: [
              Text(l10n.cookbookTitle, style: ShokuType.h1.copyWith(color: c.ink)),
              const Spacer(),
              Text(
                l10n.cookbookCookedCount(cooked.length),
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
            _EmptyCookbook(
              filter: filter,
              signedOut: dishes.isEmpty && status == SyncStatus.signedOut,
              unreachable: dishes.isEmpty &&
                  (status == SyncStatus.failed || status == SyncStatus.offline),
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
                child: _DishTile(
                  dish: visible[i],
                  onLongPress: () => showDishActions(context, visible[i]),
                ),
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
  final VoidCallback onLongPress;
  const _DishTile({required this.dish, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final outcome = dish.lastCook?.outcome;
    final meta = metaLine([
      dish.minutes > 0 ? l10n.minutesShort(dish.minutes) : '',
      outcome == null
          ? l10n.cookbookNeverCooked
          : l10n.cookbookLastCooked(outcomeLabel(l10n, outcome)),
    ]);

    return ShokuPressable(
      onTap: () => context.push('/dish/${dish.id}'),
      // Holding a card asks what to do with it, which is the only place the
      // Cookbook offers to move or remove one.
      onLongPress: onLongPress,
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
          if (dish.isSample) ...[
            const SizedBox(height: 4),
            ShokuChip(l10n.labelSample, color: c.reward, filled: true),
          ],
        ],
      ),
    );
  }
}

/// An empty cookbook has three different meanings, and saying which one matters:
/// "you have cooked nothing yet" is a normal state, while an empty shelf after a
/// reinstall reads as data loss. When the journal is empty and sync could not
/// deliver, say so and offer the one action that fixes it.
class _EmptyCookbook extends ConsumerWidget {
  const _EmptyCookbook({
    required this.filter,
    required this.signedOut,
    required this.unreachable,
  });

  final LibraryFilter filter;
  final bool signedOut;
  final bool unreachable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l10n = context.l10n;

    final String message;
    if (signedOut) {
      message = l10n.cookbookEmptySignedOut;
    } else if (unreachable) {
      message = l10n.cookbookEmptyOffline;
    } else {
      message = filter == LibraryFilter.toCook
          ? l10n.cookbookNothingToCook
          : l10n.cookbookNoCooksYet;
    }

    return Padding(
      padding: const EdgeInsets.only(top: ShokuSpace.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              key: const ValueKey('cookbook-empty'),
              textAlign: TextAlign.center,
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
            ),
            if (signedOut)
              TextButton(
                key: const ValueKey('cookbook-sign-in'),
                onPressed: () => showSignInSheet(context),
                child: Text(l10n.authSignIn,
                    style: ShokuType.label.copyWith(color: c.ink)),
              )
            else if (unreachable)
              TextButton(
                key: const ValueKey('cookbook-retry'),
                onPressed: () =>
                    ref.read(syncControllerProvider).syncNow(),
                child: Text(l10n.journalTryAgain,
                    style: ShokuType.label.copyWith(color: c.ink)),
              ),
          ],
        ),
      ),
    );
  }
}
