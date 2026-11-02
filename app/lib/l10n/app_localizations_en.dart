// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle =>
      'Shoku in your language. You can change this later in You.';

  @override
  String get languageSystem => 'System language';

  @override
  String get languageSystemHint => 'Follows this phone';

  @override
  String get languageTapToContinue => 'Tap a language to continue';
}
