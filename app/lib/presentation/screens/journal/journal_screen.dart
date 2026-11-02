import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/shoku_text.dart';
import '../../../data/mock/journal_data.dart';
import '../../state/journal_providers.dart';
import '../../state/journal_store.dart';
import '../../state/pantry_providers.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/plate_mark.dart';
import '../../widgets/kit/status_badge.dart';
import '../add/add_sheet.dart';
import '../log/log_sheet.dart';
import 'import_card.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final cooks = ref.watch(cooksProvider);
    final dishes = ref.watch(dishesProvider);
    final totalCooks = ref.watch(totalCooksProvider);
    final upgrades = ref.watch(totalUpgradesProvider);

    // The journal is read from the database on launch, so the first frame can
    // legitimately be empty — don't index into it.
    final status = ref.watch(journalStatusProvider);
    if (status == JournalStatus.failed) {
      return _withImportCard(
        _JournalError(
          onRetry: () => ref.read(journalStoreProvider.notifier).retry(),
        ),
      );
    }
    if (dishes.isEmpty) {
      // A brand-new user has no dishes and still needs a way to import.
      return _withImportCard(
        Column(
          children: [
            const _SaveRecipeRow(),
            Expanded(child: _JournalLoading(ready: status == JournalStatus.ready)),
          ],
        ),
      );
    }

    final pinned = dishes.firstWhere(
      (d) => d.status == DishStatus.toCook,
      orElse: () => dishes.first,
    );

    // A CustomScrollView because the cook-log empty card is the one thing on
    // screen and must be laid out with SliverFillRemaining: it may not be cut
    // in half by the tab bar (§12.3).
    return _withImportCard(
      CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              ShokuSpace.lg,
              ShokuSpace.sm,
              ShokuSpace.lg,
              0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
          // ---- Save a recipe -------------------------------------------
          const _SaveRecipeRow(),
          const SizedBox(height: ShokuSpace.md),

          // ---- Rhythm header ------------------------------------------
          Row(
            children: [
              const PlateMark(size: 24),
              const SizedBox(width: ShokuSpace.sm),
              Expanded(
                child: Text(
                  'October kitchen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ShokuType.h1.copyWith(color: c.ink),
                ),
              ),
              const SizedBox(width: ShokuSpace.sm),
              const _FridgeButton(),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  metaLine([
                    count(dishes.length, 'dish', 'dishes'),
                    count(upgrades, 'upgrade'),
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
              ),
              _CounterPill(
                value: '$totalCooks',
                label: 'cooks',
                color: c.accent,
                onTap: () {},
              ),
              const SizedBox(width: ShokuSpace.xs),
              _CounterPill(
                value: '$upgrades',
                label: 'upgrades',
                color: c.reward,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: ShokuSpace.xl),

          // ---- On the counter -----------------------------------------
          const ShokuLabel('on the counter'),
          const SizedBox(height: ShokuSpace.sm),
          ShokuEntrance(
            child: _PinnedCard(
              dish: pinned,
              onCook: () => showLogSheet(context, pinned),
              onOpen: () => context.push('/dish/${pinned.id}'),
            ),
          ),
          const SizedBox(height: ShokuSpace.xl),

          // ---- Timeline ------------------------------------------------
          Row(
            children: [
              const ShokuLabel('cook log'),
              const Spacer(),
              Text(
                count(cooks.length, 'entry', 'entries'),
                style: ShokuType.stat.copyWith(fontSize: 11, color: c.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: ShokuSpace.sm),
                ],
              ),
            ),
          ),
          if (cooks.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: ShokuSpace.lg,
                  right: ShokuSpace.lg,
                  bottom: ShokuSpace.tabBarClearance(context),
                ),
                child: _EmptyJournal(
                  onStart: () => showLogSheet(context, dishes.first),
                ),
              ),
            )
          else ...{
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                ShokuSpace.lg,
                0,
                ShokuSpace.lg,
                ShokuSpace.tabBarClearance(context),
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => ShokuEntrance(
                    index: i,
                    child: _TimelineEntry(
                      log: cooks[i],
                      dish: dishes
                          .firstWhere((d) => d.cooks.any((k) => k.id == cooks[i].id)),
                      isLast: i == cooks.length - 1,
                    ),
                  ),
                  childCount: cooks.length,
                ),
              ),
            ),
          },
        ],
      ),
    );
  }

  /// The import card sits above the scroll view, so it cannot scroll away and
  /// the Journal never becomes unreachable behind it.
  Widget _withImportCard(Widget body) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const JournalImportCard(),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CounterPill({
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShokuNumberRoll(
              value: value,
              style: ShokuType.stat.copyWith(fontSize: 14, color: color),
            ),
            Text(label, style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
          ],
        ),
      ),
    );
  }
}

