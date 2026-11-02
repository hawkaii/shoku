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
  /// **'{count, plural, =1{cook} other{cooks}}'**
  String journalCooksLabel(int count);

  /// No description provided for @journalUpgradesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{upgrade} other{upgrades}}'**
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
  /// **'{count, plural, =1{COOKED {count}×} other{COOKED {count}×}}'**
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
  /// **'{count, plural, =1{1 min} other{{count} min}}'**
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
