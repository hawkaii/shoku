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

  @override
  String get importPasteFirst => 'Paste a link first';

  @override
  String get importNoLink =>
      'The reel is ready but the server sent no link for it';

  @override
  String get importCouldNotStart => 'We could not start that import';

  @override
  String get importSignIn => 'Sign in to import this reel';

  @override
  String get importUnreachable => 'Could not reach the server';

  @override
  String get importLostConnection =>
      'Lost the connection — the reel is still being read. Open this again to pick it up';

  @override
  String get importStillOnServer =>
      'Could not reach the server — the reel is still on it. Open this again to pick it up';

  @override
  String get importGone =>
      'That reel is no longer on the server — try the link again';

  @override
  String importSaved(String title) {
    return 'Saved $title';
  }

  @override
  String get importNothingToSave => 'Nothing to save';

  @override
  String get importCouldNotSave =>
      'The recipe came back but could not be saved — open this again';

  @override
  String get importOpenAgain =>
      'Could not reach the server — open this again in a minute';

  @override
  String get importSheetTitle => 'Save a reel';

  @override
  String get importSheetBody =>
      'Paste a YouTube or Instagram link. It becomes a dish you can cook, with the creator attached.';

  @override
  String get importStillWorking => 'Still working — this reel is long';

  @override
  String get importLongWait =>
      'A long one takes a few minutes. You can leave this — the dish appears when it is ready.';

  @override
  String get importCloseWait =>
      'You can close this — the dish appears when it is ready.';

  @override
  String get importReading => 'Reading…';

  @override
  String get importReadLink => 'Read this link';

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

  @override
  String get botServerNotice => 'The assistant hit a problem — try again.';

  @override
  String get botSignInNotice => 'Sign in to ask the assistant.';

  @override
  String get dishStopReading => 'Stop reading';

  @override
  String get cookbookEmptySignedOut =>
      'Sign in to bring your recipes back. They live on the server, not on this phone.';

  @override
  String get cookbookEmptyOffline =>
      'Your recipes could not load. Check the connection and try again.';

  @override
  String get importCapNotice =>
      'Today\'s imports are used up. They come back tomorrow — or add one from the Wall, already read.';

  @override
  String get importCapWallHint =>
      'Or add one from the Wall — those are already read.';

  @override
  String botAsksLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count asks left today',
      one: '1 ask left today',
      zero: 'no asks left today',
    );
    return '$_temp0';
  }

  @override
  String get accountDelete => 'Delete account';

  @override
  String get accountDeleteBody =>
      'This erases your dishes, versions, cooks, fridge and photos from every device and from the server. It cannot be undone.';

  @override
  String get accountDeleteCancel => 'Keep it';

  @override
  String get accountDeleteDone => 'Account deleted';

  @override
  String get accountDeleteFailed =>
      'Could not delete the account. Nothing was changed.';

  @override
  String get wallReport => 'Report this reel';

  @override
  String get wallReported =>
      'Reported. Enough reports remove it from the Wall.';

  @override
  String get wallReportFailed => 'Could not report it. Try again.';

  @override
  String get timerNotificationTitle => 'Timer is up';

  @override
  String timerNotificationBody(int step) {
    return 'Step $step is done — back to the kitchen.';
  }

  @override
  String get timerAlertsUnavailable =>
      'alerts are off — the timer still works while the app is open';

  @override
  String get importShareNoLink =>
      'That share didn’t include a link. Paste the reel’s URL below.';

  @override
  String get authPasswordShow => 'Show password';

  @override
  String get authPasswordHide => 'Hide password';

  @override
  String get routeErrorTitle => 'This page isn’t here';

  @override
  String get routeErrorBody =>
      'The link may be old or mistyped. Your journal is still where it was.';

  @override
  String get routeErrorBack => 'Back to the journal';
}
