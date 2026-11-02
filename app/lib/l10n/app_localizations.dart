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
