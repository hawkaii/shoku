import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/mock_data.dart';
import '../../../presentation/state/shoku_providers.dart';
import '../../widgets/kit/cards.dart';
import '../../widgets/kit/controls.dart';
import '../../widgets/kit/feedback.dart';
import '../../widgets/kit/foundation.dart';
import '../add/add_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final items = ref.watch(filteredItemsProvider);
    final filter = ref.watch(feedFilterProvider);
    final streak = ref.watch(streakDaysProvider);
    final level = ref.watch(levelProvider);
    final saves = ref.watch(savesBalanceProvider);

    final cookTonight = ref
        .watch(savedItemsProvider)
        .where((i) => i.kind == ItemKind.recipe && i.pantryNeed > 0)
        .where((i) => i.pantryHave / i.pantryNeed >= 0.7)
        .toList();

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
            // ---- Header -------------------------------------------------
            Row(
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Shoku',
                    style: ShokuType.h1.copyWith(color: c.ink),
                    children: [
                      TextSpan(text: '.', style: TextStyle(color: c.accent)),
                    ],
                  ),
                ),
                const Spacer(),
                ShokuBrassHud(streak: streak, level: level),
                const SizedBox(width: ShokuSpace.sm),
                ShokuIconButton(
                  icon: Icons.notifications_none,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: ShokuSpace.lg),

            // ---- Extract bar (loudest element) --------------------------
            _ExtractBar(
              onTap: () => showAddSheet(context),
            ),
            const SizedBox(height: ShokuSpace.xl),

            // ---- Cook tonight -------------------------------------------
            if (cookTonight.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  ShokuLabel('cook tonight', color: c.ink),
                  const SizedBox(width: ShokuSpace.sm),
                  Expanded(
                    child: Text(
                      'matched to your pantry',
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                    ),
                  ),
                  Text(
                    '$saves saves',
                    style: ShokuType.stat.copyWith(fontSize: 12, color: c.inkMuted),
                  ),
                ],
              ),
              const SizedBox(height: ShokuSpace.sm),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cookTonight.length,
                  separatorBuilder: (_, __) => const SizedBox(width: ShokuSpace.sm),
                  itemBuilder: (context, i) => _CookCard(item: cookTonight[i]),
                ),
              ),
              const SizedBox(height: ShokuSpace.xl),
            ],

            // ---- Filter --------------------------------------------------
            ShokuSegmented(
              labels: const ['ALL', 'RECIPES', 'WISDOM'],
              selected: filter.index,
              onChanged: (i) => ref.read(feedFilterProvider.notifier).state =
                  FeedFilter.values[i],
            ),
            const SizedBox(height: ShokuSpace.lg),

            // ---- Feed ----------------------------------------------------
            if (items.isEmpty)
              ShokuEmptyState(
                icon: Icons.menu_book_outlined,
                title: 'Nothing here yet',
                body: 'Share a reel or paste a link and it will land here in a few seconds.',
                actionLabel: 'Add your first save',
                onAction: () => showAddSheet(context),
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: ShokuSpace.md),
                  child: item.kind == ItemKind.recipe
                      ? ShokuTicketCard(
                          item: item,
                          onTap: () => context.push('/recipe/${item.id}'),
                        )
                      : ShokuWisdomCard(
                          item: item,
                          index: items.indexOf(item) + 1,
                          onTap: () {
                            ref.read(selectedItemProvider.notifier).state = item;
                            context.go('/discover');
                          },
                        ),
                ),
              ),

            const SizedBox(height: ShokuSpace.sm),
            ShokuDashedRow(
              icon: Icons.add,
              title: 'Save your first wisdom',
              subtitle: 'Turn an advice reel into notes',
              reward: '+5',
              onTap: () => showAddSheet(context),
            ),
            const SizedBox(height: ShokuSpace.sm),
            ShokuDashedRow(
              icon: Icons.shopping_basket_outlined,
              title: 'Build a shopping list',
              subtitle: 'Pick ingredients from any recipe',
              reward: '+3',
              onTap: () => context.go('/shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtractBar extends StatelessWidget {
  final VoidCallback onTap;
  const _ExtractBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ShokuSpace.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(ShokuRadius.card),
          border: Border.all(color: c.ink, width: ShokuStroke.brutal),
          boxShadow: [
            BoxShadow(color: c.ink, offset: ShokuStroke.brutalShadow, blurRadius: 0),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
              ),
              child: Icon(Icons.add_link, size: 19, color: c.accent),
            ),
            const SizedBox(width: ShokuSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paste a reel, or share from any app',
                    style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Instagram · YouTube · links',
                    style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.ink,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
              ),
              child: Text(
                'PASTE',
                style: ShokuType.label.copyWith(color: c.canvas, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CookCard extends StatelessWidget {
  final SavedItem item;
  const _CookCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: 220,
      child: ShokuSurface(
        color: c.surfaceAlt,
        padding: const EdgeInsets.all(ShokuSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
            ),
            const Spacer(),
            Row(
              children: [
                ShokuPantryTicks(have: item.pantryHave, need: item.pantryNeed),
                const SizedBox(width: 5),
                Text(
                  '${item.pantryHave}/${item.pantryNeed}',
                  style: ShokuType.stat.copyWith(fontSize: 11, color: c.ready),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
