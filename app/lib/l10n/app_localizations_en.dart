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

  @override
  String get pantryTitle => 'Fridge';

  @override
  String pantryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'no items',
    );
    return '$_temp0';
  }

  @override
  String pantrySearchHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Search $count items',
      one: 'Search 1 item',
      zero: 'Search your fridge',
    );
    return '$_temp0';
  }

  @override
  String pantrySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
      zero: 'none selected',
    );
    return '$_temp0';
  }

  @override
  String get pantryEdit => 'Edit';

  @override
  String get pantryShelfLabel => 'cook from your fridge';

  @override
  String get pantryToBuy => 'to buy';

  @override
  String get pantryInFridge => 'in the fridge';

  @override
  String get pantryEmpty =>
      'Nothing in the fridge yet. Photograph a receipt, or just tell me what’s in it.';

  @override
  String get pantryAddItems => 'Add items';

  @override
  String get pantryHowMuch => 'How much?';

  @override
  String get pantryAmountExample => '2 kg';

  @override
  String get pantryCancel => 'Cancel';

  @override
  String get pantryDone => 'Done';

  @override
  String get pantryDelete => 'Delete';

  @override
  String get pantrySelectItems => 'Select items';

  @override
  String pantryDeleteCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $countString',
      one: 'Delete 1',
    );
    return '$_temp0';
  }

  @override
  String pantryDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items deleted',
      one: '1 item deleted',
    );
    return '$_temp0';
  }

  @override
  String get pantrySetAmount => 'set amount';

  @override
  String pantryLessItem(String name) {
    return 'Less $name';
  }

  @override
  String pantryMoreItem(String name) {
    return 'More $name';
  }

  @override
  String get shelfEmpty =>
      'Nothing to suggest yet — add a few items and I will match walls and your own dishes.';

  @override
  String shelfBuyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count to buy',
      one: '+1 to buy',
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

    return '$haveString of $totalString';
  }

  @override
  String get pantryEditTitle => 'Edit item';

  @override
  String get pantryNameLabel => 'name';

  @override
  String get pantryAmountLabel => 'amount';

  @override
  String get pantryAmountHelp =>
      'Leave it blank if you know you have it but not how much.';

  @override
  String pantrySavedAs(String amount) {
    return 'Saved as $amount';
  }

  @override
  String get pantrySave => 'Save';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitTbsp => 'tbsp';

  @override
  String get unitTsp => 'tsp';

  @override
  String get unitPcs => 'pcs';

  @override
  String get unitBunch => 'bunch';

  @override
  String get unitPack => 'pack';

  @override
  String get pantryAddTitle => 'Add to the fridge';

  @override
  String get pantryAddIntro =>
      'Photograph a receipt, say what is in the kitchen, or type it. Nothing enters the fridge until you have seen the list.';

  @override
  String get pantryDoorPhoto => 'Photo';

  @override
  String get pantryDoorVoice => 'Voice';

  @override
  String get pantryDoorType => 'Type';

  @override
  String get pantryReview => 'Review';

  @override
  String get pantryToAdd => 'to add';

  @override
  String get pantryAiReading => 'Reading the rest…';

  @override
  String get pantryAmountUnknown => 'amount unknown';

  @override
  String pantryCouldNotRead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Couldn’t read ($count)',
      one: 'Couldn’t read (1)',
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
      other: 'Add $checkedString of $totalString',
      one: 'Add $checkedString of 1',
    );
    return '$_temp0';
  }

  @override
  String get pantryNoteOffline =>
      'The receipt reader needs a connection. Type it or say it instead.';

  @override
  String get pantryNoteUnreadable =>
      'Nothing readable in that picture — type it instead.';

  @override
  String get pantryCapReached =>
      'AI reads used up for today — type them instead';

  @override
  String get pantryPhotoButton => 'Photo or screenshot';

  @override
  String get pantryPhotoHint =>
      'Photograph a receipt and the reader types it out. Nothing enters the fridge until you have seen the list.';

  @override
  String get pantryReadingReceipt => 'Reading the receipt…';

  @override
  String get pantryBackTooltip => 'Back to the fridge';

  @override
  String get pantryTypeHint => '2 kg rice, one per line';

  @override
  String get pantryVoiceHint => 'Hold the mic and say what is in the kitchen';

  @override
  String get pantryWhatIsIt => 'What is it?';

  @override
  String get pantryVisionTitle => 'The reader uses Meta’s model';

  @override
  String get pantryVisionBody =>
      'The photo is sent to Meta’s model to read it. It is used for that one call and is not stored. The lines land in the review below, where you can fix anything before it enters the fridge.';

  @override
  String get pantryGotIt => 'Got it';

  @override
  String get pantryScreenshotOrPhoto => 'Screenshot or photo';

  @override
  String get pantryCamera => 'Camera';

  @override
  String pantryInFridgeSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items in the fridge',
      one: '1 item in the fridge',
    );
    return '$_temp0';
  }

  @override
  String get botNoDish => 'No dish';

  @override
  String get botDishFallback => 'Dish';

  @override
  String botCookingStep(int step, int total) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Cooking · step $stepString of $totalString';
  }

  @override
  String get botTalkAbout => 'Talk about…';

  @override
  String get botThisDish => 'This dish';

  @override
  String get botNoDishKitchen => 'No dish — the kitchen';

  @override
  String get botOpen => 'Open';

  @override
  String get botMinimise => 'Minimise';

  @override
  String get botNewChat => 'New chat';

  @override
  String get botThinking => 'THINKING';

  @override
  String get botOfflineLine =>
      'The assistant needs a connection. Nothing is answered offline.';

  @override
  String get botAskKitchen => 'Ask about the kitchen…';

  @override
  String botAskDish(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Ask about this dish · v$versionString';
  }

  @override
  String get botOutOfQuestions => 'Out of questions for today';

  @override
  String get botNoConnection => 'No connection';

  @override
  String get botCapNotice =>
      'You have used today’s questions. They come back tomorrow.';

  @override
  String get botOfflineNotice =>
      'The assistant needs a connection. Nothing here is answered offline.';

  @override
  String botWhichDish(String choices) {
    return 'Which dish did you mean? $choices';
  }

  @override
  String botAddedToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items in the fridge.',
      one: '1 item in the fridge.',
    );
    return '$_temp0';
  }

  @override
  String get botDestructiveRefusal =>
      'I can’t change your journal from here. Open the dish (or its ⋯ menu) and the real flow will do it.';

  @override
  String botAddMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count missing',
      one: 'Add 1 missing',
    );
    return '$_temp0';
  }

  @override
  String botAddedToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items added to your list',
      one: '1 item added to your list',
    );
    return '$_temp0';
  }

  @override
  String get botNotThis => 'Not this';

  @override
  String get botAddToFridgeQuestion => 'Add to the fridge?';

  @override
  String botAddCountToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count items to fridge',
      one: 'Add 1 item to fridge',
    );
    return '$_temp0';
  }

  @override
  String get botAmountUnknown => 'amount?';

  @override
  String botSuggestionMeta(String source, int have, int total) {
    final intl.NumberFormat haveNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String haveString = haveNumberFormat.format(have);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$source · $haveString of $totalString';
  }

  @override
  String get botStarterFridge => 'What\'s in your fridge?';

  @override
  String get botStarterWall => 'Show me something from the Wall';

  @override
  String get botStarterPhoto => 'I have a photo of a dish';

  @override
  String botStarterDinner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count things in the fridge. Dinner from them?',
      one: 'You have 1 thing in the fridge. Dinner from it?',
    );
    return '$_temp0';
  }

  @override
  String chatEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show earlier ($count)',
      one: 'Show earlier (1)',
    );
    return '$_temp0';
  }

  @override
  String chatAboutStep(int step) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'about step $stepString';
  }

  @override
  String get chatAskHint => 'Ask, or hold the mic';

  @override
  String get chatResolveChange => 'Resolve the change above';

  @override
  String get chatAsk => 'Ask';

  @override
  String chatVersionDivider(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString starts here';
  }

  @override
  String chatApplied(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'V$versionString · APPLIED';
  }

  @override
  String chatOpenVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Open v$versionString';
  }

  @override
  String get chatUndo => 'Undo';

  @override
  String get chatRecipeChange => 'RECIPE CHANGE';

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
      other: '+$count more',
      one: '+1 more',
    );
    return '$_temp0';
  }

  @override
  String chatCreatesVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Creates v$versionString — from this message';
  }

  @override
  String get chatRecompute => 'Recompute';

  @override
  String get chatDiscard => 'Discard';

  @override
  String get chatNotApplied => 'NOT APPLIED';

  @override
  String get chatNothingChanged => 'Nothing changed in your recipe.';

  @override
  String get chatTryAgain => 'Try again';

  @override
  String get chatApplying => 'Applying…';

  @override
  String chatApplyAs(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Apply as v$versionString';
  }
}
