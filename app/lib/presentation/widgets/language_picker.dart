import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/shoku_theme.dart';
import '../../l10n/languages.dart';
import '../state/locale_provider.dart';

/// The language list, everywhere it appears: onboarding step zero and the
/// You → Language sheet. Tapping a row both applies and persists the choice,
/// so neither caller can forget half of it.
class LanguagePicker extends ConsumerWidget {
  /// Called after the locale has been applied and written to prefs.
  final ValueChanged<Locale?>? onSelected;

  /// Onboarding shows "System language" first; a sheet does too. Kept
  /// overridable so a future "app language only" list never has to fork.
  final bool includeSystem;

  const LanguagePicker({
    super.key,
    this.onSelected,
    this.includeSystem = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(localeProvider);

    final options = <_LanguageOption>[
      if (includeSystem)
        _LanguageOption(
          locale: null,
          label: l10n.languageSystem,
          hint: l10n.languageSystemHint,
        ),
      for (final language in shokuLanguages)
        _LanguageOption(locale: language.locale, label: language.nativeName),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 300;
        final columns = twoColumns ? 2 : 1;
        const gap = ShokuSpace.sm;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final option in options)
              SizedBox(
                width: width,
                child: _LanguageTile(
                  option: option,
                  selected:
                      current?.languageCode == option.locale?.languageCode,
                  onTap: () async {
                    await ref
                        .read(localeProvider.notifier)
                        .setLocale(option.locale);
                    onSelected?.call(option.locale);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LanguageOption {
  final Locale? locale;
  final String label;
  final String? hint;

  const _LanguageOption({
    required this.locale,
    required this.label,
    this.hint,
  });
}

class _LanguageTile extends StatelessWidget {
  final _LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md),
          decoration: BoxDecoration(
            color: selected ? c.accentSoft : c.surface,
            borderRadius: BorderRadius.circular(ShokuRadius.chip),
            border: Border.all(
              color: selected ? c.accent : c.hairline,
              width: selected ? ShokuStroke.brutal : ShokuStroke.hairline,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ShokuType.title.copyWith(
                        color: selected ? c.accent : c.ink,
                        fontSize: 14,
                      ),
                    ),
                    if (option.hint != null)
                      Text(
                        option.hint!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ShokuType.bodySmall.copyWith(
                          color: selected ? c.accent : c.inkMuted,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle, size: 16, color: c.accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The same picker, in a sheet, for the You tab. Closing on selection keeps the
/// change feeling immediate: the app behind the sheet is already redrawn.
Future<void> showLanguagePickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ShokuSpace.lg,
            ShokuSpace.lg,
            ShokuSpace.lg,
            ShokuSpace.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.languageTitle,
                style: ShokuType.h2.copyWith(color: sheetContext.colors.ink),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.languageSubtitle,
                style: ShokuType.bodySmall
                    .copyWith(color: sheetContext.colors.inkMuted),
              ),
              const SizedBox(height: ShokuSpace.lg),
              LanguagePicker(
                onSelected: (_) => Navigator.of(sheetContext).maybePop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
