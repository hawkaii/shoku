// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get languageTitle => 'भाषा';

  @override
  String get languageSubtitle =>
      'शोकु आपकी भाषा में। आप इसे बाद में \"आप\" में बदल सकते हैं।';

  @override
  String get languageSystem => 'सिस्टम भाषा';

  @override
  String get languageSystemHint => 'फ़ोन की भाषा के अनुसार';

  @override
  String get languageTapToContinue => 'जारी रखने के लिए कोई भाषा चुनें';
}
