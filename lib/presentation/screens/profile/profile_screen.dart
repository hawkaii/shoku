import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/services/prefs.dart';
import '../../state/journal_providers.dart';
import '../../state/nutrition_providers.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/controls.dart';
import '../../widgets/kit/feedback.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final cooks = ref.watch(totalCooksProvider);
    final upgrades = ref.watch(totalUpgradesProvider);
    final signature = ref.watch(signatureCountProvider);
    final mode = ref.watch(themeModeProvider);
    final nutrition = ref.watch(nutritionProvider);

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
          Text('You', style: ShokuType.h1.copyWith(color: c.ink)),
          const SizedBox(height: 2),
          Text(
            'The record of what you have actually cooked.',
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.lg),

          Row(
            children: [
              Expanded(child: _StatBlock(value: '$cooks', label: 'cooks', color: c.ink)),
              const SizedBox(width: ShokuSpace.sm),
              Expanded(child: _StatBlock(value: '$upgrades', label: 'upgrades', color: c.reward)),
              const SizedBox(width: ShokuSpace.sm),
              Expanded(child: _StatBlock(value: '$signature', label: 'signature', color: c.ready)),
            ],
          ),

          const SizedBox(height: ShokuSpace.lg),
          ShokuLabel('nutrition'),
          const SizedBox(height: ShokuSpace.sm),
          Container(
            padding: const EdgeInsets.all(ShokuSpace.md),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(ShokuRadius.card),
              border: Border.all(color: c.hairline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coming soon',
                          style: ShokuType.title.copyWith(color: c.ink, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(
                        'A future lens on how your versions change a dish.',
                        style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: ShokuSpace.sm),
                ShokuChip('soon', color: c.reward, filled: true),
              ],
            ),
          ),

          const SizedBox(height: ShokuSpace.xl),
          ShokuLabel('appearance'),
          const SizedBox(height: ShokuSpace.sm),
          ShokuSegmented(
            labels: const ['SYSTEM', 'LIGHT', 'DARK'],
            selected: mode == ThemeMode.system ? 0 : (mode == ThemeMode.light ? 1 : 2),
            onChanged: (i) => ref.read(themeModeProvider.notifier).state = [
              ThemeMode.system,
              ThemeMode.light,
              ThemeMode.dark,
            ][i],
          ),

          const SizedBox(height: ShokuSpace.lg),
          ShokuListRow(
            icon: Icons.add_link,
            title: 'Import a recipe',
            subtitle: 'Paste a reel or a link',
            onTap: () {},
          ),
          ShokuHairline(),
          ShokuListRow(
            icon: Icons.menu_book_outlined,
            title: 'How Shoku works',
            subtitle: 'The share gesture, in three steps',
            onTap: () async {
              await Prefs.setOnboardingDone(false);
              ref.read(onboardingDoneProvider.notifier).state = false;
            },
          ),
          ShokuHairline(),
          ShokuListRow(
            icon: Icons.help_outline,
            title: 'Help & feedback',
            onTap: () => context.push('/help'),
          ),
          ShokuHairline(),
          ShokuListRow(
            icon: Icons.delete_outline,
            title: 'Reset journal',
            showChevron: false,
            onTap: () {},
          ),
          const SizedBox(height: ShokuSpace.xl),
          Center(
            child: Text(
              'Shoku 1.1.0 · kitchen ticket',
              style: ShokuType.label.copyWith(color: c.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBlock({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuSurface(
      padding: const EdgeInsets.symmetric(vertical: ShokuSpace.md),
      child: Column(
        children: [
          ShokuNumberRoll(value: value, style: ShokuType.statHero.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(), style: ShokuType.label.copyWith(color: c.inkMuted)),
        ],
      ),
    );
  }
}
