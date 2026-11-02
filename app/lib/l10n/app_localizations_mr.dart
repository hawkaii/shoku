// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get languageTitle => 'भाषा';

  @override
  String get languageSubtitle =>
      'शोकु तुमच्या भाषेत. तुम्ही हे नंतर \"तुम्ही\" मध्ये बदलू शकता.';

  @override
  String get languageSystem => 'सिस्टम भाषा';

  @override
  String get languageSystemHint => 'फोनच्या भाषेनुसार';

  @override
  String get languageTapToContinue => 'पुढे जाण्यासाठी भाषा निवडा';

  @override
  String get onboardingSkip => 'वगळा';

  @override
  String get onboardingStartCooking => 'स्वयंपाक सुरू करा';

  @override
  String get onboardingShareCta => 'वापरून पाहण्यासाठी रील शेअर करा';

  @override
  String get onboardingContinue => 'सुरू ठेवा';

  @override
  String get onboardingOpenJournal => 'माझी जर्नल उघडा';

  @override
  String get onboardingIntroTitle => 'एकदा शिजवा.\nते तुमचे करा.';

  @override
  String get onboardingIntroBody =>
      'प्रत्येक वेळी शिजवताना तुम्ही काहीतरी बदलता. शोकु ते बदल लक्षात ठेवतो, म्हणून पुढच्या वेळी तुम्ही आजच्या रात्रीला योग्य आवृत्ती निवडू शकता.';

  @override
  String get onboardingShareStepLabel => '01 · रील शेअर करा';

  @override
  String get onboardingShareTitle =>
      'एक टॅप, तुम्ही आधीच ज्या ॲपमध्ये आहात त्यातून.';

  @override
  String get onboardingShareTo => 'येथे शेअर करा';

  @override
  String get onboardingSaved => 'v1 म्हणून जतन · 4 सेकंदात काढले';

  @override
  String get onboardingJournalStepLabel => '02 · शिजवा, बदला';

  @override
  String get onboardingJournalTitle => 'तुमची जर्नल बदल लक्षात ठेवते.';

  @override
  String get onboardingJournalBody =>
      'कुक मोड तुम्हाला मार्ग दाखवतो. काही बदलल्यास सांगा. शेवटी तुम्हाला एक आवृत्ती मिळते — फोटो, रेटिंग आणि काय बदलले यासह.';

  @override
  String get onboardingAltered => 'बदलले';

  @override
  String get onboardingTap => 'टॅप करा';

  @override
  String get authSheetTitle => 'तुमची जर्नल ठेवा';

  @override
  String get authSheetBody =>
      'साइन इन करेपर्यंत शिजवणे या फोनवर राहते. साइन इन केल्यावर ते तुमच्या प्रत्येक डिव्हाइसवर येते.';

  @override
  String get authEmail => 'ईमेल';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authWorking => 'सुरू आहे…';

  @override
  String get authCreateAccount => 'खाते तयार करा';

  @override
  String get authSignIn => 'साइन इन करा';

  @override
  String get authHaveAccount => 'माझे खाते आधीच आहे';

  @override
  String get authCreateAccountLink => 'खाते तयार करा';

  @override
  String get authErrorEmailPassword => 'ईमेल आणि 6+ अक्षरांचा पासवर्ड';

  @override
  String get authErrorConfirmEmail =>
      'पुष्टीसाठी तुमचा ईमेल पहा, नंतर साइन इन करा';

  @override
  String get authErrorMismatch => 'ते ईमेल आणि पासवर्ड जुळत नाहीत';

  @override
  String get authErrorUnconfirmed => 'ते खाते अजून पुष्ट नाही — तुमचा ईमेल पहा';

  @override
  String get authErrorExists => 'त्या ईमेलवर खाते आधीच आहे — साइन इन करा';

  @override
  String get authErrorNoConnection => 'कनेक्शन नाही';

  @override
  String get authErrorGeneric => 'साइन इन होऊ शकले नाही';

  @override
  String get authNotSignedIn => 'साइन इन नाही';

  @override
  String get authSignedIn => 'साइन इन आहात';

  @override
  String get authLocalOnly => 'शिजवणे फक्त या फोनवर राहते.';

  @override
  String get authSignOut => 'साइन आउट';

  @override
  String get tabJournal => 'जर्नल';

  @override
  String get tabCookbook => 'कुकबुक';

  @override
  String get tabFridge => 'फ्रिज';

  @override
  String get tabWall => 'वॉल';

  @override
  String get tabYou => 'तुम्ही';

  @override
  String journalKitchenTitle(String month) {
    return '$monthचे स्वयंपाकघर';
  }

  @override
  String journalDishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पदार्थ',
      one: '1 पदार्थ',
      zero: 'अजून काही पदार्थ नाहीत',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सुधारणा',
      one: '1 सुधारणा',
      zero: 'कोणतीही सुधारणा नाही',
    );
    return '$_temp0';
  }

  @override
  String journalCooksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'वेळा शिजवले',
      one: 'वेळ शिजवले',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सुधारणा',
      one: 'सुधारणा',
    );
    return '$_temp0';
  }

  @override
  String journalEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नोंदी',
      one: '1 नोंद',
      zero: 'कोणतीही नोंद नाही',
    );
    return '$_temp0';
  }

  @override
  String get journalOnTheCounter => 'काउंटरवर';

  @override
  String get journalCookLog => 'कुक लॉग';

  @override
  String get journalCook => 'शिजवा';

  @override
  String get journalFirstPage => 'तुमचे पहिले पान';

  @override
  String get journalFirstPageBody =>
      'एकदा शिजवा — फोटो, कसे झाले, आणि एक गोष्ट जी तुम्ही बदलली. तीच v1 होते.';

  @override
  String get journalStartJournal => 'जर्नल सुरू करा →';

  @override
  String get journalNoDishes =>
      'अजून काही पदार्थ नाहीत — सुरू करण्यासाठी रील इंपोर्ट करा';

  @override
  String get journalOpening => 'तुमची जर्नल उघडत आहे';

  @override
  String get journalErrorTitle => 'तुमची जर्नल उघडू शकली नाही';

  @override
  String get journalErrorBody => 'जतन केलेले स्वयंपाक अजूनही या फोनवर आहेत.';

  @override
  String get journalTryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get journalSaveRecipe => 'रेसिपी जतन करा';

  @override
  String get cookbookTitle => 'कुकबुक';

  @override
  String cookbookCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count शिजवले',
      one: '1 शिजवले',
      zero: 'काहीही शिजवले नाही',
    );
    return '$_temp0';
  }

  @override
  String get cookbookToCook => 'शिजवायचे';

  @override
  String get cookbookCooked => 'शिजवलेले';

  @override
  String get cookbookNothingToCook => 'शिजवण्यासाठी काहीही थांबलेले नाही.';

  @override
  String get cookbookNoCooksYet =>
      'अजून स्वयंपाक नाही. शिजवायचे मधून काहीतरी निवडा.';

  @override
  String get cookbookNeverCooked => 'कधीच शिजवले नाही';

  @override
  String cookbookLastCooked(String outcome) {
    return 'शेवटचे: $outcome';
  }

  @override
  String get badgeToCook => 'शिजवायचे';

  @override
  String get badgeCooked => 'शिजवलेले';

  @override
  String badgeCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'शिजवलेले $count×',
      one: 'शिजवलेले $count×',
    );
    return '$_temp0';
  }

  @override
  String get badgeSignature => 'सिग्नेचर';

  @override
  String get outcomeNailedIt => 'अगदी बरोबर';

  @override
  String get outcomeGood => 'चांगले';

  @override
  String get outcomeNeedsWork => 'सुधारणा हवी';

  @override
  String get moodQuick => 'पटकन';

  @override
  String get moodProject => 'प्रोजेक्ट';

  @override
  String get moodComfort => 'आरामदायी';

  @override
  String minutesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनिटे',
      one: '1 मिनिट',
    );
    return '$_temp0';
  }

  @override
  String get labelSample => 'नमुना';

  @override
  String get addSheetTitle => 'रेसिपी इंपोर्ट करा';

  @override
  String get addSheetSubtitle =>
      'एक रील एक पदार्थ बनते जो तुम्ही शिजवू आणि व्हर्जन करू शकता.';

  @override
  String get addSheetLinkHint => 'Instagram किंवा YouTube लिंक पेस्ट करा';

  @override
  String get addSheetShareOption => 'दुसऱ्या ॲपमधून शेअर करा';

  @override
  String get addSheetShareHint => 'Instagram → शेअर → Shoku';

  @override
  String get addSheetScanOption => 'बारकोड स्कॅन करा';

  @override
  String get addSheetScanHint => 'थेट तुमच्या फ्रिजमध्ये जोडा';

  @override
  String get addSheetBackendNote =>
      'एक्स्ट्रॅक्शन सर्व्हरवर चालते — हे बिल्ड फक्त इंटरफेस आहे.';

  @override
  String get importHeadline => 'रील इंपोर्ट होत आहे';

  @override
  String get importQueued => 'रांगेत';

  @override
  String get importWaking => 'स्वयंपाकघर जागे होत आहे…';

  @override
  String get importWaitingHint => 'थांबल्यानंतर पहिल्याला एक मिनिट लागते';

  @override
  String get importReadingReel => 'रील वाचली जात आहे';

  @override
  String get importReadingAudio => 'ऑडिओ वाचला जात आहे';

  @override
  String get importWritingRecipe => 'रेसिपी लिहिली जात आहे';

  @override
  String get importWatchingVideo => 'व्हिडिओ पाहिला जात आहे';

  @override
  String get importReadingCaption => 'कॅप्शन वाचले जात आहे';

  @override
  String get importReady => 'तयार';

  @override
  String get importFailedShort => 'हे वाचता आले नाही';

  @override
  String get reasonUnsupportedUrl =>
      'ती लिंक आम्ही वाचू शकतो अशी रील किंवा व्हिडिओ नाही';

  @override
  String get reasonSourceBlocked =>
      'YouTube आता आमचा सर्व्हर रोखत आहे — नंतर प्रयत्न करा किंवा रेसिपी पेस्ट करा';

  @override
  String get reasonTimeout => 'याला खूप वेळ लागला — पुन्हा प्रयत्न करा';

  @override
  String get reasonWorkerUnavailable =>
      'स्वयंपाकघर जागे झाले नाही — एका मिनिटात पुन्हा प्रयत्न करा';

  @override
  String get reasonTimedOut =>
      'अजून वाचत आहोत — याला काही मिनिटे लागू शकतात. तुम्ही जाऊ शकता, तयार झाल्यावर पदार्थ इथे असेल';

  @override
  String get reasonGone =>
      'ते इंपोर्ट आता सर्व्हरवर नाही — लिंक पुन्हा वापरून पहा';

  @override
  String get reasonInvalidRecipe => 'त्यात आम्हाला रेसिपी सापडली नाही';

  @override
  String get reasonNoAudio => 'त्या व्हिडिओमध्ये ऐकण्यासारखे काही नाही';

  @override
  String get reasonNoText =>
      'त्या रीलमध्ये कॅप्शन नाही किंवा आम्ही वाचू शकतो असा बोल नाही';

  @override
  String get reasonNoRecipe => 'तो व्हिडिओ रेसिपी दाखवत नाही';

  @override
  String get reasonVisionFailed =>
      'आम्ही तो व्हिडिओ वाचू शकलो नाही — रेसिपी पेस्ट करा';

  @override
  String get reasonTakenDown => 'ती रेसिपी काढून टाकली होती';

  @override
  String get reasonUnknown => 'हे वाचता आले नाही — रेसिपी पेस्ट करा';
}
