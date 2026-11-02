import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// `context.l10n.languageTitle` instead of `AppLocalizations.of(context)` at
/// every call site. The generated getter is non-null because l10n.yaml sets
/// `nullable-getter: false`.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
