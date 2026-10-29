import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../state/journal_providers.dart';
import '../../state/nutrition_providers.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';

/// The lens: what your cooking does to your targets, and what your versions
/// changed. Deliberately not a weekly calorie ledger — Shoku only sees the
/// meals you actually cook.
class NutritionLensScreen extends ConsumerWidget {
  const NutritionLensScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final profile = ref.watch(nutritionProvider);
    final dishes = ref.watch(dishesProvider);

    final cookedThisWeek = dishes
        .expand((d) => d.cooks)
        .where((k) => DateTime.now().difference(k.cookedAt).inDays < 7)
        .length;

    final latest = dishes.firstWhere(
      (d) => d.cooks.isNotEmpty,
      orElse: () => dishes.first,
    );

    final kcalDelta = latest.versions.length > 1
        ? latest.versions.last.kcal - latest.baselineKcal
        : 0;
    final proteinDelta = latest.versions.length > 1
        ? latest.versions.last.protein - latest.baselineProtein
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition lens', style: ShokuType.h1.copyWith(color: c.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ShokuSpace.lg,
          ShokuSpace.sm,
          ShokuSpace.lg,
          ShokuSpace.xxxl,
        ),
        children: [
          // ---- Targets ------------------------------------------------
          ShokuSurface(
            padding: const EdgeInsets.all(ShokuSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShokuLabel('per home-cooked meal'),
                    const Spacer(),
                    ShokuChip(profile.goal, color: c.accent, filled: true),
                  ],
                ),
                const SizedBox(height: ShokuSpace.md),
                Row(
                  children: [
                    Expanded(child: ShokuStat('${profile.kcalTarget}', label: 'kcal/day')),
                    Expanded(child: ShokuStat('${profile.proteinTarget}g', label: 'protein')),
                    Expanded(child: ShokuStat('${profile.fibreTarget}g', label: 'fibre')),
                  ],
                ),
                const SizedBox(height: ShokuSpace.md),
                Text(
                  'Targets are for the day, not per plate. Shoku shows how a cook fits, not what you had for lunch.',
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShokuSpace.md),

          // ---- Version diff -------------------------------------------
          ShokuSurface(
            padding: const EdgeInsets.all(ShokuSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShokuLabel('your tweaks vs the original'),
                const SizedBox(height: ShokuSpace.xs),
                Text(
                  latest.title,
                  style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                ),
                const SizedBox(height: ShokuSpace.sm),
                Text(
                  '${kcalDelta >= 0 ? '+' : ''}$kcalDelta kcal · '
                  '${proteinDelta >= 0 ? '+' : ''}$proteinDelta g protein per serving',
                  style: ShokuType.stat.copyWith(
                    fontSize: 15,
                    color: kcalDelta <= 0 ? c.ready : c.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  kcalDelta <= 0
                      ? 'Your version is lighter than the reel’s.'
                      : 'Your version is richer than the reel’s.',
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShokuSpace.md),

          // ---- Goal ---------------------------------------------------
          ShokuSurface(
            padding: const EdgeInsets.all(ShokuSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShokuLabel('goal'),
                    const Spacer(),
                    Text(
                      '${profile.weightKg} kg · BMI ${profile.bmi.toStringAsFixed(1)}',
                      style: ShokuType.stat.copyWith(fontSize: 11, color: c.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: ShokuSpace.sm),
                Text(
                  switch (profile.goal) {
                    'lose' => 'Losing slowly — the safest rate you can keep.',
                    'gain' => 'Gaining — leaning on protein at every meal.',
                    _ => 'Maintaining. Your cooking is holding the line.',
                  },
                  style: ShokuType.body.copyWith(color: c.ink),
                ),
                const SizedBox(height: ShokuSpace.md),
                ShokuChip('no weigh-ins yet', icon: Icons.monitor_weight_outlined),
                const SizedBox(height: ShokuSpace.xs),
                Text(
                  'Weight is optional and weekly. If you never weigh in, Shoku falls back to intake consistency and stops asking.',
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShokuSpace.md),

          // ---- Week ---------------------------------------------------
          ShokuSurface(
            padding: const EdgeInsets.all(ShokuSpace.md),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShokuStat('$cookedThisWeek', label: 'home cooks this week', hero: true),
                    const SizedBox(height: ShokuSpace.xs),
                    Text(
                      cookedThisWeek < 3
                          ? 'That is a partial picture — useful, not a verdict.'
                          : 'Enough dinners to see a pattern.',
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: ShokuSpace.xl),
          ShokuPressable(
            onTap: () => context.push('/nutrition/setup'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.hairline),
              ),
              child: Center(
                child: Text('Edit body details',
                    style: ShokuType.title.copyWith(color: c.ink, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
