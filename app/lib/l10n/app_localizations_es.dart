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
      'Las cocciones se quedan en este teléfono hasta que inicies sesión. Al iniciar sesión estarán en todos tus dispositivos.';

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
      'Esa cuenta aún no está confirmada — revisa tu correo';

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
  String get authLocalOnly => 'Las cocciones viven solo en este teléfono.';

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
      'Aún no hay platos — importa un reel para empezar';

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
      'YouTube está bloqueando nuestro servidor ahora — inténtalo más tarde o pega la receta';

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
  String get reasonInvalidRecipe => 'No encontramos una receta en ese vídeo';

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

  @override
  String get pantryTitle => 'Nevera';

  @override
  String pantryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
      zero: 'sin artículos',
    );
    return '$_temp0';
  }

  @override
  String pantrySearchHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Busca $count artículos',
      one: 'Busca 1 artículo',
      zero: 'Busca en tu nevera',
    );
    return '$_temp0';
  }

  @override
  String pantrySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
      zero: 'nada seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get pantryEdit => 'Editar';

  @override
  String get pantryShelfLabel => 'cocina con tu nevera';

  @override
  String get pantryToBuy => 'por comprar';

  @override
  String get pantryInFridge => 'en la nevera';

  @override
  String get pantryEmpty =>
      'Aún no hay nada en la nevera. Haz una foto de un recibo o dime qué hay.';

  @override
  String get pantryAddItems => 'Añadir artículos';

  @override
  String get pantryHowMuch => '¿Cuánto?';

  @override
  String get pantryAmountExample => '2 kg';

  @override
  String get pantryCancel => 'Cancelar';

  @override
  String get pantryDone => 'Listo';

  @override
  String get pantryDelete => 'Eliminar';

  @override
  String get pantrySelectItems => 'Elegir artículos';

  @override
  String pantryDeleteCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar $countString',
      one: 'Eliminar 1',
    );
    return '$_temp0';
  }

  @override
  String pantryDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos eliminados',
      one: '1 artículo eliminado',
    );
    return '$_temp0';
  }

  @override
  String get pantrySetAmount => 'poner cantidad';

  @override
  String pantryLessItem(String name) {
    return 'Menos $name';
  }

  @override
  String pantryMoreItem(String name) {
    return 'Más $name';
  }

  @override
  String get shelfEmpty =>
      'Aún no hay sugerencias — añade algunos artículos y cruzaré muros y tus propios platos.';

  @override
  String shelfBuyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count por comprar',
      one: '+1 por comprar',
    );
    return '$_temp0';
  }

  @override
  String shelfScore(int have, int total) {
    final intl.NumberFormat haveNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String haveString = haveNumberFormat.format(have);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$haveString de $totalString';
  }

  @override
  String get pantryEditTitle => 'Editar artículo';

  @override
  String get pantryNameLabel => 'nombre';

  @override
  String get pantryAmountLabel => 'cantidad';

  @override
  String get pantryAmountHelp =>
      'Déjalo en blanco si sabes que lo tienes pero no cuánto.';

  @override
  String pantrySavedAs(String amount) {
    return 'Guardado como $amount';
  }

  @override
  String get pantrySave => 'Guardar';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitTbsp => 'cda';

  @override
  String get unitTsp => 'cdta';

  @override
  String get unitPcs => 'uds';

  @override
  String get unitBunch => 'manojo';

  @override
  String get unitPack => 'paquete';

  @override
  String get pantryAddTitle => 'Añadir a la nevera';

  @override
  String get pantryAddIntro =>
      'Haz una foto de un recibo, di qué hay en la cocina o escríbelo. Nada entra en la nevera hasta que hayas visto la lista.';

  @override
  String get pantryDoorPhoto => 'Foto';

  @override
  String get pantryDoorVoice => 'Voz';

  @override
  String get pantryDoorType => 'Escribir';

  @override
  String get pantryReview => 'Revisar';

  @override
  String get pantryToAdd => 'por añadir';

  @override
  String get pantryAiReading => 'Leyendo el resto…';

  @override
  String get pantryAmountUnknown => 'cantidad desconocida';

  @override
  String pantryCouldNotRead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No se pudo leer ($count)',
      one: 'No se pudo leer (1)',
    );
    return '$_temp0';
  }

  @override
  String pantryConfirmAdd(int checked, int total) {
    final intl.NumberFormat checkedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String checkedString = checkedNumberFormat.format(checked);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Añadir $checkedString de $totalString',
      one: 'Añadir $checkedString de 1',
    );
    return '$_temp0';
  }

  @override
  String get pantryNoteOffline =>
      'El lector de recibos necesita conexión. Escríbelo o dilo.';

  @override
  String get pantryNoteUnreadable =>
      'No se pudo leer nada en esa foto; escríbelo.';

  @override
  String get pantryCapReached => 'Lecturas de IA agotadas por hoy; escríbelos.';

  @override
  String get pantryPhotoButton => 'Foto o captura';

  @override
  String get pantryPhotoHint =>
      'Haz una foto de un recibo y el lector lo escribe. Nada entra en la nevera hasta que hayas visto la lista.';

  @override
  String get pantryReadingReceipt => 'Leyendo el recibo…';

  @override
  String get pantryBackTooltip => 'Volver a la nevera';

  @override
  String get pantryTypeHint => '2 kg de arroz, uno por línea';

  @override
  String get pantryVoiceHint => 'Mantén el micro y di qué hay en la cocina';

  @override
  String get pantryWhatIsIt => '¿Qué es?';

  @override
  String get pantryVisionTitle => 'El lector usa el modelo de Meta';

  @override
  String get pantryVisionBody =>
      'La foto se envía al modelo de Meta para leerla. Se usa solo para esa llamada y no se guarda. Las líneas aparecen en la revisión de abajo, donde puedes corregir lo que quieras antes de que entre en la nevera.';

  @override
  String get pantryGotIt => 'Entendido';

  @override
  String get pantryScreenshotOrPhoto => 'Captura o foto';

  @override
  String get pantryCamera => 'Cámara';

  @override
  String pantryInFridgeSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos en la nevera',
      one: '1 artículo en la nevera',
    );
    return '$_temp0';
  }

  @override
  String get botNoDish => 'Sin plato';

  @override
  String get botDishFallback => 'Plato';

  @override
  String botCookingStep(int step, int total) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Cocinando · paso $stepString de $totalString';
  }

  @override
  String get botTalkAbout => 'Hablar sobre…';

  @override
  String get botThisDish => 'Este plato';

  @override
  String get botNoDishKitchen => 'Sin plato — la cocina';

  @override
  String get botOpen => 'Abrir';

  @override
  String get botMinimise => 'Minimizar';

  @override
  String get botNewChat => 'Chat nuevo';

  @override
  String get botThinking => 'PENSANDO';

  @override
  String get botOfflineLine =>
      'El asistente necesita conexión. Nada se responde sin conexión.';

  @override
  String get botAskKitchen => 'Pregunta sobre la cocina…';

  @override
  String botAskDish(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Pregunta sobre este plato · v$versionString';
  }

  @override
  String get botOutOfQuestions => 'Sin preguntas por hoy';

  @override
  String get botNoConnection => 'Sin conexión';

  @override
  String get botCapNotice => 'Has usado las preguntas de hoy. Vuelven mañana.';

  @override
  String get botOfflineNotice =>
      'El asistente necesita una conexión. Aquí nada se responde sin conexión.';

  @override
  String botWhichDish(String choices) {
    return '¿Qué plato querías decir? $choices';
  }

  @override
  String botAddedToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos en la nevera.',
      one: '1 artículo en la nevera.',
    );
    return '$_temp0';
  }

  @override
  String get botDestructiveRefusal =>
      'No puedo cambiar tu diario desde aquí. Abre el plato (o su menú ⋯) y el flujo real lo hará.';

  @override
  String botAddMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Añadir $count faltantes',
      one: 'Añadir 1 faltante',
    );
    return '$_temp0';
  }

  @override
  String botAddedToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos añadidos a tu lista',
      one: '1 artículo añadido a tu lista',
    );
    return '$_temp0';
  }

  @override
  String get botNotThis => 'No es este';

  @override
  String get botAddToFridgeQuestion => '¿Añadir a la nevera?';

  @override
  String botAddCountToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Añadir $count artículos a la nevera',
      one: 'Añadir 1 artículo a la nevera',
    );
    return '$_temp0';
  }

  @override
  String get botAmountUnknown => '¿cantidad?';

  @override
  String botSuggestionMeta(String source, int have, int total) {
    final intl.NumberFormat haveNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String haveString = haveNumberFormat.format(have);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$source · $haveString de $totalString';
  }

  @override
  String get botStarterFridge => '¿Qué hay en tu nevera?';

  @override
  String get botStarterWall => 'Muéstrame algo del Muro';

  @override
  String get botStarterPhoto => 'Tengo una foto de un plato';

  @override
  String botStarterDinner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tienes $count cosas en la nevera. ¿Cena con ellas?',
      one: 'Tienes 1 cosa en la nevera. ¿Cena con ella?',
    );
    return '$_temp0';
  }

  @override
  String chatEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostrar anteriores ($count)',
      one: 'Mostrar anterior (1)',
    );
    return '$_temp0';
  }

  @override
  String chatAboutStep(int step) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'sobre el paso $stepString';
  }

  @override
  String get chatAskHint => 'Pregunta, o mantén el micro';

  @override
  String get chatResolveChange => 'Resuelve el cambio de arriba';

  @override
  String get chatAsk => 'Preguntar';

  @override
  String chatVersionDivider(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString empieza aquí';
  }

  @override
  String chatApplied(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'V$versionString · APLICADO';
  }

  @override
  String chatOpenVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Abrir v$versionString';
  }

  @override
  String get chatUndo => 'Deshacer';

  @override
  String get chatRecipeChange => 'CAMBIO DE RECETA';

  @override
  String chatVersionArrow(int from, int to) {
    final intl.NumberFormat fromNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String fromString = fromNumberFormat.format(from);
    final intl.NumberFormat toNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String toString = toNumberFormat.format(to);

    return 'v$fromString → v$toString';
  }

  @override
  String chatMoreEdits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count más',
      one: '+1 más',
    );
    return '$_temp0';
  }

  @override
  String chatCreatesVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Crea v$versionString — desde este mensaje';
  }

  @override
  String get chatRecompute => 'Recalcular';

  @override
  String get chatDiscard => 'Descartar';

  @override
  String get chatNotApplied => 'NO APLICADO';

  @override
  String get chatNothingChanged => 'Nada cambió en tu receta.';

  @override
  String get chatTryAgain => 'Reintentar';

  @override
  String get chatApplying => 'Aplicando…';

  @override
  String chatApplyAs(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Aplicar como v$versionString';
  }
}
