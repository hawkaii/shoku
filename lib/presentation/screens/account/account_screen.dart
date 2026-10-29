import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/controls.dart';
import '../../widgets/kit/feedback.dart';
import '../../widgets/kit/foundation.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final name = ref.watch(profileNameProvider);
    final handle = ref.watch(profileHandleProvider);
    final saves = ref.watch(savesBalanceProvider);
    final used = ref.watch(weeklySavesUsedProvider);
    final streak = ref.watch(streakDaysProvider);
    final level = ref.watch(levelProvider);
    final xp = ref.watch(xpProvider);
    final xpNext = ref.watch(xpToNextProvider);
    final mode = ref.watch(themeModeProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          ShokuSpace.lg,
          ShokuSpace.sm,
          ShokuSpace.lg,
          ShokuSpace.xxl,
        ),
        children: [
          Text('Account', style: ShokuType.h1.copyWith(color: c.ink)),
          const SizedBox(height: ShokuSpace.lg),

          // ---- Identity ------------------------------------------------
          ShokuSurface(
            padding: const EdgeInsets.all(ShokuSpace.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(ShokuRadius.chip),
                    border: Border.all(color: c.hairline, width: ShokuStroke.hairline),
                  ),
                  child: Center(
                    child: Text(
                      name.characters.first.toUpperCase(),
                      style: ShokuType.h2.copyWith(color: c.ink),
                    ),
                  ),
                ),
                const SizedBox(width: ShokuSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: ShokuType.title.copyWith(color: c.ink)),
                      Text(handle, style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                    ],
                  ),
                ),
                ShokuBrassHud(streak: streak, level: level),
              ],
            ),
          ),

          const SizedBox(height: ShokuSpace.md),

          // ---- Saves balance -------------------------------------------
          ShokuSurface(
            padding: const EdgeInsets.all(ShokuSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShokuStat('$saves', label: 'saves left', hero: true, color: c.ink),
                    const Spacer(),
                    Text(
                      'free plan',
                      style: ShokuType.label.copyWith(color: c.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: ShokuSpace.md),
                ShokuProgress(value: used / 7, color: c.accent),
                const SizedBox(height: ShokuSpace.xs),
                Row(
                  children: [
                    Text(
                      "this week's free",
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                    ),
                    const Spacer(),
                    Text(
                      '$used / 7',
                      style: ShokuType.stat.copyWith(fontSize: 12, color: c.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: ShokuSpace.md),
                ShokuButton(
                  'Get more saves',
                  icon: Icons.bolt,
                  small: true,
                  onPressed: () => context.push('/saves'),
                ),
              ],
            ),
          ),

          const SizedBox(height: ShokuSpace.md),

          // ---- Level ---------------------------------------------------
          ShokuSurface(
            padding: const EdgeInsets.all(ShokuSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShokuLabel('level $level · confident cook'),
                    const Spacer(),
                    Text(
                      '$xp / $xpNext xp',
                      style: ShokuType.stat.copyWith(fontSize: 12, color: c.reward),
                    ),
                  ],
                ),
                const SizedBox(height: ShokuSpace.sm),
                ShokuProgress(value: xp / xpNext, color: c.reward),
                const SizedBox(height: ShokuSpace.xs),
                Text(
                  '${((xpNext - xp) / 40).ceil()} more recipes to level ${level + 1}',
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
              ],
            ),
          ),

          const SizedBox(height: ShokuSpace.xl),

          // ---- Appearance ----------------------------------------------
          ShokuLabel('appearance'),
          const SizedBox(height: ShokuSpace.sm),
          ShokuSegmented(
            labels: const ['SYSTEM', 'LIGHT', 'DARK'],
            selected: mode == ThemeMode.system
                ? 0
                : mode == ThemeMode.light
                    ? 1
                    : 2,
            onChanged: (i) => ref.read(themeModeProvider.notifier).state = [
              ThemeMode.system,
              ThemeMode.light,
              ThemeMode.dark,
            ][i],
          ),

          const SizedBox(height: ShokuSpace.lg),

          // ---- Rows ----------------------------------------------------
          ShokuListRow(
            icon: Icons.camera_alt_outlined,
            title: 'Link Instagram',
            subtitle: 'Save reels by sending a DM',
            onTap: () {},
          ),
          ShokuHairline(),
          ShokuListRow(
            icon: Icons.play_circle_outline,
            title: 'View onboarding',
            subtitle: 'See the share flow again',
            onTap: () {
              ref.read(onboardingDoneProvider.notifier).state = false;
            },
          ),
          ShokuHairline(),
          ShokuListRow(
            icon: Icons.bolt,
            title: 'Saves & plan',
            subtitle: '$saves saves remaining',
            onTap: () => context.push('/saves'),
          ),
          ShokuHairline(),
          ShokuListRow(
            icon: Icons.help_outline,
            title: 'Help & feedback',
            onTap: () => context.push('/help'),
          ),
          ShokuHairline(),
          ShokuListRow(
            icon: Icons.logout,
            title: 'Sign out',
            showChevron: false,
            onTap: () {},
          ),

          const SizedBox(height: ShokuSpace.xl),
          Center(
            child: Text(
              'Shoku 1.0.0 · kitchen ticket',
              style: ShokuType.label.copyWith(color: c.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
