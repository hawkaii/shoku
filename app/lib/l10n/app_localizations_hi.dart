// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get languageTitle => 'भाषा';

  @override
  String get languageSubtitle =>
      'शोकु आपकी भाषा में। आप इसे बाद में \"आप\" में बदल सकते हैं।';

  @override
  String get languageSystem => 'सिस्टम भाषा';

  @override
  String get languageSystemHint => 'फ़ोन की भाषा के अनुसार';

  @override
  String get languageTapToContinue => 'जारी रखने के लिए कोई भाषा चुनें';

  @override
  String get onboardingSkip => 'छोड़ें';

  @override
  String get onboardingStartCooking => 'खाना बनाना शुरू करें';

  @override
  String get onboardingShareCta => 'आज़माने के लिए एक रील शेयर करें';

  @override
  String get onboardingContinue => 'जारी रखें';

  @override
  String get onboardingOpenJournal => 'मेरी जर्नल खोलें';

  @override
  String get onboardingIntroTitle => 'एक बार पकाएँ।\nइसे अपना बनाएँ।';

  @override
  String get onboardingIntroBody =>
      'हर बार पकाते समय आप कुछ बदलते हैं। शोकु उन बदलावों को याद रखता है, ताकि अगली बार आप आज रात के लिए सही वर्ज़न चुन सकें।';

  @override
  String get onboardingShareStepLabel => '01 · रील शेयर करें';

  @override
  String get onboardingShareTitle => 'एक टैप, उसी ऐप से जिसमें आप पहले से हैं।';

  @override
  String get onboardingShareTo => 'इस पर शेयर करें';

  @override
  String get onboardingSaved => 'v1 के रूप में सहेजा · 4 सेकंड में निकाला';

  @override
  String get onboardingJournalStepLabel => '02 · पकाएँ, बदलें';

  @override
  String get onboardingJournalTitle => 'आपकी जर्नल बदलाव याद रखती है।';

  @override
  String get onboardingJournalBody =>
      'कुक मोड आपको रास्ता दिखाता है। जब कुछ बदलें, बताएँ। अंत में आपको एक वर्ज़न मिलता है — फ़ोटो, रेटिंग और जो बदला उसके साथ।';

  @override
  String get onboardingAltered => 'बदला';

  @override
  String get onboardingTap => 'टैप करें';

  @override
  String get authSheetTitle => 'अपनी जर्नल रखें';

  @override
  String get authSheetBody =>
      'साइन इन करने तक पकाना इस फ़ोन पर रहता है। साइन इन करने पर यह आपके हर डिवाइस पर आ जाता है।';

  @override
  String get authEmail => 'ईमेल';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authWorking => 'हो रहा है…';

  @override
  String get authCreateAccount => 'खाता बनाएँ';

  @override
  String get authSignIn => 'साइन इन करें';

  @override
  String get authHaveAccount => 'मेरा खाता पहले से है';

  @override
  String get authCreateAccountLink => 'खाता बनाएँ';

  @override
  String get authErrorEmailPassword => 'ईमेल और 6+ अक्षरों का पासवर्ड';

  @override
  String get authErrorConfirmEmail =>
      'पुष्टि के लिए अपना ईमेल देखें, फिर साइन इन करें';

  @override
  String get authErrorMismatch => 'वह ईमेल और पासवर्ड मेल नहीं खाते';

  @override
  String get authErrorUnconfirmed =>
      'वह खाता अभी पुष्ट नहीं है — अपना ईमेल देखें';

  @override
  String get authErrorExists => 'उस ईमेल पर खाता पहले से है — साइन इन करें';

  @override
  String get authErrorNoConnection => 'कनेक्शन नहीं है';

  @override
  String get authErrorGeneric => 'साइन इन नहीं हो सका';

  @override
  String get authNotSignedIn => 'साइन इन नहीं';

  @override
  String get authSignedIn => 'साइन इन है';

  @override
  String get authLocalOnly => 'पकाना सिर्फ़ इस फ़ोन पर रहता है।';

  @override
  String get authSignOut => 'साइन आउट';

  @override
  String get tabJournal => 'जर्नल';

  @override
  String get tabCookbook => 'कुकबुक';

  @override
  String get tabFridge => 'फ़्रिज';

  @override
  String get tabWall => 'वॉल';

  @override
  String get tabYou => 'आप';

  @override
  String journalKitchenTitle(String month) {
    return '$month की रसोई';
  }

  @override
  String journalDishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count व्यंजन',
      one: '1 व्यंजन',
      zero: 'अभी कोई व्यंजन नहीं',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सुधार',
      one: '1 सुधार',
      zero: 'कोई सुधार नहीं',
    );
    return '$_temp0';
  }

  @override
  String journalCooksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'बार पकाया',
      one: 'बार पकाया',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सुधार',
      one: 'सुधार',
    );
    return '$_temp0';
  }

  @override
  String journalEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रविष्टियाँ',
      one: '1 प्रविष्टि',
      zero: 'कोई प्रविष्टि नहीं',
    );
    return '$_temp0';
  }

  @override
  String get journalOnTheCounter => 'काउंटर पर';

  @override
  String get journalCookLog => 'कुक लॉग';

  @override
  String get journalCook => 'पकाएँ';

  @override
  String get journalFirstPage => 'आपका पहला पन्ना';

  @override
  String get journalFirstPageBody =>
      'एक बार पकाएँ — फ़ोटो, कैसा रहा, और एक चीज़ जो आपने बदली। वही v1 बन जाती है।';

  @override
  String get journalStartJournal => 'जर्नल शुरू करें →';

  @override
  String get journalNoDishes =>
      'अभी कोई व्यंजन नहीं — शुरू करने के लिए एक रील इंपोर्ट करें';

  @override
  String get journalOpening => 'आपकी जर्नल खुल रही है';

  @override
  String get journalErrorTitle => 'आपकी जर्नल नहीं खुल सकी';

  @override
  String get journalErrorBody => 'सहेजे गए पकाने अब भी इस फ़ोन पर हैं।';

  @override
  String get journalTryAgain => 'फिर कोशिश करें';

  @override
  String get journalSaveRecipe => 'एक रेसिपी सहेजें';

  @override
  String get cookbookTitle => 'कुकबुक';

  @override
  String cookbookCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पके',
      one: '1 पका',
      zero: 'कुछ नहीं पका',
    );
    return '$_temp0';
  }

  @override
  String get cookbookToCook => 'पकाने हैं';

  @override
  String get cookbookCooked => 'पके';

  @override
  String get cookbookNothingToCook => 'पकाने के लिए कुछ नहीं है।';

  @override
  String get cookbookNoCooksYet =>
      'अभी कोई पकाना नहीं। पकाने हैं में से कुछ चुनें।';

  @override
  String get cookbookNeverCooked => 'कभी नहीं पकाया';

  @override
  String cookbookLastCooked(String outcome) {
    return 'पिछली बार: $outcome';
  }

  @override
  String get badgeToCook => 'पकाने हैं';

  @override
  String get badgeCooked => 'पका';

  @override
  String badgeCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'पका $count×',
      one: 'पका $count×',
    );
    return '$_temp0';
  }

  @override
  String get badgeSignature => 'सिग्नेचर';

  @override
  String get outcomeNailedIt => 'बिल्कुल सही';

  @override
  String get outcomeGood => 'अच्छा';

  @override
  String get outcomeNeedsWork => 'सुधार चाहिए';

  @override
  String get moodQuick => 'जल्दी';

  @override
  String get moodProject => 'प्रोजेक्ट';

  @override
  String get moodComfort => 'आरामदेह';

  @override
  String minutesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनट',
      one: '1 मिनट',
    );
    return '$_temp0';
  }

  @override
  String get labelSample => 'नमूना';

  @override
  String get addSheetTitle => 'रेसिपी इंपोर्ट करें';

  @override
  String get addSheetSubtitle =>
      'एक रील एक व्यंजन बनती है जिसे आप पका और वर्ज़न कर सकते हैं।';

  @override
  String get addSheetLinkHint => 'Instagram या YouTube लिंक पेस्ट करें';

  @override
  String get addSheetShareOption => 'दूसरे ऐप से शेयर करें';

  @override
  String get addSheetShareHint => 'Instagram → शेयर → Shoku';

  @override
  String get addSheetScanOption => 'बारकोड स्कैन करें';

  @override
  String get addSheetScanHint => 'सीधे अपनी फ़्रिज में जोड़ें';

  @override
  String get addSheetBackendNote =>
      'एक्सट्रैक्शन सर्वर पर चलता है — यह बिल्ड सिर्फ़ इंटरफ़ेस है।';

  @override
  String get importHeadline => 'रील इंपोर्ट हो रही है';

  @override
  String get importQueued => 'कतार में';

  @override
  String get importWaking => 'रसोई जाग रही है…';

  @override
  String get importWaitingHint => 'रुकने के बाद पहली बार एक मिनट लगता है';

  @override
  String get importReadingReel => 'रील पढ़ी जा रही है';

  @override
  String get importReadingAudio => 'ऑडियो पढ़ा जा रहा है';

  @override
  String get importWritingRecipe => 'रेसिपी लिखी जा रही है';

  @override
  String get importWatchingVideo => 'वीडियो देखा जा रहा है';

  @override
  String get importReadingCaption => 'कैप्शन पढ़ा जा रहा है';

  @override
  String get importReady => 'तैयार';

  @override
  String get importFailedShort => 'यह नहीं पढ़ी जा सकी';

  @override
  String get reasonUnsupportedUrl =>
      'वह लिंक ऐसी रील या वीडियो नहीं है जिसे हम पढ़ सकें';

  @override
  String get reasonSourceBlocked =>
      'YouTube अभी हमारे सर्वर को रोक रहा है — बाद में कोशिश करें या रेसिपी पेस्ट करें';

  @override
  String get reasonTimeout => 'इसमें बहुत ज़्यादा समय लगा — फिर कोशिश करें';

  @override
  String get reasonWorkerUnavailable =>
      'रसोई नहीं जगी — एक मिनट में फिर कोशिश करें';

  @override
  String get reasonTimedOut =>
      'अब भी पढ़ रहे हैं — इसमें कुछ मिनट लग सकते हैं। आप जा सकते हैं, तैयार होने पर व्यंजन यहाँ मिलेगा';

  @override
  String get reasonGone => 'वह इंपोर्ट अब सर्वर पर नहीं है — लिंक फिर आज़माएँ';

  @override
  String get reasonInvalidRecipe => 'उसमें हमें कोई रेसिपी नहीं मिली';

  @override
  String get reasonNoAudio => 'उस वीडियो में सुनने के लिए कुछ नहीं है';

  @override
  String get reasonNoText => 'उस रील में न कैप्शन है न ऐसा बोल जो हम पढ़ सकें';

  @override
  String get reasonNoRecipe => 'वह वीडियो कोई रेसिपी नहीं दिखाता';

  @override
  String get reasonVisionFailed =>
      'हम वह वीडियो नहीं पढ़ सके — रेसिपी पेस्ट करें';

  @override
  String get reasonTakenDown => 'वह रेसिपी हटा दी गई थी';

  @override
  String get reasonUnknown => 'यह नहीं पढ़ी जा सकी — रेसिपी पेस्ट करें';
}
