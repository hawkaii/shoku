import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/prefs.dart';
import '../../../l10n/languages.dart';
import '../../state/journal_providers.dart';
import '../../state/locale_provider.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/controls.dart';
import '../../widgets/kit/feedback.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/language_picker.dart';
import 'sign_in_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l10n = context.l10n;
    final cooks = ref.watch(totalCooksProvider);
    final upgrades = ref.watch(totalUpgradesProvider);
    final signature = ref.watch(signatureCountProvider);
    final mode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

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
          Text(l10n.tabYou, style: ShokuType.h1.copyWith(color: c.ink)),
          const SizedBox(height: 2),
          Text(
            l10n.profileSubtitle,
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.lg),

          Row(
            children: [
              Expanded(
                  child: _StatBlock(
                      value: '$cooks',
                      label: l10n.journalCooksLabel(cooks),
                      color: c.ink)),
              const SizedBox(width: ShokuSpace.sm),
              Expanded(
                  child: _StatBlock(
                      value: '$upgrades',
                      label: l10n.journalUpgradesLabel(upgrades),
                      color: c.reward)),
              const SizedBox(width: ShokuSpace.sm),
              Expanded(
                  child: _StatBlock(
                      value: '$signature',
                      label: l10n.badgeSignature,
                      color: c.ready)),
            ],
          ),

          const SizedBox(height: ShokuSpace.lg),
          ShokuLabel(l10n.profileAccount),
          const SizedBox(height: ShokuSpace.sm),
          const _AccountRow(),

          const SizedBox(height: ShokuSpace.lg),
          ShokuLabel(l10n.nutritionTitle),
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
                      Text(l10n.profileComingSoon,
                          style: ShokuType.title.copyWith(color: c.ink, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(
                        l10n.profileNutritionBody,
                        style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: ShokuSpace.sm),
                ShokuChip(l10n.profileSoon, color: c.reward, filled: true),
              ],
            ),
          ),

          const SizedBox(height: ShokuSpace.xl),
          ShokuLabel(l10n.profileAppearance),
          const SizedBox(height: ShokuSpace.sm),
          ShokuSegmented(
            labels: [
              l10n.profileThemeSystem,
              l10n.profileThemeLight,
              l10n.profileThemeDark,
            ],
            selected: mode == ThemeMode.system ? 0 : (mode == ThemeMode.light ? 1 : 2),
            onChanged: (i) => ref.read(themeModeProvider.notifier).state = [
              ThemeMode.system,
              ThemeMode.light,
              ThemeMode.dark,
            ][i],
          ),

          const SizedBox(height: ShokuSpace.sm),
          ShokuListRow(
            icon: Icons.translate,
            title: context.l10n.languageTitle,
            subtitle: locale == null
                ? context.l10n.languageSystem
                : shokuLanguageName(locale) ?? context.l10n.languageSystem,
            onTap: () => showLanguagePickerSheet(context),
          ),

          const SizedBox(height: ShokuSpace.lg),
          ShokuListRow(
            icon: Icons.menu_book_outlined,
            title: l10n.profileHowItWorks,
            subtitle: l10n.profileHowItWorksBody,
            onTap: () async {
              await Prefs.setOnboardingDone(false);
              ref.read(onboardingDoneProvider.notifier).state = false;
            },
          ),
          const ShokuHairline(),
          ShokuListRow(
            icon: Icons.help_outline,
            title: l10n.helpTitle,
            onTap: () => context.push('/help'),
          ),
          const ShokuHairline(),
          ShokuListRow(
            icon: Icons.delete_outline,
            title: l10n.profileResetJournal,
            showChevron: false,
            onTap: () {},
          ),
          const SizedBox(height: ShokuSpace.xl),
          Center(
            child: Text(
              l10n.profileFooter,
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
    final l10n = context.l10n;
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
                      session == null ? l10n.authNotSignedIn : l10n.authSignedIn,
                      style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session == null
                          ? l10n.authLocalOnly
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
                    child: Text(l10n.authSignIn,
                        style: ShokuType.label.copyWith(color: c.canvas)),
                  ),
                )
              else
                TextButton(
                  onPressed: () => AuthService().signOut(),
                  child: Text(l10n.authSignOut,
                      style: ShokuType.label.copyWith(color: c.inkMuted)),
                ),
            ],
          ),
        );
      },
    );
  }
}
