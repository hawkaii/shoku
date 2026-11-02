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
}
