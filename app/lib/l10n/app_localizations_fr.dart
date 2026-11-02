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
      'Un geste, depuis l\'app où vous êtes déjà.';

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
  String get cookbookTitle => 'Carnet de recettes';

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
  String get moodComfort => 'réconfort';

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
      'Nous n\'avons pas trouvé de recette dans celle-ci';

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
}
