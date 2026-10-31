import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/prefs.dart';
import '../../state/journal_providers.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/controls.dart';
import '../../widgets/kit/feedback.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import 'sign_in_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final cooks = ref.watch(totalCooksProvider);
    final upgrades = ref.watch(totalUpgradesProvider);
    final signature = ref.watch(signatureCountProvider);
    final mode = ref.watch(themeModeProvider);

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
          const ShokuLabel('account'),
          const SizedBox(height: ShokuSpace.sm),
          const _AccountRow(),

          const SizedBox(height: ShokuSpace.lg),
          const ShokuLabel('nutrition'),
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
          const ShokuLabel('appearance'),
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
            icon: Icons.menu_book_outlined,
            title: 'How Shoku works',
            subtitle: 'The share gesture, in three steps',
            onTap: () async {
              await Prefs.setOnboardingDone(false);
              ref.read(onboardingDoneProvider.notifier).state = false;
            },
          ),
          const ShokuHairline(),
          ShokuListRow(
            icon: Icons.help_outline,
            title: 'Help & feedback',
            onTap: () => context.push('/help'),
          ),
          const ShokuHairline(),
          ShokuListRow(
            icon: Icons.delete_outline,
            title: 'Reset journal',
            showChevron: false,
            onTap: () {},
          ),
          const SizedBox(height: ShokuSpace.xl),
          Center(
            child: Text(
              'Shoku · evening kitchen',
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


/// Signed in, or a way to sign in — the one place auth surfaces in the app.
class _AccountRow extends StatelessWidget {
  const _AccountRow();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final auth = AuthService();
    return StreamBuilder(
      stream: auth.changes,
      builder: (context, _) {
        final session = auth.session;
        final email = session?.user.email ?? '';
        return Container(
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
                    Text(
                      session == null ? 'Not signed in' : 'Signed in',
                      style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session == null
                          ? 'Cooks live on this phone only.'
                          : email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ShokuSpace.sm),
              if (session == null)
                ShokuPressable(
                  onTap: () => showSignInSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: c.ink,
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                    ),
                    child: Text('Sign in',
                        style: ShokuType.label.copyWith(color: c.canvas)),
                  ),
                )
              else
                TextButton(
                  onPressed: () => AuthService().signOut(),
                  child: Text('Sign out',
                      style: ShokuType.label.copyWith(color: c.inkMuted)),
                ),
            ],
          ),
        );
      },
    );
  }
}
