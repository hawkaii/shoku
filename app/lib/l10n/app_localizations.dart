import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('mr'),
    Locale('pt'),
    Locale('ta'),
    Locale('te')
  ];

  /// Title of the language picker, on onboarding and in You.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// Explains that the choice can be revisited from the You tab.
  ///
  /// In en, this message translates to:
  /// **'Shoku in your language. You can change this later in You.'**
  String get languageSubtitle;

  /// Language option that follows the device locale.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageSystem;

  /// Subtitle under the system-language option.
  ///
  /// In en, this message translates to:
  /// **'Follows this phone'**
  String get languageSystemHint;

  /// Hint shown under the onboarding language picker.
  ///
  /// In en, this message translates to:
  /// **'Tap a language to continue'**
  String get languageTapToContinue;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingStartCooking.
  ///
  /// In en, this message translates to:
  /// **'Start cooking'**
  String get onboardingStartCooking;

  /// No description provided for @onboardingShareCta.
  ///
  /// In en, this message translates to:
  /// **'Share a reel to try it'**
  String get onboardingShareCta;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingOpenJournal.
  ///
  /// In en, this message translates to:
  /// **'Open my journal'**
  String get onboardingOpenJournal;

  /// No description provided for @onboardingIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Cook it once.\nMake it yours.'**
  String get onboardingIntroTitle;

  /// No description provided for @onboardingIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Every time you cook, you change something. Shoku remembers those changes, so next time you can pick the version that fits tonight.'**
  String get onboardingIntroBody;

  /// No description provided for @onboardingShareStepLabel.
  ///
  /// In en, this message translates to:
  /// **'01 · SHARE THE REEL'**
  String get onboardingShareStepLabel;

  /// No description provided for @onboardingShareTitle.
  ///
  /// In en, this message translates to:
  /// **'One tap, from the app you are already in.'**
  String get onboardingShareTitle;

  /// No description provided for @onboardingShareTo.
  ///
  /// In en, this message translates to:
  /// **'Share to'**
  String get onboardingShareTo;

  /// No description provided for @onboardingSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved as v1 · extracted in 4 seconds'**
  String get onboardingSaved;

  /// No description provided for @onboardingJournalStepLabel.
  ///
  /// In en, this message translates to:
  /// **'02 · COOK IT, CHANGE IT'**
  String get onboardingJournalStepLabel;

  /// No description provided for @onboardingJournalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your journal remembers the changes.'**
  String get onboardingJournalTitle;

  /// No description provided for @onboardingJournalBody.
  ///
  /// In en, this message translates to:
  /// **'Cook mode walks you through it. When you swap something, say so. At the end you get one version — with a photo, a rating and what altered.'**
  String get onboardingJournalBody;

  /// No description provided for @onboardingAltered.
  ///
  /// In en, this message translates to:
  /// **'altered'**
  String get onboardingAltered;

  /// No description provided for @onboardingTap.
  ///
  /// In en, this message translates to:
  /// **'TAP'**
  String get onboardingTap;

  /// No description provided for @authSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your journal'**
  String get authSheetTitle;

  /// No description provided for @authSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Cooks stay on this phone until you sign in. Signing in puts them on every device you use.'**
  String get authSheetBody;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get authWorking;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get authHaveAccount;

  /// No description provided for @authCreateAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authCreateAccountLink;

  /// No description provided for @authErrorEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Email and a password of 6+ characters'**
  String get authErrorEmailPassword;

  /// No description provided for @authErrorConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm, then sign in'**
  String get authErrorConfirmEmail;

  /// No description provided for @authErrorMismatch.
  ///
  /// In en, this message translates to:
  /// **'That email and password do not match'**
  String get authErrorMismatch;

  /// No description provided for @authErrorUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'That account is not confirmed yet — check your email'**
  String get authErrorUnconfirmed;

  /// No description provided for @authErrorExists.
  ///
  /// In en, this message translates to:
  /// **'That email already has an account — sign in instead'**
  String get authErrorExists;

  /// No description provided for @authErrorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get authErrorNoConnection;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in'**
  String get authErrorGeneric;

  /// No description provided for @authNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get authNotSignedIn;

  /// No description provided for @authSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get authSignedIn;

  /// No description provided for @authLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Cooks live on this phone only.'**
  String get authLocalOnly;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @tabJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get tabJournal;

  /// No description provided for @tabCookbook.
  ///
  /// In en, this message translates to:
  /// **'Cookbook'**
  String get tabCookbook;

  /// No description provided for @tabFridge.
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get tabFridge;

  /// No description provided for @tabWall.
  ///
  /// In en, this message translates to:
  /// **'Wall'**
  String get tabWall;

  /// No description provided for @tabYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get tabYou;

  /// No description provided for @journalKitchenTitle.
  ///
  /// In en, this message translates to:
  /// **'{month} kitchen'**
  String journalKitchenTitle(String month);

  /// No description provided for @journalDishesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No dishes yet} =1{1 dish} other{{count} dishes}}'**
  String journalDishesCount(int count);

  /// No description provided for @journalUpgradesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no upgrades} =1{1 upgrade} other{{count} upgrades}}'**
  String journalUpgradesCount(int count);

  /// No description provided for @journalCooksLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{cook} other{cooks}}'**
  String journalCooksLabel(int count);

  /// No description provided for @journalUpgradesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{upgrade} other{upgrades}}'**
  String journalUpgradesLabel(int count);

  /// No description provided for @journalEntriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no entries} =1{1 entry} other{{count} entries}}'**
  String journalEntriesCount(int count);

  /// No description provided for @journalOnTheCounter.
  ///
  /// In en, this message translates to:
  /// **'on the counter'**
  String get journalOnTheCounter;

  /// No description provided for @journalCookLog.
  ///
  /// In en, this message translates to:
  /// **'cook log'**
  String get journalCookLog;

  /// No description provided for @journalCook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get journalCook;

  /// No description provided for @journalFirstPage.
  ///
  /// In en, this message translates to:
  /// **'Your first page'**
  String get journalFirstPage;

  /// No description provided for @journalFirstPageBody.
  ///
  /// In en, this message translates to:
  /// **'Log one cook — a photo, how it went, and one thing you changed. That becomes v1.'**
  String get journalFirstPageBody;

  /// No description provided for @journalStartJournal.
  ///
  /// In en, this message translates to:
  /// **'Start the journal →'**
  String get journalStartJournal;

  /// No description provided for @journalNoDishes.
  ///
  /// In en, this message translates to:
  /// **'No dishes yet — import a reel to start'**
  String get journalNoDishes;

  /// No description provided for @journalOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening your journal'**
  String get journalOpening;

  /// No description provided for @journalErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Your journal could not be opened'**
  String get journalErrorTitle;

  /// No description provided for @journalErrorBody.
  ///
  /// In en, this message translates to:
  /// **'The saved cooks are still on this phone.'**
  String get journalErrorBody;

  /// No description provided for @journalTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get journalTryAgain;

  /// No description provided for @journalSaveRecipe.
  ///
  /// In en, this message translates to:
  /// **'Save a recipe'**
  String get journalSaveRecipe;

  /// No description provided for @cookbookTitle.
  ///
  /// In en, this message translates to:
  /// **'Cookbook'**
  String get cookbookTitle;

  /// No description provided for @cookbookCookedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{nothing cooked} =1{1 cooked} other{{count} cooked}}'**
  String cookbookCookedCount(int count);

  /// No description provided for @cookbookToCook.
  ///
  /// In en, this message translates to:
  /// **'To cook'**
  String get cookbookToCook;

  /// No description provided for @cookbookCooked.
  ///
  /// In en, this message translates to:
  /// **'Cooked'**
  String get cookbookCooked;

  /// No description provided for @cookbookNothingToCook.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting to be cooked.'**
  String get cookbookNothingToCook;

  /// No description provided for @cookbookNoCooksYet.
  ///
  /// In en, this message translates to:
  /// **'No cooks yet. Pick something from To cook.'**
  String get cookbookNoCooksYet;

  /// No description provided for @cookbookNeverCooked.
  ///
  /// In en, this message translates to:
  /// **'never cooked'**
  String get cookbookNeverCooked;

  /// No description provided for @cookbookLastCooked.
  ///
  /// In en, this message translates to:
  /// **'last {outcome}'**
  String cookbookLastCooked(String outcome);

  /// No description provided for @badgeToCook.
  ///
  /// In en, this message translates to:
  /// **'TO COOK'**
  String get badgeToCook;

  /// No description provided for @badgeCooked.
  ///
  /// In en, this message translates to:
  /// **'COOKED'**
  String get badgeCooked;

  /// No description provided for @badgeCookedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{COOKED {count}×} other{COOKED {count}×}}'**
  String badgeCookedCount(int count);

  /// No description provided for @badgeSignature.
  ///
  /// In en, this message translates to:
  /// **'SIGNATURE'**
  String get badgeSignature;

  /// No description provided for @outcomeNailedIt.
  ///
  /// In en, this message translates to:
  /// **'Nailed it'**
  String get outcomeNailedIt;

  /// No description provided for @outcomeGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get outcomeGood;

  /// No description provided for @outcomeNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'Needs work'**
  String get outcomeNeedsWork;

  /// No description provided for @moodQuick.
  ///
  /// In en, this message translates to:
  /// **'quick'**
  String get moodQuick;

  /// No description provided for @moodProject.
  ///
  /// In en, this message translates to:
  /// **'project'**
  String get moodProject;

  /// No description provided for @moodComfort.
  ///
  /// In en, this message translates to:
  /// **'comfort'**
  String get moodComfort;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 min} other{{count} min}}'**
  String minutesShort(int count);

  /// No description provided for @labelSample.
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get labelSample;

  /// No description provided for @addSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Import a recipe'**
  String get addSheetTitle;

  /// No description provided for @addSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One reel becomes one dish you can cook and version.'**
  String get addSheetSubtitle;

  /// No description provided for @addSheetLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Paste an Instagram or YouTube link'**
  String get addSheetLinkHint;

  /// No description provided for @addSheetShareOption.
  ///
  /// In en, this message translates to:
  /// **'Share from another app'**
  String get addSheetShareOption;

  /// No description provided for @addSheetShareHint.
  ///
  /// In en, this message translates to:
  /// **'Instagram → share → Shoku'**
  String get addSheetShareHint;

  /// No description provided for @addSheetScanOption.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode'**
  String get addSheetScanOption;

  /// No description provided for @addSheetScanHint.
  ///
  /// In en, this message translates to:
  /// **'Add straight to your pantry'**
  String get addSheetScanHint;

  /// No description provided for @addSheetBackendNote.
  ///
  /// In en, this message translates to:
  /// **'Extraction runs on the backend — this build is the interface only.'**
  String get addSheetBackendNote;

  /// No description provided for @importHeadline.
  ///
  /// In en, this message translates to:
  /// **'Importing a reel'**
  String get importHeadline;

  /// No description provided for @importQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get importQueued;

  /// No description provided for @importWaking.
  ///
  /// In en, this message translates to:
  /// **'Waking the kitchen…'**
  String get importWaking;

  /// No description provided for @importWaitingHint.
  ///
  /// In en, this message translates to:
  /// **'The first one after a pause takes a minute'**
  String get importWaitingHint;

  /// No description provided for @importReadingReel.
  ///
  /// In en, this message translates to:
  /// **'Reading the reel'**
  String get importReadingReel;

  /// No description provided for @importReadingAudio.
  ///
  /// In en, this message translates to:
  /// **'Reading the audio'**
  String get importReadingAudio;

  /// No description provided for @importWritingRecipe.
  ///
  /// In en, this message translates to:
  /// **'Writing the recipe'**
  String get importWritingRecipe;

  /// No description provided for @importWatchingVideo.
  ///
  /// In en, this message translates to:
  /// **'Watching the video'**
  String get importWatchingVideo;

  /// No description provided for @importReadingCaption.
  ///
  /// In en, this message translates to:
  /// **'Reading the caption'**
  String get importReadingCaption;

  /// No description provided for @importReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get importReady;

  /// No description provided for @importFailedShort.
  ///
  /// In en, this message translates to:
  /// **'Could not read this one'**
  String get importFailedShort;

  /// No description provided for @reasonUnsupportedUrl.
  ///
  /// In en, this message translates to:
  /// **'That link is not a reel or video we can read'**
  String get reasonUnsupportedUrl;

  /// No description provided for @reasonSourceBlocked.
  ///
  /// In en, this message translates to:
  /// **'YouTube is blocking our server right now — try again later or paste the recipe'**
  String get reasonSourceBlocked;

  /// No description provided for @reasonTimeout.
  ///
  /// In en, this message translates to:
  /// **'That took too long — try again'**
  String get reasonTimeout;

  /// No description provided for @reasonWorkerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The kitchen did not wake up — try again in a minute'**
  String get reasonWorkerUnavailable;

  /// No description provided for @reasonTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Still reading — this can take a few minutes. You can leave this and the dish will be here when it is ready'**
  String get reasonTimedOut;

  /// No description provided for @reasonGone.
  ///
  /// In en, this message translates to:
  /// **'That import is no longer on the server — try the link again'**
  String get reasonGone;

  /// No description provided for @reasonInvalidRecipe.
  ///
  /// In en, this message translates to:
  /// **'We could not find a recipe in that one'**
  String get reasonInvalidRecipe;

  /// No description provided for @reasonNoAudio.
  ///
  /// In en, this message translates to:
  /// **'That video has nothing to listen to'**
  String get reasonNoAudio;

  /// No description provided for @reasonNoText.
  ///
  /// In en, this message translates to:
  /// **'That reel has no caption and no speech we could read'**
  String get reasonNoText;

  /// No description provided for @reasonNoRecipe.
  ///
  /// In en, this message translates to:
  /// **'That video does not show a recipe'**
  String get reasonNoRecipe;

  /// No description provided for @reasonVisionFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not read that video — paste the recipe instead'**
  String get reasonVisionFailed;

  /// No description provided for @reasonTakenDown.
  ///
  /// In en, this message translates to:
  /// **'That recipe was removed'**
  String get reasonTakenDown;

  /// No description provided for @reasonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Could not read this one — paste the recipe instead'**
  String get reasonUnknown;

  /// No description provided for @pantryTitle.
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get pantryTitle;

  /// No description provided for @pantryItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no items} =1{1 item} other{{count} items}}'**
  String pantryItemCount(int count);

  /// No description provided for @pantrySearchHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Search your fridge} =1{Search 1 item} other{Search {count} items}}'**
  String pantrySearchHint(int count);

  /// No description provided for @pantrySelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{none selected} =1{1 selected} other{{count} selected}}'**
  String pantrySelectedCount(int count);

  /// No description provided for @pantryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get pantryEdit;

  /// No description provided for @pantryShelfLabel.
  ///
  /// In en, this message translates to:
  /// **'cook from your fridge'**
  String get pantryShelfLabel;

  /// No description provided for @pantryToBuy.
  ///
  /// In en, this message translates to:
  /// **'to buy'**
  String get pantryToBuy;

  /// No description provided for @pantryInFridge.
  ///
  /// In en, this message translates to:
  /// **'in the fridge'**
  String get pantryInFridge;

  /// No description provided for @pantryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the fridge yet. Photograph a receipt, or just tell me what’s in it.'**
  String get pantryEmpty;

  /// No description provided for @pantryAddItems.
  ///
  /// In en, this message translates to:
  /// **'Add items'**
  String get pantryAddItems;

  /// No description provided for @pantryHowMuch.
  ///
  /// In en, this message translates to:
  /// **'How much?'**
  String get pantryHowMuch;

  /// No description provided for @pantryAmountExample.
  ///
  /// In en, this message translates to:
  /// **'2 kg'**
  String get pantryAmountExample;

  /// No description provided for @pantryCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pantryCancel;

  /// No description provided for @pantryDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get pantryDone;

  /// No description provided for @pantryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pantryDelete;

  /// No description provided for @pantrySelectItems.
  ///
  /// In en, this message translates to:
  /// **'Select items'**
  String get pantrySelectItems;

  /// No description provided for @pantryDeleteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1} other{Delete {count}}}'**
  String pantryDeleteCount(int count);

  /// No description provided for @pantryDeletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item deleted} other{{count} items deleted}}'**
  String pantryDeletedCount(int count);

  /// No description provided for @pantrySetAmount.
  ///
  /// In en, this message translates to:
  /// **'set amount'**
  String get pantrySetAmount;

  /// No description provided for @pantryLessItem.
  ///
  /// In en, this message translates to:
  /// **'Less {name}'**
  String pantryLessItem(String name);

  /// No description provided for @pantryMoreItem.
  ///
  /// In en, this message translates to:
  /// **'More {name}'**
  String pantryMoreItem(String name);

  /// No description provided for @shelfEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to suggest yet — add a few items and I will match walls and your own dishes.'**
  String get shelfEmpty;

  /// No description provided for @shelfBuyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{+1 to buy} other{+{count} to buy}}'**
  String shelfBuyCount(int count);

  /// No description provided for @shelfScore.
  ///
  /// In en, this message translates to:
  /// **'{have} of {total}'**
  String shelfScore(int have, int total);

  /// No description provided for @pantryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get pantryEditTitle;

  /// No description provided for @pantryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get pantryNameLabel;

  /// No description provided for @pantryAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'amount'**
  String get pantryAmountLabel;

  /// No description provided for @pantryAmountHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave it blank if you know you have it but not how much.'**
  String get pantryAmountHelp;

  /// No description provided for @pantrySavedAs.
  ///
  /// In en, this message translates to:
  /// **'Saved as {amount}'**
  String pantrySavedAs(String amount);

  /// No description provided for @pantrySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get pantrySave;

  /// No description provided for @unitG.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitG;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitL.
  ///
  /// In en, this message translates to:
  /// **'l'**
  String get unitL;

  /// No description provided for @unitTbsp.
  ///
  /// In en, this message translates to:
  /// **'tbsp'**
  String get unitTbsp;

  /// No description provided for @unitTsp.
  ///
  /// In en, this message translates to:
  /// **'tsp'**
  String get unitTsp;

  /// No description provided for @unitPcs.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get unitPcs;

  /// No description provided for @unitBunch.
  ///
  /// In en, this message translates to:
  /// **'bunch'**
  String get unitBunch;

  /// No description provided for @unitPack.
  ///
  /// In en, this message translates to:
  /// **'pack'**
  String get unitPack;

  /// No description provided for @pantryAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to the fridge'**
  String get pantryAddTitle;

  /// No description provided for @pantryAddIntro.
  ///
  /// In en, this message translates to:
  /// **'Photograph a receipt, say what is in the kitchen, or type it. Nothing enters the fridge until you have seen the list.'**
  String get pantryAddIntro;

  /// No description provided for @pantryDoorPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get pantryDoorPhoto;

  /// No description provided for @pantryDoorVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get pantryDoorVoice;

  /// No description provided for @pantryDoorType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get pantryDoorType;

  /// No description provided for @pantryReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get pantryReview;

  /// No description provided for @pantryToAdd.
  ///
  /// In en, this message translates to:
  /// **'to add'**
  String get pantryToAdd;

  /// No description provided for @pantryAiReading.
  ///
  /// In en, this message translates to:
  /// **'Reading the rest…'**
  String get pantryAiReading;

  /// No description provided for @pantryAmountUnknown.
  ///
  /// In en, this message translates to:
  /// **'amount unknown'**
  String get pantryAmountUnknown;

  /// No description provided for @pantryCouldNotRead.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Couldn’t read (1)} other{Couldn’t read ({count})}}'**
  String pantryCouldNotRead(int count);

  /// No description provided for @pantryConfirmAdd.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{Add {checked} of 1} other{Add {checked} of {total}}}'**
  String pantryConfirmAdd(int checked, int total);

  /// No description provided for @pantryNoteOffline.
  ///
  /// In en, this message translates to:
  /// **'The receipt reader needs a connection. Type it or say it instead.'**
  String get pantryNoteOffline;

  /// No description provided for @pantryNoteUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Nothing readable in that picture — type it instead.'**
  String get pantryNoteUnreadable;

  /// No description provided for @pantryCapReached.
  ///
  /// In en, this message translates to:
  /// **'AI reads used up for today — type them instead'**
  String get pantryCapReached;

  /// No description provided for @pantryPhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Photo or screenshot'**
  String get pantryPhotoButton;

  /// No description provided for @pantryPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Photograph a receipt and the reader types it out. Nothing enters the fridge until you have seen the list.'**
  String get pantryPhotoHint;

  /// No description provided for @pantryReadingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Reading the receipt…'**
  String get pantryReadingReceipt;

  /// No description provided for @pantryBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to the fridge'**
  String get pantryBackTooltip;

  /// No description provided for @pantryTypeHint.
  ///
  /// In en, this message translates to:
  /// **'2 kg rice, one per line'**
  String get pantryTypeHint;

  /// No description provided for @pantryVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Hold the mic and say what is in the kitchen'**
  String get pantryVoiceHint;

  /// No description provided for @pantryWhatIsIt.
  ///
  /// In en, this message translates to:
  /// **'What is it?'**
  String get pantryWhatIsIt;

  /// No description provided for @pantryVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'The reader uses Meta’s model'**
  String get pantryVisionTitle;

  /// No description provided for @pantryVisionBody.
  ///
  /// In en, this message translates to:
  /// **'The photo is sent to Meta’s model to read it. It is used for that one call and is not stored. The lines land in the review below, where you can fix anything before it enters the fridge.'**
  String get pantryVisionBody;

  /// No description provided for @pantryGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get pantryGotIt;

  /// No description provided for @pantryScreenshotOrPhoto.
  ///
  /// In en, this message translates to:
  /// **'Screenshot or photo'**
  String get pantryScreenshotOrPhoto;

  /// No description provided for @pantryCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get pantryCamera;

  /// No description provided for @pantryInFridgeSnack.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item in the fridge} other{{count} items in the fridge}}'**
  String pantryInFridgeSnack(int count);

  /// No description provided for @botNoDish.
  ///
  /// In en, this message translates to:
  /// **'No dish'**
  String get botNoDish;

  /// No description provided for @botDishFallback.
  ///
  /// In en, this message translates to:
  /// **'Dish'**
  String get botDishFallback;

  /// No description provided for @botCookingStep.
  ///
  /// In en, this message translates to:
  /// **'Cooking · step {step} of {total}'**
  String botCookingStep(int step, int total);

  /// No description provided for @botTalkAbout.
  ///
  /// In en, this message translates to:
  /// **'Talk about…'**
  String get botTalkAbout;

  /// No description provided for @botThisDish.
  ///
  /// In en, this message translates to:
  /// **'This dish'**
  String get botThisDish;

  /// No description provided for @botNoDishKitchen.
  ///
  /// In en, this message translates to:
  /// **'No dish — the kitchen'**
  String get botNoDishKitchen;

  /// No description provided for @botOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get botOpen;

  /// No description provided for @botMinimise.
  ///
  /// In en, this message translates to:
  /// **'Minimise'**
  String get botMinimise;

  /// No description provided for @botNewChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get botNewChat;

  /// No description provided for @botThinking.
  ///
  /// In en, this message translates to:
  /// **'THINKING'**
  String get botThinking;

  /// No description provided for @botOfflineLine.
  ///
  /// In en, this message translates to:
  /// **'The assistant needs a connection. Nothing is answered offline.'**
  String get botOfflineLine;

  /// No description provided for @botAskKitchen.
  ///
  /// In en, this message translates to:
  /// **'Ask about the kitchen…'**
  String get botAskKitchen;

  /// No description provided for @botAskDish.
  ///
  /// In en, this message translates to:
  /// **'Ask about this dish · v{version}'**
  String botAskDish(int version);

  /// No description provided for @botOutOfQuestions.
  ///
  /// In en, this message translates to:
  /// **'Out of questions for today'**
  String get botOutOfQuestions;

  /// No description provided for @botNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get botNoConnection;

  /// No description provided for @botCapNotice.
  ///
  /// In en, this message translates to:
  /// **'You have used today’s questions. They come back tomorrow.'**
  String get botCapNotice;

  /// No description provided for @botOfflineNotice.
  ///
  /// In en, this message translates to:
  /// **'The assistant needs a connection. Nothing here is answered offline.'**
  String get botOfflineNotice;

  /// No description provided for @botWhichDish.
  ///
  /// In en, this message translates to:
  /// **'Which dish did you mean? {choices}'**
  String botWhichDish(String choices);

  /// No description provided for @botAddedToFridge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item in the fridge.} other{{count} items in the fridge.}}'**
  String botAddedToFridge(int count);

  /// No description provided for @botDestructiveRefusal.
  ///
  /// In en, this message translates to:
  /// **'I can’t change your journal from here. Open the dish (or its ⋯ menu) and the real flow will do it.'**
  String get botDestructiveRefusal;

  /// No description provided for @botAddMissing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 missing} other{Add {count} missing}}'**
  String botAddMissing(int count);

  /// No description provided for @botAddedToList.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item added to your list} other{{count} items added to your list}}'**
  String botAddedToList(int count);

  /// No description provided for @botNotThis.
  ///
  /// In en, this message translates to:
  /// **'Not this'**
  String get botNotThis;

  /// No description provided for @botAddToFridgeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add to the fridge?'**
  String get botAddToFridgeQuestion;

  /// No description provided for @botAddCountToFridge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 item to fridge} other{Add {count} items to fridge}}'**
  String botAddCountToFridge(int count);

  /// No description provided for @botAmountUnknown.
  ///
  /// In en, this message translates to:
  /// **'amount?'**
  String get botAmountUnknown;

  /// No description provided for @botSuggestionMeta.
  ///
  /// In en, this message translates to:
  /// **'{source} · {have} of {total}'**
  String botSuggestionMeta(String source, int have, int total);

  /// No description provided for @botStarterFridge.
  ///
  /// In en, this message translates to:
  /// **'What\'s in your fridge?'**
  String get botStarterFridge;

  /// No description provided for @botStarterWall.
  ///
  /// In en, this message translates to:
  /// **'Show me something from the Wall'**
  String get botStarterWall;

  /// No description provided for @botStarterPhoto.
  ///
  /// In en, this message translates to:
  /// **'I have a photo of a dish'**
  String get botStarterPhoto;

  /// No description provided for @botStarterDinner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You have 1 thing in the fridge. Dinner from it?} other{You have {count} things in the fridge. Dinner from them?}}'**
  String botStarterDinner(int count);

  /// No description provided for @chatEarlier.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show earlier (1)} other{Show earlier ({count})}}'**
  String chatEarlier(int count);

  /// No description provided for @chatAboutStep.
  ///
  /// In en, this message translates to:
  /// **'about step {step}'**
  String chatAboutStep(int step);

  /// No description provided for @chatAskHint.
  ///
  /// In en, this message translates to:
  /// **'Ask, or hold the mic'**
  String get chatAskHint;

  /// No description provided for @chatResolveChange.
  ///
  /// In en, this message translates to:
  /// **'Resolve the change above'**
  String get chatResolveChange;

  /// No description provided for @chatAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get chatAsk;

  /// No description provided for @chatVersionDivider.
  ///
  /// In en, this message translates to:
  /// **'v{version} starts here'**
  String chatVersionDivider(int version);

  /// No description provided for @chatApplied.
  ///
  /// In en, this message translates to:
  /// **'V{version} · APPLIED'**
  String chatApplied(int version);

  /// No description provided for @chatOpenVersion.
  ///
  /// In en, this message translates to:
  /// **'Open v{version}'**
  String chatOpenVersion(int version);

  /// No description provided for @chatUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get chatUndo;

  /// No description provided for @chatRecipeChange.
  ///
  /// In en, this message translates to:
  /// **'RECIPE CHANGE'**
  String get chatRecipeChange;

  /// No description provided for @chatVersionArrow.
  ///
  /// In en, this message translates to:
  /// **'v{from} → v{to}'**
  String chatVersionArrow(int from, int to);

  /// No description provided for @chatMoreEdits.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{+1 more} other{+{count} more}}'**
  String chatMoreEdits(int count);

  /// No description provided for @chatCreatesVersion.
  ///
  /// In en, this message translates to:
  /// **'Creates v{version} — from this message'**
  String chatCreatesVersion(int version);

  /// No description provided for @chatRecompute.
  ///
  /// In en, this message translates to:
  /// **'Recompute'**
  String get chatRecompute;

  /// No description provided for @chatDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get chatDiscard;

  /// No description provided for @chatNotApplied.
  ///
  /// In en, this message translates to:
  /// **'NOT APPLIED'**
  String get chatNotApplied;

  /// No description provided for @chatNothingChanged.
  ///
  /// In en, this message translates to:
  /// **'Nothing changed in your recipe.'**
  String get chatNothingChanged;

  /// No description provided for @chatTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get chatTryAgain;

  /// No description provided for @chatApplying.
  ///
  /// In en, this message translates to:
  /// **'Applying…'**
  String get chatApplying;

  /// No description provided for @chatApplyAs.
  ///
  /// In en, this message translates to:
  /// **'Apply as v{version}'**
  String chatApplyAs(int version);

  /// No description provided for @importPasteFirst.
  ///
  /// In en, this message translates to:
  /// **'Paste a link first'**
  String get importPasteFirst;

  /// No description provided for @importNoLink.
  ///
  /// In en, this message translates to:
  /// **'The reel is ready but the server sent no link for it'**
  String get importNoLink;

  /// No description provided for @importCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'We could not start that import'**
  String get importCouldNotStart;

  /// No description provided for @importSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in from You to import'**
  String get importSignIn;

  /// No description provided for @importUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server'**
  String get importUnreachable;

  /// No description provided for @importLostConnection.
  ///
  /// In en, this message translates to:
  /// **'Lost the connection — the reel is still being read. Open this again to pick it up'**
  String get importLostConnection;

  /// No description provided for @importStillOnServer.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server — the reel is still on it. Open this again to pick it up'**
  String get importStillOnServer;

  /// No description provided for @importGone.
  ///
  /// In en, this message translates to:
  /// **'That reel is no longer on the server — try the link again'**
  String get importGone;

  /// No description provided for @importSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {title}'**
  String importSaved(String title);

  /// No description provided for @importNothingToSave.
  ///
  /// In en, this message translates to:
  /// **'Nothing to save'**
  String get importNothingToSave;

  /// No description provided for @importCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'The recipe came back but could not be saved — open this again'**
  String get importCouldNotSave;

  /// No description provided for @importOpenAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server — open this again in a minute'**
  String get importOpenAgain;

  /// No description provided for @importSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Save a reel'**
  String get importSheetTitle;

  /// No description provided for @importSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Paste a YouTube or Instagram link. It becomes a dish you can cook, with the creator attached.'**
  String get importSheetBody;

  /// No description provided for @importStillWorking.
  ///
  /// In en, this message translates to:
  /// **'Still working — this reel is long'**
  String get importStillWorking;

  /// No description provided for @importLongWait.
  ///
  /// In en, this message translates to:
  /// **'A long one takes a few minutes. You can leave this — the dish appears when it is ready.'**
  String get importLongWait;

  /// No description provided for @importCloseWait.
  ///
  /// In en, this message translates to:
  /// **'You can close this — the dish appears when it is ready.'**
  String get importCloseWait;

  /// No description provided for @importReading.
  ///
  /// In en, this message translates to:
  /// **'Reading…'**
  String get importReading;

  /// No description provided for @importReadLink.
  ///
  /// In en, this message translates to:
  /// **'Read this link'**
  String get importReadLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'bn',
        'en',
        'es',
        'fr',
        'hi',
        'id',
        'mr',
        'pt',
        'ta',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'mr':
      return AppLocalizationsMr();
    case 'pt':
      return AppLocalizationsPt();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
