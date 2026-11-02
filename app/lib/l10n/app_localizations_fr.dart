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

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingStartCooking => 'Commencer à cuisiner';

  @override
  String get onboardingShareCta => 'Partagez un reel pour essayer';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get onboardingOpenJournal => 'Ouvrir mon journal';

  @override
  String get onboardingIntroTitle => 'Cuisinez-le une fois.\nFaites-le vôtre.';

  @override
  String get onboardingIntroBody =>
      'À chaque cuisson, vous changez quelque chose. Shoku retient ces changements pour que vous choisissiez la version qui convient ce soir.';

  @override
  String get onboardingShareStepLabel => '01 · PARTAGEZ LE REEL';

  @override
  String get onboardingShareTitle =>
      'Un appui, depuis l\'app où vous êtes déjà.';

  @override
  String get onboardingShareTo => 'Partager avec';

  @override
  String get onboardingSaved => 'Enregistré en v1 · extrait en 4 secondes';

  @override
  String get onboardingJournalStepLabel => '02 · CUISINEZ-LE, CHANGEZ-LE';

  @override
  String get onboardingJournalTitle => 'Votre journal retient les changements.';

  @override
  String get onboardingJournalBody =>
      'Le mode cuisine vous guide. Quand vous remplacez quelque chose, dites-le. À la fin, vous obtenez une version : avec une photo, une note et ce qui a changé.';

  @override
  String get onboardingAltered => 'modifié';

  @override
  String get onboardingTap => 'APPUYEZ';

  @override
  String get authSheetTitle => 'Gardez votre journal';

  @override
  String get authSheetBody =>
      'Les cuissons restent sur ce téléphone jusqu\'à votre connexion. Se connecter les met sur tous vos appareils.';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authWorking => 'Traitement…';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authHaveAccount => 'J\'ai déjà un compte';

  @override
  String get authCreateAccountLink => 'Créer un compte';

  @override
  String get authErrorEmailPassword =>
      'E-mail et un mot de passe de 6 caractères ou plus';

  @override
  String get authErrorConfirmEmail =>
      'Vérifiez votre e-mail pour confirmer, puis connectez-vous';

  @override
  String get authErrorMismatch =>
      'Cet e-mail et ce mot de passe ne correspondent pas';

  @override
  String get authErrorUnconfirmed =>
      'Ce compte n\'est pas encore confirmé — vérifiez votre e-mail';

  @override
  String get authErrorExists => 'Cet e-mail a déjà un compte — connectez-vous';

  @override
  String get authErrorNoConnection => 'Pas de connexion';

  @override
  String get authErrorGeneric => 'Connexion impossible';

  @override
  String get authNotSignedIn => 'Non connecté';

  @override
  String get authSignedIn => 'Connecté';

  @override
  String get authLocalOnly => 'Les cuissons ne vivent que sur ce téléphone.';

  @override
  String get authSignOut => 'Se déconnecter';

  @override
  String get tabJournal => 'Journal';

  @override
  String get tabCookbook => 'Recettes';

  @override
  String get tabFridge => 'Frigo';

  @override
  String get tabWall => 'Mur';

  @override
  String get tabYou => 'Vous';

  @override
  String journalKitchenTitle(String month) {
    return 'Cuisine de $month';
  }

  @override
  String journalDishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plats',
      one: '1 plat',
      zero: 'Pas encore de plats',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count améliorations',
      one: '1 amélioration',
      zero: 'pas d\'améliorations',
    );
    return '$_temp0';
  }

  @override
  String journalCooksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cuissons',
      one: 'cuisson',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'améliorations',
      one: 'amélioration',
    );
    return '$_temp0';
  }

  @override
  String journalEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées',
      one: '1 entrée',
      zero: 'pas d\'entrées',
    );
    return '$_temp0';
  }

  @override
  String get journalOnTheCounter => 'sur le comptoir';

  @override
  String get journalCookLog => 'journal des cuissons';

  @override
  String get journalCook => 'Cuisiner';

  @override
  String get journalFirstPage => 'Votre première page';

  @override
  String get journalFirstPageBody =>
      'Enregistrez une cuisson : une photo, le résultat et une chose que vous avez changée. Cela devient la v1.';

  @override
  String get journalStartJournal => 'Commencer le journal →';

  @override
  String get journalNoDishes =>
      'Pas encore de plats — importez un reel pour commencer';

  @override
  String get journalOpening => 'Ouverture de votre journal';

  @override
  String get journalErrorTitle => 'Votre journal n\'a pas pu être ouvert';

  @override
  String get journalErrorBody =>
      'Les cuissons enregistrées sont toujours sur ce téléphone.';

  @override
  String get journalTryAgain => 'Réessayer';

  @override
  String get journalSaveRecipe => 'Enregistrer une recette';

  @override
  String get cookbookTitle => 'Recettes';

  @override
  String cookbookCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cuisinés',
      one: '1 cuisiné',
      zero: 'rien de cuisiné',
    );
    return '$_temp0';
  }

  @override
  String get cookbookToCook => 'À cuisiner';

  @override
  String get cookbookCooked => 'Cuisinés';

  @override
  String get cookbookNothingToCook => 'Rien n\'attend d\'être cuisiné.';

  @override
  String get cookbookNoCooksYet =>
      'Pas encore de cuissons. Choisissez quelque chose dans À cuisiner.';

  @override
  String get cookbookNeverCooked => 'jamais cuisiné';

  @override
  String cookbookLastCooked(String outcome) {
    return 'dernière : $outcome';
  }

  @override
  String get badgeToCook => 'À CUISINER';

  @override
  String get badgeCooked => 'CUISINÉ';

  @override
  String badgeCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'CUISINÉ $count×',
      one: 'CUISINÉ $count×',
    );
    return '$_temp0';
  }

  @override
  String get badgeSignature => 'SIGNATURE';

  @override
  String get outcomeNailedIt => 'Réussi';

  @override
  String get outcomeGood => 'Bien';

  @override
  String get outcomeNeedsWork => 'À revoir';

  @override
  String get moodQuick => 'rapide';

  @override
  String get moodProject => 'projet';

  @override
  String get moodComfort => 'réconfortant';

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
  String get labelSample => 'Exemple';

  @override
  String get addSheetTitle => 'Importer une recette';

  @override
  String get addSheetSubtitle =>
      'Un reel devient un plat que vous pouvez cuisiner et versionner.';

  @override
  String get addSheetLinkHint => 'Collez un lien Instagram ou YouTube';

  @override
  String get addSheetShareOption => 'Partager depuis une autre app';

  @override
  String get addSheetShareHint => 'Instagram → partager → Shoku';

  @override
  String get addSheetScanOption => 'Scanner un code-barres';

  @override
  String get addSheetScanHint => 'Ajoutez-le directement à votre frigo';

  @override
  String get addSheetBackendNote =>
      'L\'extraction tourne sur le serveur — cette version n\'est que l\'interface.';

  @override
  String get importHeadline => 'Importation d\'un reel';

  @override
  String get importQueued => 'En attente';

  @override
  String get importWaking => 'La cuisine se réveille…';

  @override
  String get importWaitingHint => 'Le premier après une pause prend une minute';

  @override
  String get importReadingReel => 'Lecture du reel';

  @override
  String get importReadingAudio => 'Lecture de l\'audio';

  @override
  String get importWritingRecipe => 'Rédaction de la recette';

  @override
  String get importWatchingVideo => 'Visionnage de la vidéo';

  @override
  String get importReadingCaption => 'Lecture du texte';

  @override
  String get importReady => 'Prêt';

  @override
  String get importFailedShort => 'Impossible de lire celui-ci';

  @override
  String get reasonUnsupportedUrl =>
      'Ce lien n\'est pas un reel ou une vidéo que nous pouvons lire';

  @override
  String get reasonSourceBlocked =>
      'YouTube bloque notre serveur en ce moment — réessayez plus tard ou collez la recette';

  @override
  String get reasonTimeout => 'Cela a pris trop de temps — réessayez';

  @override
  String get reasonWorkerUnavailable =>
      'La cuisine ne s\'est pas réveillée — réessayez dans une minute';

  @override
  String get reasonTimedOut =>
      'Toujours en lecture — cela peut prendre quelques minutes. Vous pouvez partir, le plat sera là quand il sera prêt';

  @override
  String get reasonGone =>
      'Cette importation n\'est plus sur le serveur — réessayez le lien';

  @override
  String get reasonInvalidRecipe =>
      'Nous n\'avons pas trouvé de recette dans cette vidéo';

  @override
  String get reasonNoAudio => 'Cette vidéo n\'a rien à écouter';

  @override
  String get reasonNoText =>
      'Ce reel n\'a ni texte ni parole que nous puissions lire';

  @override
  String get reasonNoRecipe => 'Cette vidéo ne montre pas de recette';

  @override
  String get reasonVisionFailed =>
      'Nous n\'avons pas pu lire cette vidéo — collez la recette';

  @override
  String get reasonTakenDown => 'Cette recette a été retirée';

  @override
  String get reasonUnknown => 'Impossible de lire celui-ci — collez la recette';

  @override
  String get pantryTitle => 'Frigo';

  @override
  String pantryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'aucun article',
    );
    return '$_temp0';
  }

  @override
  String pantrySearchHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chercher $count articles',
      one: 'Chercher 1 article',
      zero: 'Cherchez dans votre frigo',
    );
    return '$_temp0';
  }

  @override
  String pantrySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '1 sélectionné',
      zero: 'aucun sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get pantryEdit => 'Modifier';

  @override
  String get pantryShelfLabel => 'cuisinez avec votre frigo';

  @override
  String get pantryToBuy => 'à acheter';

  @override
  String get pantryInFridge => 'dans le frigo';

  @override
  String get pantryEmpty =>
      'Votre frigo est vide. Photographiez un ticket ou dites-moi ce qu\'il contient.';

  @override
  String get pantryAddItems => 'Ajouter des articles';

  @override
  String get pantryHowMuch => 'Combien ?';

  @override
  String get pantryAmountExample => '2 kg';

  @override
  String get pantryCancel => 'Annuler';

  @override
  String get pantryDone => 'Terminé';

  @override
  String get pantryDelete => 'Supprimer';

  @override
  String get pantrySelectItems => 'Choisir des articles';

  @override
  String pantryDeleteCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer $countString',
      one: 'Supprimer 1',
    );
    return '$_temp0';
  }

  @override
  String pantryDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles supprimés',
      one: '1 article supprimé',
    );
    return '$_temp0';
  }

  @override
  String get pantrySetAmount => 'définir la quantité';

  @override
  String pantryLessItem(String name) {
    return 'Moins $name';
  }

  @override
  String pantryMoreItem(String name) {
    return 'Plus $name';
  }

  @override
  String get shelfEmpty =>
      'Rien à suggérer pour l\'instant — ajoutez quelques articles et je croiserai les murs et vos propres plats.';

  @override
  String shelfBuyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count à acheter',
      one: '+1 à acheter',
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

    return '$haveString sur $totalString';
  }

  @override
  String get pantryEditTitle => 'Modifier l\'article';

  @override
  String get pantryNameLabel => 'nom';

  @override
  String get pantryAmountLabel => 'quantité';

  @override
  String get pantryAmountHelp =>
      'Laissez vide si vous savez que vous en avez mais pas combien.';

  @override
  String pantrySavedAs(String amount) {
    return 'Enregistré comme $amount';
  }

  @override
  String get pantrySave => 'Enregistrer';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitTbsp => 'c. à s.';

  @override
  String get unitTsp => 'c. à c.';

  @override
  String get unitPcs => 'pièces';

  @override
  String get unitBunch => 'botte';

  @override
  String get unitPack => 'paquet';

  @override
  String get pantryAddTitle => 'Ajouter au frigo';

  @override
  String get pantryAddIntro =>
      'Photographiez un ticket, dites ce qu\'il y a dans la cuisine ou tapez-le. Rien n\'entre dans le frigo avant que vous ayez vu la liste.';

  @override
  String get pantryDoorPhoto => 'Photo';

  @override
  String get pantryDoorVoice => 'Voix';

  @override
  String get pantryDoorType => 'Saisir';

  @override
  String get pantryReview => 'Vérifier';

  @override
  String get pantryToAdd => 'à ajouter';

  @override
  String get pantryAiReading => 'Lecture du reste…';

  @override
  String get pantryAmountUnknown => 'quantité inconnue';

  @override
  String pantryCouldNotRead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Illisible ($count)',
      one: 'Illisible (1)',
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
      other: 'Ajouter $checkedString sur $totalString',
      one: 'Ajouter $checkedString sur 1',
    );
    return '$_temp0';
  }

  @override
  String get pantryNoteOffline =>
      'Le lecteur de tickets a besoin d\'une connexion. Tapez-le ou dites-le.';

  @override
  String get pantryNoteUnreadable =>
      'Rien de lisible sur cette photo — tapez-le.';

  @override
  String get pantryCapReached =>
      'Lectures IA épuisées pour aujourd\'hui — tapez-les.';

  @override
  String get pantryPhotoButton => 'Photo ou capture';

  @override
  String get pantryPhotoHint =>
      'Photographiez un ticket et le lecteur le tape. Rien n\'entre dans le frigo avant que vous ayez vu la liste.';

  @override
  String get pantryReadingReceipt => 'Lecture du ticket…';

  @override
  String get pantryBackTooltip => 'Retour au frigo';

  @override
  String get pantryTypeHint => '2 kg de riz, un par ligne';

  @override
  String get pantryVoiceHint =>
      'Maintenez le micro et dites ce qu\'il y a dans la cuisine';

  @override
  String get pantryWhatIsIt => 'Qu\'est-ce que c\'est ?';

  @override
  String get pantryVisionTitle => 'Le lecteur utilise le modèle de Meta';

  @override
  String get pantryVisionBody =>
      'La photo est envoyée au modèle de Meta pour être lue. Elle sert à cet appel unique et n\'est pas stockée. Les lignes arrivent dans la vérification ci-dessous, où vous pouvez tout corriger avant qu\'elles entrent dans le frigo.';

  @override
  String get pantryGotIt => 'Compris';

  @override
  String get pantryScreenshotOrPhoto => 'Capture ou photo';

  @override
  String get pantryCamera => 'Appareil photo';

  @override
  String pantryInFridgeSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles dans le frigo',
      one: '1 article dans le frigo',
    );
    return '$_temp0';
  }

  @override
  String get botNoDish => 'Pas de plat';

  @override
  String get botDishFallback => 'Plat';

  @override
  String botCookingStep(int step, int total) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Cuisson · étape $stepString sur $totalString';
  }

  @override
  String get botTalkAbout => 'Parler de…';

  @override
  String get botThisDish => 'Ce plat';

  @override
  String get botNoDishKitchen => 'Pas de plat — la cuisine';

  @override
  String get botOpen => 'Ouvrir';

  @override
  String get botMinimise => 'Réduire';

  @override
  String get botNewChat => 'Nouveau chat';

  @override
  String get botThinking => 'RÉFLEXION';

  @override
  String get botOfflineLine =>
      'L\'assistant a besoin d\'une connexion. Rien n\'est répondu hors ligne.';

  @override
  String get botAskKitchen => 'Posez une question sur la cuisine…';

  @override
  String botAskDish(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Posez une question sur ce plat · v$versionString';
  }

  @override
  String get botOutOfQuestions => 'Plus de questions aujourd\'hui';

  @override
  String get botNoConnection => 'Pas de connexion';

  @override
  String get botCapNotice =>
      'Vous avez utilisé les questions du jour. Elles reviennent demain.';

  @override
  String get botOfflineNotice =>
      'L\'assistant a besoin d\'une connexion. Rien ici n\'est répondu hors ligne.';

  @override
  String botWhichDish(String choices) {
    return 'Quel plat vouliez-vous dire ? $choices';
  }

  @override
  String botAddedToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles dans le frigo.',
      one: '1 article dans le frigo.',
    );
    return '$_temp0';
  }

  @override
  String get botDestructiveRefusal =>
      'Je ne peux pas modifier votre journal d\'ici. Ouvrez le plat (ou son menu ⋯) et le vrai flux le fera.';

  @override
  String botAddMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count manquants',
      one: 'Ajouter 1 manquant',
    );
    return '$_temp0';
  }

  @override
  String botAddedToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles ajoutés à votre liste',
      one: '1 article ajouté à votre liste',
    );
    return '$_temp0';
  }

  @override
  String get botNotThis => 'Pas celui-ci';

  @override
  String get botAddToFridgeQuestion => 'Ajouter au frigo ?';

  @override
  String botAddCountToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count articles au frigo',
      one: 'Ajouter 1 article au frigo',
    );
    return '$_temp0';
  }

  @override
  String get botAmountUnknown => 'quantité ?';

  @override
  String botSuggestionMeta(String source, int have, int total) {
    final intl.NumberFormat haveNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String haveString = haveNumberFormat.format(have);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$source · $haveString sur $totalString';
  }

  @override
  String get botStarterFridge => 'Qu\'y a-t-il dans votre frigo ?';

  @override
  String get botStarterWall => 'Montrez-moi quelque chose du Mur';

  @override
  String get botStarterPhoto => 'J\'ai une photo d\'un plat';

  @override
  String botStarterDinner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous avez $count choses dans le frigo. Un dîner avec ?',
      one: 'Vous avez 1 chose dans le frigo. Un dîner avec ?',
    );
    return '$_temp0';
  }

  @override
  String chatEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Afficher les précédents ($count)',
      one: 'Afficher le précédent (1)',
    );
    return '$_temp0';
  }

  @override
  String chatAboutStep(int step) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'sur l\'étape $stepString';
  }

  @override
  String get chatAskHint => 'Demandez, ou maintenez le micro';

  @override
  String get chatResolveChange => 'Résolvez le changement ci-dessus';

  @override
  String get chatAsk => 'Demander';

  @override
  String chatVersionDivider(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString commence ici';
  }

  @override
  String chatApplied(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'V$versionString · APPLIQUÉ';
  }

  @override
  String chatOpenVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Ouvrir v$versionString';
  }

  @override
  String get chatUndo => 'Annuler';

  @override
  String get chatRecipeChange => 'CHANGEMENT DE RECETTE';

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
      other: '+$count de plus',
      one: '+1 de plus',
    );
    return '$_temp0';
  }

  @override
  String chatCreatesVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Crée v$versionString — depuis ce message';
  }

  @override
  String get chatRecompute => 'Recalculer';

  @override
  String get chatDiscard => 'Écarter';

  @override
  String get chatNotApplied => 'NON APPLIQUÉ';

  @override
  String get chatNothingChanged => 'Rien n\'a changé dans votre recette.';

  @override
  String get chatTryAgain => 'Réessayer';

  @override
  String get chatApplying => 'Application…';

  @override
  String chatApplyAs(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Appliquer comme v$versionString';
  }

  @override
  String get importPasteFirst => 'Collez d\'abord un lien';

  @override
  String get importNoLink =>
      'Le reel est prêt mais le serveur n\'a envoyé aucun lien';

  @override
  String get importCouldNotStart => 'Impossible de lancer cette importation';

  @override
  String get importSignIn => 'Connectez-vous dans Vous pour importer';

  @override
  String get importUnreachable => 'Impossible d\'atteindre le serveur';

  @override
  String get importLostConnection =>
      'Connexion perdue — le reel est toujours en lecture. Rouvrez ceci pour reprendre';

  @override
  String get importStillOnServer =>
      'Impossible d\'atteindre le serveur — le reel y est toujours. Rouvrez ceci pour reprendre';

  @override
  String get importGone =>
      'Ce reel n\'est plus sur le serveur — réessayez le lien';

  @override
  String importSaved(String title) {
    return 'Enregistré $title';
  }

  @override
  String get importNothingToSave => 'Rien à enregistrer';

  @override
  String get importCouldNotSave =>
      'La recette est revenue mais n\'a pas pu être enregistrée — rouvrez ceci';

  @override
  String get importOpenAgain =>
      'Impossible d\'atteindre le serveur — rouvrez ceci dans une minute';

  @override
  String get importSheetTitle => 'Enregistrer un reel';

  @override
  String get importSheetBody =>
      'Collez un lien YouTube ou Instagram. Il devient un plat que vous pouvez cuisiner, avec le créateur attaché.';

  @override
  String get importStillWorking => 'Toujours en cours — ce reel est long';

  @override
  String get importLongWait =>
      'Un long prend quelques minutes. Vous pouvez partir ; le plat apparaît quand il est prêt.';

  @override
  String get importCloseWait =>
      'Vous pouvez fermer ceci ; le plat apparaît quand il est prêt.';

  @override
  String get importReading => 'Lecture…';

  @override
  String get importReadLink => 'Lire ce lien';

  @override
  String get dishSampleGate =>
      'Sign in to import your own reels and talk to the recipe.';

  @override
  String dishCookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cooks',
      one: '1 cook',
    );
    return '$_temp0';
  }

  @override
  String get dishFromVideoNote => 'read from the video — amounts may be off';

  @override
  String dishVersionGone(int from, int to) {
    final intl.NumberFormat fromNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String fromString = fromNumberFormat.format(from);
    final intl.NumberFormat toNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String toString = toNumberFormat.format(to);

    return 'v$fromString is gone — showing v$toString';
  }

  @override
  String get dishStartCookMode => 'Start cook mode';

  @override
  String get dishReadRecipe => 'Read this recipe';

  @override
  String get dishMore => 'More';

  @override
  String get dishMenuCooked => 'I just cooked this';

  @override
  String get dishMarkToCook => 'Mark as to cook';

  @override
  String get dishSetUpFridge => 'Set up your fridge';

  @override
  String dishAddMissingToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count missing to list',
      one: 'Add 1 missing to list',
    );
    return '$_temp0';
  }

  @override
  String dishAddedToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count added to your list',
      one: '1 added to your list',
    );
    return '$_temp0';
  }

  @override
  String dishIngredientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients',
      one: '1 ingredient',
    );
    return '$_temp0';
  }

  @override
  String dishMissingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count missing',
      one: '1 missing',
    );
    return '$_temp0';
  }

  @override
  String get dishPickVersion => 'Pick a version';

  @override
  String dishVersionShowing(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString · showing';
  }

  @override
  String dishStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String dishAskAboutStep(int step) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'Ask about step $stepString';
  }

  @override
  String get dishHistory => 'HISTORY';

  @override
  String get dishNotCookedYet => 'Not cooked yet. The first log becomes v1.';

  @override
  String dishHistoryEntry(int version, String outcome) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString · $outcome';
  }

  @override
  String get dishWhatAltered => 'What altered';

  @override
  String get dishFromChatEdit => 'from a chat edit';

  @override
  String get dishNoNote => 'No note';

  @override
  String get dishUnavailableTitle => 'This dish is not here';

  @override
  String get dishUnavailableBody =>
      'It may still be loading, or it was removed.';

  @override
  String get dishBackToJournal => 'Back to the journal';

  @override
  String get dishImported => 'Imported';

  @override
  String get dishTheSource => 'the source';

  @override
  String get dishViewReel => 'View the reel';

  @override
  String get logTitle => 'Log tonight’s cook';

  @override
  String get logSnapResult => 'SNAP TONIGHT’S RESULT';

  @override
  String get logPhotoReady => 'PHOTO READY TO UPLOAD';

  @override
  String get logHowDidItGo => 'how did it go';

  @override
  String get logNoteLabel => 'a note for you';

  @override
  String get logNoteHint => 'The pan ran hot, so I pulled it early';

  @override
  String get logChangeLabel => 'what did you change';

  @override
  String get logChangeHint => 'More lime, 2 minutes less, air-fried instead';

  @override
  String get logSaveWithPhoto => 'Save with photo';

  @override
  String get logSaveTonight => 'Save tonight';

  @override
  String logSaveUpgrade(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Save & upgrade to v$versionString';
  }

  @override
  String get logSaveFailed => 'Could not save that cook';

  @override
  String logSaved(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Logged as v$versionString';
  }

  @override
  String logSavedWithOutcome(int version, String outcome) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Logged as v$versionString · $outcome';
  }

  @override
  String get debriefTitle => 'How did it go?';

  @override
  String debriefSubtitle(String title, int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return '$title · becomes v$versionString';
  }

  @override
  String get debriefAddPhoto => 'ADD PHOTO';

  @override
  String get debriefChangePhoto => 'CHANGE PHOTO';

  @override
  String get debriefRating => 'rating';

  @override
  String get debriefMoodLabel => 'what kind of cook was it';

  @override
  String get debriefChangesLabel => 'what altered from the original';

  @override
  String get debriefNoChanges => 'Nothing yet — add what you did differently.';

  @override
  String get debriefChangeHint => 'e.g. 2 tbsp honey instead of 3';

  @override
  String get debriefNoteLabel => 'what was missing';

  @override
  String get debriefNoteHint => '“needed more acid, next time add lime”';

  @override
  String get debriefPantryLabel => 'used from pantry';

  @override
  String get debriefDeduct => 'Deduct what matches';

  @override
  String debriefSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines not deducted',
      one: '1 line not deducted',
    );
    return '$_temp0';
  }

  @override
  String debriefSave(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Save as v$versionString';
  }

  @override
  String debriefSaveUpgrade(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Save & upgrade to v$versionString';
  }

  @override
  String get debriefSaveFailed => 'Could not save this cook';

  @override
  String debriefSaved(int version, String mood) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Saved as v$versionString · $mood';
  }

  @override
  String get wallSubtitleEmpty => 'Reels people imported';

  @override
  String wallReelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reels',
      one: '1 reel',
    );
    return '$_temp0';
  }

  @override
  String get wallMoreBelow => 'more below';

  @override
  String get wallReelGone => 'That reel is no longer on the server';

  @override
  String wallSavedToCookbook(String title) {
    return 'Saved $title to your cookbook';
  }

  @override
  String get wallInCookbook => 'In your cookbook';

  @override
  String get wallSaving => 'Saving…';

  @override
  String get wallAddToCookbook => 'Add to cookbook';

  @override
  String get wallLoadFailed => 'The Wall did not load';

  @override
  String get wallEmptyTitle => 'Nothing has been imported yet';

  @override
  String get wallEmptyBody => 'Import a reel and it lands here, for everyone.';

  @override
  String get wallImportReel => 'Import a reel';

  @override
  String get wallLoadMoreFailed => 'Could not load more — try again';

  @override
  String get wallMoreReels => 'More reels';

  @override
  String get wallEndOfFeed => 'That is every reel for now';

  @override
  String wallStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String wallIngredientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients',
      one: '1 ingredient',
    );
    return '$_temp0';
  }

  @override
  String get wallMethod => 'method';

  @override
  String get wallReelLoadFailed => 'This reel did not load';

  @override
  String get actionMarkCooked => 'Mark as cooked';

  @override
  String get actionMoveBackToCook => 'Move back to To cook';

  @override
  String get actionNeverCooked => 'Never cooked';

  @override
  String actionCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cooked $count times',
      one: 'Cooked 1 time',
    );
    return '$_temp0';
  }

  @override
  String get actionStatusCookedBody =>
      'It moves to Cooked. You can put it back.';

  @override
  String get actionStatusToCookBody =>
      'It moves to To cook, ready to make again.';

  @override
  String get actionDeleteBody => 'Leaves your journal. Asks first.';

  @override
  String get actionKeep => 'Keep it';

  @override
  String get actionRemoveTitle => 'Remove this dish?';

  @override
  String actionRemoveBody(String title) {
    return '$title leaves your journal, along with its versions and its cooks. The reel is still out there if you want to import it again — this copy is not coming back.';
  }

  @override
  String get actionRemove => 'Remove';

  @override
  String get profileSubtitle => 'The record of what you have actually cooked.';

  @override
  String get profileAccount => 'account';

  @override
  String get profileComingSoon => 'Coming soon';

  @override
  String get profileNutritionBody =>
      'A future lens on how your versions change a dish.';

  @override
  String get profileSoon => 'soon';

  @override
  String get profileAppearance => 'appearance';

  @override
  String get profileThemeSystem => 'SYSTEM';

  @override
  String get profileThemeLight => 'LIGHT';

  @override
  String get profileThemeDark => 'DARK';

  @override
  String get profileHowItWorks => 'How Shoku works';

  @override
  String get profileHowItWorksBody => 'The share gesture, in three steps';

  @override
  String get profileResetJournal => 'Reset journal';

  @override
  String get profileFooter => 'Shoku · evening kitchen';

  @override
  String get helpTitle => 'Help & feedback';

  @override
  String get helpSubtitle => 'Short answers to the things people ask first.';

  @override
  String get helpStillStuck => 'still stuck';

  @override
  String get helpStillStuckBody =>
      'Send the reel link and what you expected. It makes the fix much faster.';

  @override
  String get nutritionTitle => 'Nutrition';

  @override
  String get nutritionComingSoon => 'COMING SOON';

  @override
  String get nutritionHeadline => 'A lens on how your cooking changes.';

  @override
  String get nutritionBody =>
      'Your journal works without it. When it lands, it will read only the meals you cook here.';

  @override
  String get nutritionBackToYou => 'Back to You';

  @override
  String get exitTitle => 'Leave Shoku?';

  @override
  String get exitBody => 'Your journal is saved. Nothing is lost.';

  @override
  String get exitKeepCooking => 'Keep cooking';

  @override
  String get exitExit => 'Exit';

  @override
  String get orbAssistant => 'Assistant';

  @override
  String get orbAskAboutStep => 'Ask about this step';

  @override
  String timerStart(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'start $minutesString min timer';
  }

  @override
  String get timerTimesUp => 'time\'s up';

  @override
  String get timerPaused => 'paused';

  @override
  String get timerRunning => 'running';

  @override
  String timerOnStep(int step, String state) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'step $stepString · $state';
  }

  @override
  String get timerStartAgain => 'Start again';

  @override
  String get timerResume => 'Resume';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerStop => 'Stop';

  @override
  String get timerAlertsOff =>
      'alerts are off — enable notifications for Shoku';

  @override
  String get timerAlertsLate =>
      'alerts may arrive late — allow exact alarms in settings';

  @override
  String get cookLeaveTitle => 'Leave this cook?';

  @override
  String get cookLeaveBody => 'You are part-way through. Nothing is saved yet.';

  @override
  String cookLeaveChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes in this cook will be discarded.',
      one: '1 change in this cook will be discarded.',
    );
    return '$_temp0';
  }

  @override
  String cookChangedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changed',
      one: '1 changed',
    );
    return '$_temp0';
  }

  @override
  String cookStepLabel(String step) {
    return 'step $step';
  }

  @override
  String get cookTimerCleared => 'Timer cleared — this dish has a new version';

  @override
  String get cookBack => 'Back';

  @override
  String get cookFinishLog => 'Finish & log';

  @override
  String get cookNextStep => 'Next step';

  @override
  String get cookNoSteps => 'Follow the recipe.';

  @override
  String get micHint => 'Type or hold the mic';

  @override
  String get micListening => 'Listening…';

  @override
  String get searchHint => 'Search recipes, notes, handles';

  @override
  String hudStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}d',
      one: '1d',
    );
    return '$_temp0';
  }

  @override
  String hudLevel(String level) {
    return 'LVL $level';
  }
}
