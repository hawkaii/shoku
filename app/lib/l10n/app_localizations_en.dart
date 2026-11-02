// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle =>
      'Shoku in your language. You can change this later in You.';

  @override
  String get languageSystem => 'System language';

  @override
  String get languageSystemHint => 'Follows this phone';

  @override
  String get languageTapToContinue => 'Tap a language to continue';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStartCooking => 'Start cooking';

  @override
  String get onboardingShareCta => 'Share a reel to try it';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingOpenJournal => 'Open my journal';

  @override
  String get onboardingIntroTitle => 'Cook it once.\nMake it yours.';

  @override
  String get onboardingIntroBody =>
      'Every time you cook, you change something. Shoku remembers those changes, so next time you can pick the version that fits tonight.';

  @override
  String get onboardingShareStepLabel => '01 · SHARE THE REEL';

  @override
  String get onboardingShareTitle =>
      'One tap, from the app you are already in.';

  @override
  String get onboardingShareTo => 'Share to';

  @override
  String get onboardingSaved => 'Saved as v1 · extracted in 4 seconds';

  @override
  String get onboardingJournalStepLabel => '02 · COOK IT, CHANGE IT';

  @override
  String get onboardingJournalTitle => 'Your journal remembers the changes.';

  @override
  String get onboardingJournalBody =>
      'Cook mode walks you through it. When you swap something, say so. At the end you get one version — with a photo, a rating and what altered.';

  @override
  String get onboardingAltered => 'altered';

  @override
  String get onboardingTap => 'TAP';

  @override
  String get authSheetTitle => 'Keep your journal';

  @override
  String get authSheetBody =>
      'Cooks stay on this phone until you sign in. Signing in puts them on every device you use.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authWorking => 'Working…';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authHaveAccount => 'I already have an account';

  @override
  String get authCreateAccountLink => 'Create an account';

  @override
  String get authErrorEmailPassword => 'Email and a password of 6+ characters';

  @override
  String get authErrorConfirmEmail =>
      'Check your email to confirm, then sign in';

  @override
  String get authErrorMismatch => 'That email and password do not match';

  @override
  String get authErrorUnconfirmed =>
      'That account is not confirmed yet — check your email';

  @override
  String get authErrorExists =>
      'That email already has an account — sign in instead';

  @override
  String get authErrorNoConnection => 'No connection';

  @override
  String get authErrorGeneric => 'Could not sign in';

  @override
  String get authNotSignedIn => 'Not signed in';

  @override
  String get authSignedIn => 'Signed in';

  @override
  String get authLocalOnly => 'Cooks live on this phone only.';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get tabJournal => 'Journal';

  @override
  String get tabCookbook => 'Cookbook';

  @override
  String get tabFridge => 'Fridge';

  @override
  String get tabWall => 'Wall';

  @override
  String get tabYou => 'You';

  @override
  String journalKitchenTitle(String month) {
    return '$month kitchen';
  }

  @override
  String journalDishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dishes',
      one: '1 dish',
      zero: 'No dishes yet',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count upgrades',
      one: '1 upgrade',
      zero: 'no upgrades',
    );
    return '$_temp0';
  }

  @override
  String journalCooksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cooks',
      one: 'cook',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'upgrades',
      one: 'upgrade',
    );
    return '$_temp0';
  }

  @override
  String journalEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
      zero: 'no entries',
    );
    return '$_temp0';
  }

  @override
  String get journalOnTheCounter => 'on the counter';

  @override
  String get journalCookLog => 'cook log';

  @override
  String get journalCook => 'Cook';

  @override
  String get journalFirstPage => 'Your first page';

  @override
  String get journalFirstPageBody =>
      'Log one cook — a photo, how it went, and one thing you changed. That becomes v1.';

  @override
  String get journalStartJournal => 'Start the journal →';

  @override
  String get journalNoDishes => 'No dishes yet — import a reel to start';

  @override
  String get journalOpening => 'Opening your journal';

  @override
  String get journalErrorTitle => 'Your journal could not be opened';

  @override
  String get journalErrorBody => 'The saved cooks are still on this phone.';

  @override
  String get journalTryAgain => 'Try again';

  @override
  String get journalSaveRecipe => 'Save a recipe';

  @override
  String get cookbookTitle => 'Cookbook';

  @override
  String cookbookCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cooked',
      one: '1 cooked',
      zero: 'nothing cooked',
    );
    return '$_temp0';
  }

  @override
  String get cookbookToCook => 'To cook';

  @override
  String get cookbookCooked => 'Cooked';

  @override
  String get cookbookNothingToCook => 'Nothing waiting to be cooked.';

  @override
  String get cookbookNoCooksYet => 'No cooks yet. Pick something from To cook.';

  @override
  String get cookbookNeverCooked => 'never cooked';

  @override
  String cookbookLastCooked(String outcome) {
    return 'last $outcome';
  }

  @override
  String get badgeToCook => 'TO COOK';

  @override
  String get badgeCooked => 'COOKED';

  @override
  String badgeCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'COOKED $count×',
      one: 'COOKED $count×',
    );
    return '$_temp0';
  }

  @override
  String get badgeSignature => 'SIGNATURE';

  @override
  String get outcomeNailedIt => 'Nailed it';

  @override
  String get outcomeGood => 'Good';

  @override
  String get outcomeNeedsWork => 'Needs work';

  @override
  String get moodQuick => 'quick';

  @override
  String get moodProject => 'project';

  @override
  String get moodComfort => 'comfort';

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
  String get labelSample => 'Sample';

  @override
  String get addSheetTitle => 'Import a recipe';

  @override
  String get addSheetSubtitle =>
      'One reel becomes one dish you can cook and version.';

  @override
  String get addSheetLinkHint => 'Paste an Instagram or YouTube link';

  @override
  String get addSheetShareOption => 'Share from another app';

  @override
  String get addSheetShareHint => 'Instagram → share → Shoku';

  @override
  String get addSheetScanOption => 'Scan a barcode';

  @override
  String get addSheetScanHint => 'Add straight to your pantry';

  @override
  String get addSheetBackendNote =>
      'Extraction runs on the backend — this build is the interface only.';

  @override
  String get importHeadline => 'Importing a reel';

  @override
  String get importQueued => 'Queued';

  @override
  String get importWaking => 'Waking the kitchen…';

  @override
  String get importWaitingHint => 'The first one after a pause takes a minute';

  @override
  String get importReadingReel => 'Reading the reel';

  @override
  String get importReadingAudio => 'Reading the audio';

  @override
  String get importWritingRecipe => 'Writing the recipe';

  @override
  String get importWatchingVideo => 'Watching the video';

  @override
  String get importReadingCaption => 'Reading the caption';

  @override
  String get importReady => 'Ready';

  @override
  String get importFailedShort => 'Could not read this one';

  @override
  String get reasonUnsupportedUrl =>
      'That link is not a reel or video we can read';

  @override
  String get reasonSourceBlocked =>
      'YouTube is blocking our server right now — try again later or paste the recipe';

  @override
  String get reasonTimeout => 'That took too long — try again';

  @override
  String get reasonWorkerUnavailable =>
      'The kitchen did not wake up — try again in a minute';

  @override
  String get reasonTimedOut =>
      'Still reading — this can take a few minutes. You can leave this and the dish will be here when it is ready';

  @override
  String get reasonGone =>
      'That import is no longer on the server — try the link again';

  @override
  String get reasonInvalidRecipe => 'We could not find a recipe in that one';

  @override
  String get reasonNoAudio => 'That video has nothing to listen to';

  @override
  String get reasonNoText =>
      'That reel has no caption and no speech we could read';

  @override
  String get reasonNoRecipe => 'That video does not show a recipe';

  @override
  String get reasonVisionFailed =>
      'We could not read that video — paste the recipe instead';

  @override
  String get reasonTakenDown => 'That recipe was removed';

  @override
  String get reasonUnknown =>
      'Could not read this one — paste the recipe instead';
}
