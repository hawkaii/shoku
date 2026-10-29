import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../state/journal_providers.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/step_diagram.dart';
import '../log/log_sheet.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final cooks = ref.watch(cooksProvider);
    final dishes = ref.watch(dishesProvider);
    final totalCooks = ref.watch(totalCooksProvider);
    final upgrades = ref.watch(totalUpgradesProvider);
    final pinned = dishes.firstWhere(
      (d) => d.status == DishStatus.wantToTry,
      orElse: () => dishes.first,
    );

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
          // ---- Rhythm header ------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('October kitchen', style: ShokuType.h1.copyWith(color: c.ink)),
                    const SizedBox(height: 2),
                    Text(
                      '${dishes.length} dishes · ${upgrades} upgrades',
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                    ),
                  ],
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
          ShokuLabel('on the counter'),
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
              ShokuLabel('cook log'),
              const Spacer(),
              Text(
                '${cooks.length} entries',
                style: ShokuType.stat.copyWith(fontSize: 11, color: c.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: ShokuSpace.sm),

          if (cooks.isEmpty)
            _EmptyJournal(onStart: () => showLogSheet(context, dishes.first))
          else
            for (var i = 0; i < cooks.length; i++)
              ShokuEntrance(
                index: i,
                child: _TimelineEntry(
                  log: cooks[i],
                  dish: dishes.firstWhere((d) => d.cooks.any((k) => k.id == cooks[i].id)),
                  isLast: i == cooks.length - 1,
                ),
              ),
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
                      const SizedBox(width: ShokuSpace.xs),
                      Text(
                        '· ${dish.minutes} min',
                        style: ShokuType.stat.copyWith(fontSize: 11, color: c.inkMuted),
                      ),
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
                  Text(
                    dish.cookCount == 0 ? 'Not cooked yet' : 'Cooked ${dish.cookCount}×',
                    style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                  ),
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
          SizedBox(
            height: 120,
            child: StepDiagram(stepText: 'plate', height: 120),
          ),
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