class _PinnedCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback onCook;
  final VoidCallback onOpen;

  const _PinnedCard({required this.dish, required this.onCook, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuPressable(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(ShokuSpace.sm),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(ShokuRadius.card),
          border: Border.all(color: c.hairline, width: ShokuStroke.hairline),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: ShokuDishImage(url: dish.coverUrl, title: dish.title, radius: 6),
            ),
            const SizedBox(width: ShokuSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'v${dish.currentVersion}',
                        style: ShokuType.stat.copyWith(fontSize: 11, color: c.accent),
                      ),
                      // A duration we don't know is not shown at all: a stray
                      // dot or a dash would read as data.
                      if (minutesLabel(dish.minutes).isNotEmpty) ...[
                        const SizedBox(width: ShokuSpace.xs),
                        Flexible(
                          child: Text(
                            '· ${minutesLabel(dish.minutes)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ShokuType.stat.copyWith(
                              fontSize: 11,
                              color: c.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dish.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ShokuType.title.copyWith(color: c.ink),
                  ),
                  const SizedBox(height: 1),
                  StatusBadge(status: dish.status, cookCount: dish.cookCount, compact: true),
                ],
              ),
            ),
            const SizedBox(width: ShokuSpace.sm),
            ShokuPressable(
              onTap: onCook,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  gradient: ShokuGradients.crimsonPress,
                  borderRadius: BorderRadius.circular(ShokuRadius.chip),
                  border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                  boxShadow: [
                    BoxShadow(color: c.ink, offset: ShokuStroke.brutalShadow, blurRadius: 0),
                  ],
                ),
                child: Text(
                  'Cook',
                  style: ShokuType.title.copyWith(color: c.onAccent, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final CookLog log;
  final Dish dish;
  final bool isLast;

  const _TimelineEntry({required this.log, required this.dish, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final day = log.cookedAt.day.toString().padLeft(2, '0');
    final month = _month(log.cookedAt.month);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date spine
          SizedBox(
            width: 46,
            child: Column(
              children: [
                Text(day, style: ShokuType.stat.copyWith(fontSize: 13, color: c.ink)),
                Text(month, style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
                const SizedBox(height: ShokuSpace.xs),
                Expanded(
                  child: Container(
                    width: 1,
                    color: isLast ? Colors.transparent : c.hairline,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ShokuPressable(
              onTap: () => context.push('/dish/${dish.id}'),
              child: Container(
                margin: const EdgeInsets.only(bottom: ShokuSpace.lg),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(ShokuRadius.card),
                  border: Border.all(color: c.hairline, width: ShokuStroke.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ShokuDishImage(
                          url: log.photoUrl,
                          title: dish.title,
                          height: 168,
                          radius: ShokuRadius.card,
                        ),
                        Positioned(
                          top: ShokuSpace.sm,
                          right: ShokuSpace.sm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: c.canvas.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(ShokuRadius.chip),
                              border: Border.all(color: c.hairline),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'v${log.versionNumber}',
                                  style: ShokuType.stat.copyWith(fontSize: 11, color: c.accent),
                                ),
                                Container(
                                  width: 1,
                                  height: 10,
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  color: c.hairline,
                                ),
                                Text(
                                  log.outcome.label,
                                  style: ShokuType.label.copyWith(fontSize: 9, color: c.ink),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(ShokuSpace.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dish.title, style: ShokuType.h2.copyWith(color: c.ink)),
                          const SizedBox(height: 2),
                          // How the night felt and what it was worth — quiet,
                          // in the words the log already stores.
                          Text(
                            '${log.mood.name} · ${log.rating}/5',
                            key: const ValueKey('cook-mood-rating'),
                            style: ShokuType.bodySmall.copyWith(
                              color: c.inkMuted,
                            ),
                          ),
                          if (log.changes.isNotEmpty) ...[
                            const SizedBox(height: ShokuSpace.sm),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final change in log.changes.take(2))
                                  ShokuChip(change, color: c.reward, icon: Icons.bolt),
                              ],
                            ),
                          ],
                          if (log.note.isNotEmpty) ...[
                            const SizedBox(height: ShokuSpace.sm),
                            Text(
                              '“${log.note}”',
                              style: ShokuType.bodySmall.copyWith(
                                color: c.inkMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _month(int m) =>
    const ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][m - 1];

class _EmptyJournal extends StatelessWidget {
  final VoidCallback onStart;
  const _EmptyJournal({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(ShokuSpace.lg),
      decoration: BoxDecoration(
        gradient: ShokuGradients.warmVellum,
        borderRadius: BorderRadius.circular(ShokuRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: PlateMark(size: 96)),
          const SizedBox(height: ShokuSpace.sm),
          Text('Your first page', style: ShokuType.h2.copyWith(color: c.ink)),
          const SizedBox(height: ShokuSpace.xs),
          Text(
            'Log one cook — a photo, how it went, and one thing you changed. That becomes v1.',
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.md),
          Text('Start the journal →', style: ShokuType.title.copyWith(color: c.accent, fontSize: 14)),
        ],
      ),
    );
  }
}


/// Shown for the frame or two while the journal is read from disk, and for a
/// genuinely empty journal. No spinners: the mark, one line, and nothing to tap.
/// A cart-style door to the fridge, with how much is in it.
class _FridgeButton extends ConsumerWidget {
  const _FridgeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final items = ref.watch(pantryStoreProvider).where((i) => !i.wanted).length;
    return GestureDetector(
      key: const ValueKey('fridge-button'),
      onTap: () => context.go('/pantry'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
          border: Border.all(color: c.hairline),
        ),
        child: Row(
          children: [
            Icon(Icons.kitchen, size: 15, color: c.ink),
            const SizedBox(width: 4),
            Text('$items',
                style: ShokuType.stat.copyWith(fontSize: 11, color: c.ink)),
          ],
        ),
      ),
    );
  }
}

/// The import door, present in every journal state — including the empty one,
/// where it is the only way forward for a new user.
class _SaveRecipeRow extends StatelessWidget {
  const _SaveRecipeRow();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          ShokuSpace.lg, ShokuSpace.xs, ShokuSpace.lg, 0),
      child: ShokuPressable(
        key: const ValueKey('journal-save-recipe'),
        onTap: () => showAddSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: ShokuSpace.md, vertical: ShokuSpace.sm),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(ShokuRadius.card),
            border: Border.all(color: c.hairline),
          ),
          child: Row(
            children: [
              Icon(Icons.add, size: 16, color: c.accent),
              const SizedBox(width: ShokuSpace.sm),
              Text('Save a recipe',
                  style: ShokuType.title.copyWith(color: c.ink, fontSize: 13)),
              const Spacer(),
              Icon(Icons.chevron_right, size: 18, color: c.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalLoading extends StatelessWidget {
  final bool ready;
  const _JournalLoading({this.ready = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PlateMark(size: 56),
            const SizedBox(height: ShokuSpace.md),
            Text(
              ready ? 'No dishes yet — import a reel to start' : 'Opening your journal',
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// The database failed to open. Say so, and offer the one useful action.
class _JournalError extends StatelessWidget {
  final VoidCallback onRetry;
  const _JournalError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PlateMark(size: 56),
              const SizedBox(height: ShokuSpace.md),
              Text(
                'Your journal could not be opened',
                textAlign: TextAlign.center,
                style: ShokuType.title.copyWith(color: c.ink, fontSize: 15),
              ),
              const SizedBox(height: ShokuSpace.xs),
              Text(
                'The saved cooks are still on this phone.',
                textAlign: TextAlign.center,
                style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
              ),
              const SizedBox(height: ShokuSpace.lg),
              TextButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}
