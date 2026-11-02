// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get languageTitle => 'ভাষা';

  @override
  String get languageSubtitle =>
      'শোকু আপনার ভাষায়। আপনি পরে \"আপনি\" অংশে এটি বদলাতে পারেন।';

  @override
  String get languageSystem => 'সিস্টেম ভাষা';

  @override
  String get languageSystemHint => 'ফোনের ভাষা অনুসরণ করে';

  @override
  String get languageTapToContinue => 'চালিয়ে যেতে একটি ভাষা বেছে নিন';
}
