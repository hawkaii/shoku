import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/failure_log.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/prefs.dart';
import '../../../l10n/languages.dart';
import '../../state/account_providers.dart';
import '../../state/auth_providers.dart';
import '../../state/journal_providers.dart';
import '../../state/journal_store.dart';
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
                          style: ShokuType.title
                              .copyWith(color: c.ink, fontSize: 14)),
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
            selected: mode == ThemeMode.system
                ? 0
                : (mode == ThemeMode.light ? 1 : 2),
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

  const _StatBlock(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuSurface(
      padding: const EdgeInsets.symmetric(vertical: ShokuSpace.md),
      child: Column(
        children: [
          ShokuNumberRoll(
              value: value, style: ShokuType.statHero.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(),
              style: ShokuType.label.copyWith(color: c.inkMuted)),
        ],
      ),
    );
  }
}

/// Signed in, or a way to sign in — the one place auth surfaces in the app.
class _AccountRow extends ConsumerStatefulWidget {
  const _AccountRow();

  @override
  ConsumerState<_AccountRow> createState() => _AccountRowState();
}

class _AccountRowState extends ConsumerState<_AccountRow> {
  /// Cached once. A stream built in `build` re-subscribes on every rebuild and
  /// can miss the event that arrived between the old and new subscription.
  late final Stream<ShokuAuthEvent> _changes;

  @override
  void initState() {
    super.initState();
    _changes = ref.read(authServiceProvider).events;
  }

  Future<void> _signIn() async {
    final signedIn = await showSignInSheet(context);
    // The session is live before the stream event reaches this row; read it
    // now rather than waiting for a second frame of the right answer.
    if (signedIn && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final auth = ref.watch(authServiceProvider);
    return StreamBuilder<ShokuAuthEvent>(
      stream: _changes,
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
                      session == null
                          ? l10n.authNotSignedIn
                          : l10n.authSignedIn,
                      style:
                          ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session == null ? l10n.authLocalOnly : email,
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
                  onTap: _signIn,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: c.ink,
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                    ),
                    child: Text(l10n.authSignIn,
                        style: ShokuType.label.copyWith(color: c.canvas)),
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => auth.signOut(),
                      child: Text(l10n.authSignOut,
                          style: ShokuType.label.copyWith(color: c.inkMuted)),
                    ),
                    const _DeleteAccountButton(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Deletes the account for real: the server erases its rows, the device erases
/// its copy, and the app signs out. Play looks for exactly this control.
class _DeleteAccountButton extends ConsumerStatefulWidget {
  const _DeleteAccountButton();

  @override
  ConsumerState<_DeleteAccountButton> createState() =>
      _DeleteAccountButtonState();
}

class _DeleteAccountButtonState extends ConsumerState<_DeleteAccountButton> {
  bool _busy = false;

  Future<void> _confirmAndDelete(BuildContext context) async {
    final l10n = context.l10n;
    final colours = context.colors;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: colours.canvas,
        title: Text(l10n.accountDelete, style: ShokuType.h2),
        content: Text(l10n.accountDeleteBody, style: ShokuType.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.accountDeleteCancel),
          ),
          TextButton(
            key: const ValueKey('account-delete-confirm'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.accountDelete,
                style: ShokuType.label.copyWith(color: colours.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(accountServiceProvider).deleteAccount();
      await ref.read(databaseProvider).wipe();
      await ref.read(authServiceProvider).signOut();
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountDeleteDone)));
    } catch (error, stack) {
      // The snackbar already says the delete failed; the log says which step.
      logFailure('account delete', error, stack);
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountDeleteFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextButton(
      key: const ValueKey('account-delete'),
      onPressed: _busy ? null : () => _confirmAndDelete(context),
      child: Text(
        context.l10n.accountDelete,
        style: ShokuType.label.copyWith(color: c.danger),
      ),
    );
  }
}
