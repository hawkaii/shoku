// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle =>
      'Shoku en tu idioma. Puedes cambiarlo más tarde en Tú.';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get languageSystemHint => 'Sigue el idioma del teléfono';

  @override
  String get languageTapToContinue => 'Toca un idioma para continuar';
}
