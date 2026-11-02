import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// `context.l10n.languageTitle` instead of `AppLocalizations.of(context)` at
/// every call site. The generated getter is non-null because l10n.yaml sets
/// `nullable-getter: false`.
///
/// Widgets also get an English fallback: unit and widget tests pump fragments
/// in a bare `MaterialApp`, and a fragment is not the place to discover that
/// the app forgot its delegates. The real app always has them.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      lookupAppLocalizations(const Locale('en'));
}
