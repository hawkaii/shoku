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
  String get importSignIn => 'Connectez-vous pour importer ce reel';

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
      'Connectez-vous pour importer vos propres reels et parler à la recette.';

  @override
  String dishCookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cuissons',
      many: '$count de cuissons',
      one: '1 cuisson',
    );
    return '$_temp0';
  }

  @override
  String get dishFromVideoNote =>
      'lu dans la vidéo — les quantités peuvent être fausses';

  @override
  String dishVersionGone(int from, int to) {
    final intl.NumberFormat fromNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String fromString = fromNumberFormat.format(from);
    final intl.NumberFormat toNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String toString = toNumberFormat.format(to);

    return 'v$fromString n\'existe plus — affichage de v$toString';
  }

  @override
  String get dishStartCookMode => 'Lancer le mode cuisine';

  @override
  String get dishReadRecipe => 'Lire cette recette';

  @override
  String get dishMore => 'Plus';

  @override
  String get dishMenuCooked => 'Je viens de le cuisiner';

  @override
  String get dishMarkToCook => 'Marquer à cuisiner';

  @override
  String get dishSetUpFridge => 'Configurer votre frigo';

  @override
  String dishAddMissingToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count manquants à la liste',
      many: 'Ajouter $count de manquants à la liste',
      one: 'Ajouter 1 manquant à la liste',
    );
    return '$_temp0';
  }

  @override
  String dishAddedToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ajoutés à votre liste',
      many: '$count d\'ajoutés à votre liste',
      one: '1 ajouté à votre liste',
    );
    return '$_temp0';
  }

  @override
  String dishIngredientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrédients',
      many: '$count d\'ingrédients',
      one: '1 ingrédient',
    );
    return '$_temp0';
  }

  @override
  String dishMissingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count manquants',
      many: '$count de manquants',
      one: '1 manquant',
    );
    return '$_temp0';
  }

  @override
  String get dishPickVersion => 'Choisissez une version';

  @override
  String dishVersionShowing(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString · affichée';
  }

  @override
  String dishStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      many: '$count d\'étapes',
      one: '1 étape',
    );
    return '$_temp0';
  }

  @override
  String dishAskAboutStep(int step) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'Demander à propos de l\'étape $stepString';
  }

  @override
  String get dishHistory => 'HISTORIQUE';

  @override
  String get dishNotCookedYet =>
      'Pas encore cuisiné. La première cuisson devient la v1.';

  @override
  String dishHistoryEntry(int version, String outcome) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString · $outcome';
  }

  @override
  String get dishWhatAltered => 'Ce qui a été modifié';

  @override
  String get dishFromChatEdit => 'depuis une modification du chat';

  @override
  String get dishNoNote => 'Aucune note';

  @override
  String get dishUnavailableTitle => 'Ce plat n\'est pas ici';

  @override
  String get dishUnavailableBody =>
      'Il est peut-être encore en chargement, ou il a été supprimé.';

  @override
  String get dishBackToJournal => 'Retour au journal';

  @override
  String get dishImported => 'Importé';

  @override
  String get dishTheSource => 'la source';

  @override
  String get dishViewReel => 'Voir le reel';

  @override
  String get logTitle => 'Enregistrer la cuisson du soir';

  @override
  String get logSnapResult => 'PHOTOGRAPHIEZ LE RÉSULTAT DU SOIR';

  @override
  String get logPhotoReady => 'PHOTO PRÊTE À ENVOYER';

  @override
  String get logHowDidItGo => 'comment ça s\'est passé';

  @override
  String get logNoteLabel => 'une note pour vous';

  @override
  String get logNoteHint => 'La poêle a trop chauffé, je l\'ai retiré plus tôt';

  @override
  String get logChangeLabel => 'qu\'avez-vous changé';

  @override
  String get logChangeHint =>
      'Plus de citron vert, 2 minutes de moins, à la friteuse à air';

  @override
  String get logSaveWithPhoto => 'Enregistrer avec photo';

  @override
  String get logSaveTonight => 'Enregistrer ce soir';

  @override
  String logSaveUpgrade(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Enregistrer et passer en v$versionString';
  }

  @override
  String get logSaveFailed => 'Cette cuisson n\'a pas pu être enregistrée';

  @override
  String logSaved(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Enregistré en v$versionString';
  }

  @override
  String logSavedWithOutcome(int version, String outcome) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Enregistré en v$versionString · $outcome';
  }

  @override
  String get debriefTitle => 'Comment ça s\'est passé ?';

  @override
  String debriefSubtitle(String title, int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return '$title · devient v$versionString';
  }

  @override
  String get debriefAddPhoto => 'AJOUTER UNE PHOTO';

  @override
  String get debriefChangePhoto => 'CHANGER LA PHOTO';

  @override
  String get debriefRating => 'note';

  @override
  String get debriefMoodLabel => 'quel genre de cuisson c\'était';

  @override
  String get debriefChangesLabel =>
      'ce qui a été modifié par rapport à l\'original';

  @override
  String get debriefNoChanges =>
      'Rien pour l\'instant — ajoutez ce que vous avez fait autrement.';

  @override
  String get debriefChangeHint => 'ex. 2 c. à s. de miel au lieu de 3';

  @override
  String get debriefNoteLabel => 'ce qui manquait';

  @override
  String get debriefNoteHint =>
      '« il manquait de l\'acidité, la prochaine fois ajoutez du citron vert »';

  @override
  String get debriefPantryLabel => 'pris dans le frigo';

  @override
  String get debriefDeduct => 'Déduire ce qui correspond';

  @override
  String debriefSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes non déduites',
      many: '$count de lignes non déduites',
      one: '1 ligne non déduite',
    );
    return '$_temp0';
  }

  @override
  String debriefSave(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Enregistrer en v$versionString';
  }

  @override
  String debriefSaveUpgrade(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Enregistrer et passer en v$versionString';
  }

  @override
  String get debriefSaveFailed => 'Cette cuisson n\'a pas pu être enregistrée';

  @override
  String debriefSaved(int version, String mood) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Enregistré en v$versionString · $mood';
  }

  @override
  String get wallSubtitleEmpty => 'Les reels que les gens ont importés';

  @override
  String wallReelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reels',
      many: '$count de reels',
      one: '1 reel',
    );
    return '$_temp0';
  }

  @override
  String get wallMoreBelow => 'plus bas';

  @override
  String get wallReelGone => 'Ce reel n\'est plus sur le serveur';

  @override
  String wallSavedToCookbook(String title) {
    return '$title enregistré dans vos recettes';
  }

  @override
  String get wallInCookbook => 'Dans vos recettes';

  @override
  String get wallSaving => 'Enregistrement…';

  @override
  String get wallAddToCookbook => 'Ajouter aux recettes';

  @override
  String get wallLoadFailed => 'Le Mur n\'a pas pu se charger';

  @override
  String get wallEmptyTitle => 'Rien n\'a encore été importé';

  @override
  String get wallEmptyBody =>
      'Importez un reel et il arrive ici, pour tout le monde.';

  @override
  String get wallImportReel => 'Importer un reel';

  @override
  String get wallLoadMoreFailed => 'Impossible de charger la suite — réessayez';

  @override
  String get wallMoreReels => 'Plus de reels';

  @override
  String get wallEndOfFeed => 'C\'est tout pour le moment';

  @override
  String wallStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      many: '$count d\'étapes',
      one: '1 étape',
    );
    return '$_temp0';
  }

  @override
  String wallIngredientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrédients',
      many: '$count d\'ingrédients',
      one: '1 ingrédient',
    );
    return '$_temp0';
  }

  @override
  String get wallMethod => 'méthode';

  @override
  String get wallReelLoadFailed => 'Ce reel n\'a pas pu se charger';

  @override
  String get actionMarkCooked => 'Marquer comme cuisiné';

  @override
  String get actionMoveBackToCook => 'Remettre dans À cuisiner';

  @override
  String get actionNeverCooked => 'Jamais cuisiné';

  @override
  String actionCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cuisiné $count fois',
      many: 'Cuisiné $count de fois',
      one: 'Cuisiné 1 fois',
    );
    return '$_temp0';
  }

  @override
  String get actionStatusCookedBody =>
      'Il passe dans Cuisinés. Vous pouvez le remettre.';

  @override
  String get actionStatusToCookBody =>
      'Il passe dans À cuisiner, prêt à refaire.';

  @override
  String get actionDeleteBody => 'Quitte votre journal. Demande avant.';

  @override
  String get actionKeep => 'Le garder';

  @override
  String get actionRemoveTitle => 'Retirer ce plat ?';

  @override
  String actionRemoveBody(String title) {
    return '$title quitte votre journal, avec ses versions et ses cuissons. Le reel est toujours là si vous voulez l\'importer à nouveau — cette copie ne reviendra pas.';
  }

  @override
  String get actionRemove => 'Retirer';

  @override
  String get profileSubtitle =>
      'Le registre de ce que vous avez vraiment cuisiné.';

  @override
  String get profileAccount => 'compte';

  @override
  String get profileComingSoon => 'Bientôt';

  @override
  String get profileNutritionBody =>
      'Un futur regard sur la façon dont vos versions changent un plat.';

  @override
  String get profileSoon => 'bientôt';

  @override
  String get profileAppearance => 'apparence';

  @override
  String get profileThemeSystem => 'SYSTÈME';

  @override
  String get profileThemeLight => 'CLAIR';

  @override
  String get profileThemeDark => 'SOMBRE';

  @override
  String get profileHowItWorks => 'Comment fonctionne Shoku';

  @override
  String get profileHowItWorksBody => 'Le geste de partage, en trois étapes';

  @override
  String get profileResetJournal => 'Réinitialiser le journal';

  @override
  String get profileFooter => 'Shoku · cuisine du soir';

  @override
  String get helpTitle => 'Aide et retours';

  @override
  String get helpSubtitle => 'Des réponses courtes aux premières questions.';

  @override
  String get helpStillStuck => 'toujours bloqué';

  @override
  String get helpStillStuckBody =>
      'Envoyez le lien du reel et ce que vous attendiez. La correction va bien plus vite.';

  @override
  String get nutritionTitle => 'Nutrition';

  @override
  String get nutritionComingSoon => 'BIENTÔT';

  @override
  String get nutritionHeadline =>
      'Un regard sur la façon dont votre cuisine change.';

  @override
  String get nutritionBody =>
      'Votre journal fonctionne sans. Quand elle arrivera, elle ne lira que les repas que vous cuisinez ici.';

  @override
  String get nutritionBackToYou => 'Retour à Vous';

  @override
  String get exitTitle => 'Quitter Shoku ?';

  @override
  String get exitBody => 'Votre journal est enregistré. Rien n\'est perdu.';

  @override
  String get exitKeepCooking => 'Continuer à cuisiner';

  @override
  String get exitExit => 'Quitter';

  @override
  String get orbAssistant => 'Assistant';

  @override
  String get orbAskAboutStep => 'Demander à propos de cette étape';

  @override
  String timerStart(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'lancer un minuteur de $minutesString min';
  }

  @override
  String get timerTimesUp => 'temps écoulé';

  @override
  String get timerPaused => 'en pause';

  @override
  String get timerRunning => 'en cours';

  @override
  String timerOnStep(int step, String state) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'étape $stepString · $state';
  }

  @override
  String get timerStartAgain => 'Relancer';

  @override
  String get timerResume => 'Reprendre';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerStop => 'Arrêter';

  @override
  String get timerAlertsOff =>
      'les alertes sont coupées — activez les notifications pour Shoku';

  @override
  String get timerAlertsLate =>
      'les alertes peuvent arriver en retard — autorisez les alarmes exactes dans les réglages';

  @override
  String get cookLeaveTitle => 'Quitter cette cuisson ?';

  @override
  String get cookLeaveBody =>
      'Vous êtes à mi-chemin. Rien n\'est encore enregistré.';

  @override
  String cookLeaveChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changements de cette cuisson seront perdus.',
      many: '$count de changements de cette cuisson seront perdus.',
      one: '1 changement de cette cuisson sera perdu.',
    );
    return '$_temp0';
  }

  @override
  String cookChangedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifiés',
      many: '$count de modifiés',
      one: '1 modifié',
    );
    return '$_temp0';
  }

  @override
  String cookStepLabel(String step) {
    return 'étape $step';
  }

  @override
  String get cookTimerCleared =>
      'Minuteur effacé — ce plat a une nouvelle version';

  @override
  String get cookBack => 'Retour';

  @override
  String get cookFinishLog => 'Terminer et enregistrer';

  @override
  String get cookNextStep => 'Étape suivante';

  @override
  String get cookNoSteps => 'Suivez la recette.';

  @override
  String get micHint => 'Tapez ou maintenez le micro';

  @override
  String get micListening => 'Écoute…';

  @override
  String get searchHint => 'Recherchez recettes, notes, comptes';

  @override
  String hudStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}j',
      many: '${count}j',
      one: '1j',
    );
    return '$_temp0';
  }

  @override
  String hudLevel(String level) {
    return 'NIV $level';
  }

  @override
  String get botServerNotice =>
      'L\'assistant a rencontré un problème — réessayez.';

  @override
  String get botSignInNotice => 'Connectez-vous pour interroger l\'assistant.';

  @override
  String get dishStopReading => 'Arrêter la lecture';

  @override
  String get cookbookEmptySignedOut =>
      'Connectez-vous pour retrouver vos recettes. Elles sont sur le serveur, pas sur ce téléphone.';

  @override
  String get cookbookEmptyOffline =>
      'Impossible de charger vos recettes. Vérifiez la connexion et réessayez.';

  @override
  String get importCapNotice =>
      'Les imports du jour sont épuisés. Ils reviennent demain — ou ajoutez un reel du Mur, déjà lu.';

  @override
  String get importCapWallHint =>
      'Ou ajoutez-en un du Mur : ils sont déjà lus.';

  @override
  String botAsksLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions restantes aujourd\'hui',
      one: '1 question restante aujourd\'hui',
      zero: 'plus de questions aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String get accountDelete => 'Supprimer le compte';

  @override
  String get accountDeleteBody =>
      'Cela efface vos plats, versions, cuissons, frigo et photos de tous les appareils et du serveur. Irréversible.';

  @override
  String get accountDeleteCancel => 'Garder';

  @override
  String get accountDeleteDone => 'Compte supprimé';

  @override
  String get accountDeleteFailed =>
      'Impossible de supprimer le compte. Rien n\'a été modifié.';

  @override
  String get wallReport => 'Signaler ce reel';

  @override
  String get wallReported =>
      'Signalé. Assez de signalements le retirent du Mur.';

  @override
  String get wallReportFailed => 'Impossible de le signaler. Réessayez.';

  @override
  String get timerNotificationTitle => 'Le minuteur est terminé';

  @override
  String timerNotificationBody(int step) {
    return 'L’étape $step est prête — retour à la cuisine.';
  }

  @override
  String get timerAlertsUnavailable =>
      'les alertes ne sont pas disponibles — le minuteur fonctionne tant que l’app est ouverte';

  @override
  String get importShareNoLink =>
      'Ce partage ne contenait pas de lien. Collez l’URL du reel ci-dessous.';

  @override
  String get authPasswordShow => 'Afficher le mot de passe';

  @override
  String get authPasswordHide => 'Masquer le mot de passe';

  @override
  String get routeErrorTitle => 'Cette page n’est pas ici';

  @override
  String get routeErrorBody =>
      'Le lien est peut-être ancien ou mal saisi. Votre journal est toujours là où il était.';

  @override
  String get routeErrorBack => 'Retour au journal';
}
