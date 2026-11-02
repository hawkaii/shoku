// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSubtitle =>
      'Shoku dans votre langue. Vous pouvez la changer plus tard dans Vous.';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get languageSystemHint => 'Suit le téléphone';

  @override
  String get languageTapToContinue => 'Touchez une langue pour continuer';
}
