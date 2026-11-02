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
}
