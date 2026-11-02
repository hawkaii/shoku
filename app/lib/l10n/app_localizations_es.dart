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

  @override
  String get tabJournal => 'Diario';

  @override
  String get tabCookbook => 'Recetario';

  @override
  String get tabFridge => 'Nevera';

  @override
  String get tabWall => 'Muro';

  @override
  String get tabYou => 'Tú';

  @override
  String journalKitchenTitle(String month) {
    return 'Cocina de $month';
  }

  @override
  String journalDishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count platos',
      one: '1 plato',
      zero: 'Aún no hay platos',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mejoras',
      one: '1 mejora',
      zero: 'sin mejoras',
    );
    return '$_temp0';
  }

  @override
  String journalCooksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cocciones',
      one: 'cocción',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mejoras',
      one: 'mejora',
    );
    return '$_temp0';
  }

  @override
  String journalEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas',
      one: '1 entrada',
      zero: 'sin entradas',
    );
    return '$_temp0';
  }

  @override
  String get journalOnTheCounter => 'en el mostrador';

  @override
  String get journalCookLog => 'registro de cocciones';

  @override
  String get journalCook => 'Cocinar';

  @override
  String get journalFirstPage => 'Tu primera página';

  @override
  String get journalFirstPageBody =>
      'Registra una cocción: una foto, cómo salió y una cosa que cambiaste. Eso se convierte en la v1.';

  @override
  String get journalStartJournal => 'Empezar el diario →';

  @override
  String get journalNoDishes =>
      'Aún no hay platos: importa un reel para empezar';

  @override
  String get journalOpening => 'Abriendo tu diario';

  @override
  String get journalErrorTitle => 'No se pudo abrir tu diario';

  @override
  String get journalErrorBody =>
      'Las cocciones guardadas siguen en este teléfono.';

  @override
  String get journalTryAgain => 'Reintentar';

  @override
  String get journalSaveRecipe => 'Guardar una receta';

  @override
  String get cookbookTitle => 'Recetario';

  @override
  String cookbookCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cocinados',
      one: '1 cocinado',
      zero: 'nada cocinado',
    );
    return '$_temp0';
  }

  @override
  String get cookbookToCook => 'Por cocinar';

  @override
  String get cookbookCooked => 'Cocinados';

  @override
  String get cookbookNothingToCook => 'Nada esperando para cocinarse.';

  @override
  String get cookbookNoCooksYet =>
      'Aún no hay cocciones. Elige algo de Por cocinar.';

  @override
  String get cookbookNeverCooked => 'sin cocinar';

  @override
  String cookbookLastCooked(String outcome) {
    return 'última: $outcome';
  }

  @override
  String get badgeToCook => 'POR COCINAR';

  @override
  String get badgeCooked => 'COCINADO';

  @override
  String badgeCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'COCINADO $count×',
      one: 'COCINADO $count×',
    );
    return '$_temp0';
  }

  @override
  String get badgeSignature => 'FIRMA';

  @override
  String get outcomeNailedIt => 'Clavado';

  @override
  String get outcomeGood => 'Bueno';

  @override
  String get outcomeNeedsWork => 'Hay que mejorar';

  @override
  String get moodQuick => 'rápida';

  @override
  String get moodProject => 'proyecto';

  @override
  String get moodComfort => 'reconfortante';

  @override
  String minutesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min',
      one: '1 min',
    );
    return '$_temp0';
  }

  @override
  String get labelSample => 'Muestra';

  @override
  String get addSheetTitle => 'Importar una receta';

  @override
  String get addSheetSubtitle =>
      'Un reel se convierte en un plato que puedes cocinar y versionar.';

  @override
  String get addSheetLinkHint => 'Pega un enlace de Instagram o YouTube';

  @override
  String get addSheetShareOption => 'Compartir desde otra app';

  @override
  String get addSheetShareHint => 'Instagram → compartir → Shoku';

  @override
  String get addSheetScanOption => 'Escanear un código de barras';

  @override
  String get addSheetScanHint => 'Añádelo directo a tu nevera';

  @override
  String get addSheetBackendNote =>
      'La extracción corre en el servidor; esta versión es solo la interfaz.';

  @override
  String get importHeadline => 'Importando un reel';

  @override
  String get importQueued => 'En cola';

  @override
  String get importWaking => 'Despertando la cocina…';

  @override
  String get importWaitingHint => 'El primero tras una pausa tarda un minuto';

  @override
  String get importReadingReel => 'Leyendo el reel';

  @override
  String get importReadingAudio => 'Leyendo el audio';

  @override
  String get importWritingRecipe => 'Escribiendo la receta';

  @override
  String get importWatchingVideo => 'Viendo el vídeo';

  @override
  String get importReadingCaption => 'Leyendo el texto';

  @override
  String get importReady => 'Listo';

  @override
  String get importFailedShort => 'No se pudo leer este';

  @override
  String get reasonUnsupportedUrl =>
      'Ese enlace no es un reel o vídeo que podamos leer';

  @override
  String get reasonSourceBlocked =>
      'YouTube está bloqueando nuestro servidor ahora; inténtalo más tarde o pega la receta';

  @override
  String get reasonTimeout => 'Tardó demasiado; inténtalo otra vez';

  @override
  String get reasonWorkerUnavailable =>
      'La cocina no se despertó; inténtalo en un minuto';

  @override
  String get reasonTimedOut =>
      'Sigue leyendo; puede tardar unos minutos. Puedes irte y el plato estará aquí cuando esté listo';

  @override
  String get reasonGone =>
      'Esa importación ya no está en el servidor; prueba el enlace otra vez';

  @override
  String get reasonInvalidRecipe => 'No encontramos una receta en ese';

  @override
  String get reasonNoAudio => 'Ese vídeo no tiene nada que escuchar';

  @override
  String get reasonNoText => 'Ese reel no tiene texto ni voz que podamos leer';

  @override
  String get reasonNoRecipe => 'Ese vídeo no muestra una receta';

  @override
  String get reasonVisionFailed => 'No pudimos leer ese vídeo; pega la receta';

  @override
  String get reasonTakenDown => 'Esa receta fue eliminada';

  @override
  String get reasonUnknown => 'No se pudo leer este; pega la receta';
}
