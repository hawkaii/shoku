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

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingStartCooking => 'Empezar a cocinar';

  @override
  String get onboardingShareCta => 'Comparte un reel para probarlo';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingOpenJournal => 'Abrir mi diario';

  @override
  String get onboardingIntroTitle => 'Cocínalo una vez.\nHazlo tuyo.';

  @override
  String get onboardingIntroBody =>
      'Cada vez que cocinas, cambias algo. Shoku recuerda esos cambios para que la próxima vez elijas la versión que encaja esta noche.';

  @override
  String get onboardingShareStepLabel => '01 · COMPARTE EL REEL';

  @override
  String get onboardingShareTitle =>
      'Un toque, desde la app en la que ya estás.';

  @override
  String get onboardingShareTo => 'Compartir con';

  @override
  String get onboardingSaved => 'Guardado como v1 · extraído en 4 segundos';

  @override
  String get onboardingJournalStepLabel => '02 · CUÉCINALO, CÁMBIALO';

  @override
  String get onboardingJournalTitle => 'Tu diario recuerda los cambios.';

  @override
  String get onboardingJournalBody =>
      'El modo cocina te guía. Cuando cambies algo, dilo. Al final obtienes una versión: con foto, valoración y lo que cambió.';

  @override
  String get onboardingAltered => 'modificado';

  @override
  String get onboardingTap => 'TOCA';

  @override
  String get authSheetTitle => 'Guarda tu diario';

  @override
  String get authSheetBody =>
      'Las cocinas se quedan en este teléfono hasta que inicies sesión. Al iniciar sesión estarán en todos tus dispositivos.';

  @override
  String get authEmail => 'Correo';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authWorking => 'Procesando…';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authHaveAccount => 'Ya tengo una cuenta';

  @override
  String get authCreateAccountLink => 'Crear una cuenta';

  @override
  String get authErrorEmailPassword =>
      'Correo y una contraseña de 6+ caracteres';

  @override
  String get authErrorConfirmEmail =>
      'Revisa tu correo para confirmar y luego inicia sesión';

  @override
  String get authErrorMismatch => 'Ese correo y esa contraseña no coinciden';

  @override
  String get authErrorUnconfirmed =>
      'Esa cuenta aún no está confirmada; revisa tu correo';

  @override
  String get authErrorExists => 'Ese correo ya tiene cuenta; inicia sesión';

  @override
  String get authErrorNoConnection => 'Sin conexión';

  @override
  String get authErrorGeneric => 'No se pudo iniciar sesión';

  @override
  String get authNotSignedIn => 'Sin sesión';

  @override
  String get authSignedIn => 'Sesión iniciada';

  @override
  String get authLocalOnly => 'Las cocinas viven solo en este teléfono.';

  @override
  String get authSignOut => 'Cerrar sesión';
}
