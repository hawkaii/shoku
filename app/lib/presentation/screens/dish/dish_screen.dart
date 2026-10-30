import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../state/journal_providers.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../assistant/assistant_sheet.dart';
import '../log/debrief_sheet.dart';

class DishScreen extends ConsumerWidget {
  final String dishId;
  const DishScreen({super.key, required this.dishId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final dish = ref.watch(dishProvider(dishId));
    final inspected = ref.watch(inspectedVersionProvider(dishId)).clamp(1, dish.versions.length);
    final version = dish.versions[inspected - 1];
    final recommended = dish.versions.last;
    final altered = recommended.changes.any((c) => c != 'First attempt' && c != 'No changes');

    return Scaffold(
      body: SafeArea(
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
                ShokuPressable(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                      border: Border.all(color: c.hairline),
                    ),
                    child: Icon(Icons.arrow_back, size: 18, color: c.ink),
                  ),
                ),
                const Spacer(),
                ShokuPressable(
                  onTap: () => showAssistantSheet(context, dish: dish),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                      border: Border.all(color: c.hairline),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 14, color: c.accent),
                        const SizedBox(width: 5),
                        Text('ASK', style: ShokuType.label.copyWith(color: c.ink)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ShokuSpace.md),
            ShokuDishImage(
              url: dish.coverUrl,
              title: dish.title,
              height: 210,
              radius: ShokuRadius.card,
              heroTag: true,
            ),
            const SizedBox(height: ShokuSpace.lg),
            Text(dish.title, style: ShokuType.display.copyWith(color: c.ink)),
            const SizedBox(height: 4),
            Text(dish.subtitle, style: ShokuType.body.copyWith(color: c.inkMuted)),
            const SizedBox(height: ShokuSpace.lg),

            // ---- The memory: recommended version -------------------------
            Container(
              padding: const EdgeInsets.all(ShokuSpace.md),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(ShokuRadius.card),
                border: Border.all(color: c.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'v${recommended.number}',
                        style: ShokuType.stat.copyWith(fontSize: 13, color: c.accent),
                      ),
                      const SizedBox(width: ShokuSpace.xs),
                      if (altered)
                        ShokuChip('altered from original', color: c.reward, filled: true),
                      const Spacer(),
                      Text(
                        '${dish.cookCount} cooks',
                        style: ShokuType.stat.copyWith(fontSize: 11, color: c.inkMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: ShokuSpace.sm),
                  Text('What altered', style: ShokuType.label.copyWith(color: c.inkMuted)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final change in recommended.changes)
                        ShokuChip(change, color: c.reward, icon: Icons.bolt),
                    ],
                  ),
                  const SizedBox(height: ShokuSpace.md),
                  Row(
                    children: [
                      Expanded(
                        child: _SmallAction(
                          label: 'View original',
                          icon: Icons.history,
                          onTap: () {
                            ref.read(inspectedVersionProvider(dishId).notifier).state = 1;
                          },
                        ),
                      ),
                      const SizedBox(width: ShokuSpace.sm),
                      Expanded(
                        child: _SmallAction(
                          label: 'Other versions',
                          icon: Icons.layers_outlined,
                          onTap: () {
                            ref.read(inspectedVersionProvider(dishId).notifier).state =
                                dish.versions.length;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: ShokuSpace.md),

            // ---- Version scrubber ---------------------------------------
            Row(
              children: [
                for (var v = 1; v <= dish.versions.length; v++) ...[
                  ShokuPressable(
                    onTap: () => ref
                        .read(inspectedVersionProvider(dishId).notifier)
                        .state = v,
                    child: AnimatedContainer(
                      duration: ShokuMotion.toggle,
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: inspected == v ? c.ink : c.surface,
                        borderRadius: BorderRadius.circular(ShokuRadius.chip),
                        border: Border.all(color: inspected == v ? c.ink : c.hairline),
                      ),
                      child: Text(
                        'v$v',
                        style: ShokuType.stat.copyWith(
                          fontSize: 11,
                          color: inspected == v ? c.canvas : c.inkMuted,
                        ),
                      ),
                    ),
                  ),
                  if (v != dish.versions.length)
                    Container(
                      width: 8,
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      color: c.hairline,
                    ),
                ],
              ],
            ),
            const SizedBox(height: ShokuSpace.lg),

            AnimatedSwitcher(
              duration: ShokuMotion.toggle,
              child: Column(
                key: ValueKey(inspected),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (version.changes.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final change in version.changes)
                          ShokuChip(change, color: c.reward, icon: Icons.bolt),
                      ],
                    ),
                    const SizedBox(height: ShokuSpace.md),
                  ],
                  ShokuLabel('ingredients'),
                  const SizedBox(height: ShokuSpace.sm),
                  for (final ingredient in version.ingredients)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: c.hairline, width: 1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(right: ShokuSpace.md),
                            decoration: BoxDecoration(
                              color: c.ready,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          Expanded(
                            child: Text(ingredient,
                                style: ShokuType.body.copyWith(color: c.ink)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: ShokuSpace.lg),

            // ---- Actions -------------------------------------------------
            ShokuPressable(
              onTap: () => context.push('/cook/$dishId'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: ShokuGradients.crimsonPress,
                  borderRadius: BorderRadius.circular(ShokuRadius.chip),
                  border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                  boxShadow: [
                    BoxShadow(color: c.ink, offset: ShokuStroke.brutalShadow, blurRadius: 0),
                  ],
                ),
                child: Center(
                  child: Text('Start cook mode',
                      style: ShokuType.title.copyWith(color: c.onAccent, fontSize: 14)),
                ),
              ),
            ),
            const SizedBox(height: ShokuSpace.sm),
            ShokuPressable(
              onTap: () => showDebriefSheet(context, dish: dish),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(ShokuRadius.chip),
                  border: Border.all(color: c.hairline),
                ),
                child: Center(
                  child: Text('I just cooked this',
                      style: ShokuType.title.copyWith(color: c.ink, fontSize: 13)),
                ),
              ),
            ),

            const SizedBox(height: ShokuSpace.xl),
            ShokuLabel('history'),
            const SizedBox(height: ShokuSpace.sm),
            if (dish.cooks.isEmpty)
              Text('Not cooked yet. The first log becomes v1.',
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted))
            else
              for (final log in dish.cooks)
                ShokuPressable(
                  onTap: () => ref
                      .read(inspectedVersionProvider(dishId).notifier)
                      .state = log.versionNumber,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: ShokuSpace.sm),
                    padding: const EdgeInsets.all(ShokuSpace.sm),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(ShokuRadius.card),
                      border: Border.all(color: c.hairline),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: ShokuDishImage(
                              url: log.photoUrl, title: dish.title, radius: 6),
                        ),
                        const SizedBox(width: ShokuSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('v${log.versionNumber}',
                                      style: ShokuType.stat
                                          .copyWith(fontSize: 11, color: c.accent)),
                                  const SizedBox(width: ShokuSpace.xs),
                                  Text('· ${_date(log.cookedAt)}',
                                      style: ShokuType.stat.copyWith(
                                          fontSize: 11, color: c.inkMuted)),
                                  const Spacer(),
                                  ShokuChip(log.outcome.label,
                                      color: log.outcome == CookOutcome.nailedIt
                                          ? c.ready
                                          : c.inkMuted),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                log.note.isEmpty ? 'No note' : log.note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SmallAction({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: c.surfaceAlt,
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: c.ink),
            const SizedBox(width: 5),
            Text(label, style: ShokuType.label.copyWith(fontSize: 9.5, color: c.ink)),
          ],
        ),
      ),
    );
  }
}

String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]}';
