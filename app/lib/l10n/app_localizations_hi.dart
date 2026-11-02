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
  String get onboardingStartCooking => 'पकाना शुरू करें';

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
      'हर बार पकाते समय आप कुछ बदलते हैं। शोकु उन बदलावों को याद रखता है, ताकि अगली बार आप आज रात के लिए सही संस्करण चुन सकें।';

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
  String get tabCookbook => 'पाकपुस्तक';

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
  String get journalCookLog => 'पकाने का लॉग';

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
  String get cookbookTitle => 'पाकपुस्तक';

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
      'अभी कोई पकाना नहीं। पकाने हैं सूची में से कुछ चुनें।';

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
      'एक रील एक व्यंजन बनती है जिसे आप पका और संस्करण कर सकते हैं।';

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

  @override
  String get pantryTitle => 'फ़्रिज';

  @override
  String pantryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सामान',
      one: '1 सामान',
      zero: 'कोई सामान नहीं',
    );
    return '$_temp0';
  }

  @override
  String pantrySearchHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सामान खोजें',
      one: '1 सामान खोजें',
      zero: 'अपनी फ़्रिज खोजें',
    );
    return '$_temp0';
  }

  @override
  String pantrySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चुने',
      one: '1 चुना',
      zero: 'कुछ चुना नहीं',
    );
    return '$_temp0';
  }

  @override
  String get pantryEdit => 'बदलें';

  @override
  String get pantryShelfLabel => 'अपनी फ़्रिज से पकाएँ';

  @override
  String get pantryToBuy => 'खरीदना है';

  @override
  String get pantryInFridge => 'फ़्रिज में';

  @override
  String get pantryEmpty =>
      'फ़्रिज में अभी कुछ नहीं है। रसीद की फ़ोटो लें, या बस बताएँ कि इसमें क्या है।';

  @override
  String get pantryAddItems => 'सामान जोड़ें';

  @override
  String get pantryHowMuch => 'कितना?';

  @override
  String get pantryAmountExample => '2 kg';

  @override
  String get pantryCancel => 'रद्द करें';

  @override
  String get pantryDone => 'हो गया';

  @override
  String get pantryDelete => 'हटाएँ';

  @override
  String get pantrySelectItems => 'सामान चुनें';

  @override
  String pantryDeleteCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString हटाएँ',
      one: '1 हटाएँ',
    );
    return '$_temp0';
  }

  @override
  String pantryDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सामान हटाए',
      one: '1 सामान हटाया',
    );
    return '$_temp0';
  }

  @override
  String get pantrySetAmount => 'मात्रा तय करें';

  @override
  String pantryLessItem(String name) {
    return '$name कम';
  }

  @override
  String pantryMoreItem(String name) {
    return '$name ज़्यादा';
  }

  @override
  String get shelfEmpty =>
      'अभी सुझाव नहीं — कुछ सामान जोड़ें, मैं वॉल और आपके व्यंजन मिलाऊँगा।';

  @override
  String shelfBuyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count खरीदना है',
      one: '+1 खरीदना है',
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

    return '$totalString में से $haveString';
  }

  @override
  String get pantryEditTitle => 'सामान बदलें';

  @override
  String get pantryNameLabel => 'नाम';

  @override
  String get pantryAmountLabel => 'मात्रा';

  @override
  String get pantryAmountHelp =>
      'अगर पता है कि सामान है पर कितना नहीं, तो खाली छोड़ें।';

  @override
  String pantrySavedAs(String amount) {
    return '$amount के रूप में सहेजा';
  }

  @override
  String get pantrySave => 'सहेजें';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitTbsp => 'बड़ा चम्मच';

  @override
  String get unitTsp => 'छोटा चम्मच';

  @override
  String get unitPcs => 'पीस';

  @override
  String get unitBunch => 'गुच्छा';

  @override
  String get unitPack => 'पैक';

  @override
  String get pantryAddTitle => 'फ़्रिज में जोड़ें';

  @override
  String get pantryAddIntro =>
      'रसीद की फ़ोटो लें, रसोई में क्या है बताएँ, या लिखें। जब तक आप सूची न देखें, कुछ भी फ़्रिज में नहीं जाता।';

  @override
  String get pantryDoorPhoto => 'फ़ोटो';

  @override
  String get pantryDoorVoice => 'आवाज़';

  @override
  String get pantryDoorType => 'लिखें';

  @override
  String get pantryReview => 'जाँचें';

  @override
  String get pantryToAdd => 'जोड़ने हैं';

  @override
  String get pantryAiReading => 'बाकी पढ़ रहे हैं…';

  @override
  String get pantryAmountUnknown => 'मात्रा अज्ञात';

  @override
  String pantryCouldNotRead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'पढ़ा नहीं जा सका ($count)',
      one: 'पढ़ा नहीं जा सका (1)',
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
      other: '$totalString में से $checkedString जोड़ें',
      one: '1 में से $checkedString जोड़ें',
    );
    return '$_temp0';
  }

  @override
  String get pantryNoteOffline =>
      'रसीद पढ़ने के लिए कनेक्शन चाहिए। लिखें या बोलें।';

  @override
  String get pantryNoteUnreadable =>
      'उस फ़ोटो में कुछ पढ़ने लायक नहीं था — लिखें।';

  @override
  String get pantryCapReached => 'आज की AI रीडिंग खत्म — लिखें।';

  @override
  String get pantryPhotoButton => 'फ़ोटो या स्क्रीनशॉट';

  @override
  String get pantryPhotoHint =>
      'रसीद की फ़ोटो लें और पढ़ने वाला उसे लिख देगा। जब तक आप सूची न देखें, कुछ भी फ़्रिज में नहीं जाता।';

  @override
  String get pantryReadingReceipt => 'रसीद पढ़ी जा रही है…';

  @override
  String get pantryBackTooltip => 'फ़्रिज पर वापस';

  @override
  String get pantryTypeHint => '2 kg चावल, एक प्रति पंक्ति';

  @override
  String get pantryVoiceHint => 'माइक दबाए रखें और बताएँ रसोई में क्या है';

  @override
  String get pantryWhatIsIt => 'यह क्या है?';

  @override
  String get pantryVisionTitle => 'पढ़ने वाला Meta का मॉडल इस्तेमाल करता है';

  @override
  String get pantryVisionBody =>
      'फ़ोटो पढ़ने के लिए Meta के मॉडल को भेजी जाती है। यह सिर्फ़ उस एक कॉल के लिए इस्तेमाल होती है और संग्रह नहीं होती। पंक्तियाँ नीचे जाँच में आती हैं, जहाँ फ़्रिज में जाने से पहले आप कुछ भी ठीक कर सकते हैं।';

  @override
  String get pantryGotIt => 'समझ गया';

  @override
  String get pantryScreenshotOrPhoto => 'स्क्रीनशॉट या फ़ोटो';

  @override
  String get pantryCamera => 'कैमरा';

  @override
  String pantryInFridgeSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'फ़्रिज में $count सामान',
      one: 'फ़्रिज में 1 सामान',
    );
    return '$_temp0';
  }

  @override
  String get botNoDish => 'बिना व्यंजन';

  @override
  String get botDishFallback => 'व्यंजन';

  @override
  String botCookingStep(int step, int total) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'पकाते हुए · चरण $stepString / $totalString';
  }

  @override
  String get botTalkAbout => 'इस बारे में बात करें…';

  @override
  String get botThisDish => 'यह व्यंजन';

  @override
  String get botNoDishKitchen => 'बिना व्यंजन — रसोई';

  @override
  String get botOpen => 'खोलें';

  @override
  String get botMinimise => 'छोटा करें';

  @override
  String get botNewChat => 'नई चैट';

  @override
  String get botThinking => 'सोच रहे हैं';

  @override
  String get botOfflineLine =>
      'सहायक को कनेक्शन चाहिए। ऑफ़लाइन कुछ जवाब नहीं मिलता।';

  @override
  String get botAskKitchen => 'रसोई के बारे में पूछें…';

  @override
  String botAskDish(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'इस व्यंजन के बारे में पूछें · v$versionString';
  }

  @override
  String get botOutOfQuestions => 'आज के सवाल खत्म';

  @override
  String get botNoConnection => 'कनेक्शन नहीं';

  @override
  String get botCapNotice => 'आपने आज के सवाल इस्तेमाल कर लिए। वे कल लौटेंगे।';

  @override
  String get botOfflineNotice =>
      'सहायक को कनेक्शन चाहिए। यहाँ ऑफ़लाइन कुछ जवाब नहीं मिलता।';

  @override
  String botWhichDish(String choices) {
    return 'आपका मतलब कौन सा व्यंजन था? $choices';
  }

  @override
  String botAddedToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'फ़्रिज में $count सामान।',
      one: 'फ़्रिज में 1 सामान।',
    );
    return '$_temp0';
  }

  @override
  String get botDestructiveRefusal =>
      'मैं यहाँ से आपकी जर्नल नहीं बदल सकता। व्यंजन (या उसका ⋯ मेन्यू) खोलें, असली फ़्लो वह कर देगा।';

  @override
  String botAddMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गुम जोड़ें',
      one: '1 गुम जोड़ें',
    );
    return '$_temp0';
  }

  @override
  String botAddedToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सामान आपकी सूची में जोड़े',
      one: '1 सामान आपकी सूची में जोड़ा',
    );
    return '$_temp0';
  }

  @override
  String get botNotThis => 'यह नहीं';

  @override
  String get botAddToFridgeQuestion => 'फ़्रिज में जोड़ें?';

  @override
  String botAddCountToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'फ़्रिज में $count सामान जोड़ें',
      one: 'फ़्रिज में 1 सामान जोड़ें',
    );
    return '$_temp0';
  }

  @override
  String get botAmountUnknown => 'मात्रा?';

  @override
  String botSuggestionMeta(String source, int have, int total) {
    final intl.NumberFormat haveNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String haveString = haveNumberFormat.format(have);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$source · $totalString में से $haveString';
  }

  @override
  String get botStarterFridge => 'आपकी फ़्रिज में क्या है?';

  @override
  String get botStarterWall => 'मुझे वॉल से कुछ दिखाएँ';

  @override
  String get botStarterPhoto => 'मेरे पास एक व्यंजन की फ़ोटो है';

  @override
  String botStarterDinner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'फ़्रिज में आपके पास $count चीज़ें हैं। उनसे रात का खाना?',
      one: 'फ़्रिज में आपके पास 1 चीज़ है। उससे रात का खाना?',
    );
    return '$_temp0';
  }

  @override
  String chatEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'पिछले दिखाएँ ($count)',
      one: 'पिछला दिखाएँ (1)',
    );
    return '$_temp0';
  }

  @override
  String chatAboutStep(int step) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'चरण $stepString के बारे में';
  }

  @override
  String get chatAskHint => 'पूछें, या माइक दबाए रखें';

  @override
  String get chatResolveChange => 'ऊपर का बदलाव सुलझाएँ';

  @override
  String get chatAsk => 'पूछें';

  @override
  String chatVersionDivider(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString यहाँ से शुरू';
  }

  @override
  String chatApplied(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'V$versionString · लागू';
  }

  @override
  String chatOpenVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString खोलें';
  }

  @override
  String get chatUndo => 'पूर्ववत करें';

  @override
  String get chatRecipeChange => 'रेसिपी बदलाव';

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
      other: '+$count और',
      one: '+1 और',
    );
    return '$_temp0';
  }

  @override
  String chatCreatesVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString बनाता है — इस संदेश से';
  }

  @override
  String get chatRecompute => 'फिर गणना करें';

  @override
  String get chatDiscard => 'छोड़ें';

  @override
  String get chatNotApplied => 'लागू नहीं';

  @override
  String get chatNothingChanged => 'आपकी रेसिपी में कुछ नहीं बदला।';

  @override
  String get chatTryAgain => 'फिर कोशिश करें';

  @override
  String get chatApplying => 'लागू हो रहा है…';

  @override
  String chatApplyAs(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString के रूप में लागू करें';
  }

  @override
  String get importPasteFirst => 'पहले एक लिंक पेस्ट करें';

  @override
  String get importNoLink => 'रील तैयार है पर सर्वर ने कोई लिंक नहीं भेजा';

  @override
  String get importCouldNotStart => 'वह इंपोर्ट शुरू नहीं हो सका';

  @override
  String get importSignIn => 'इंपोर्ट के लिए आप में साइन इन करें';

  @override
  String get importUnreachable => 'सर्वर तक नहीं पहुँच सके';

  @override
  String get importLostConnection =>
      'कनेक्शन टूटा — रील अब भी पढ़ी जा रही है। दोबारा खोलकर इसे पूरा करें';

  @override
  String get importStillOnServer =>
      'सर्वर तक नहीं पहुँच सके — रील अब भी वहाँ है। दोबारा खोलकर इसे पूरा करें';

  @override
  String get importGone => 'वह रील अब सर्वर पर नहीं है — लिंक फिर आज़माएँ';

  @override
  String importSaved(String title) {
    return '$title सहेजा';
  }

  @override
  String get importNothingToSave => 'सहेजने के लिए कुछ नहीं';

  @override
  String get importCouldNotSave =>
      'रेसिपी लौटी पर सहेजी नहीं जा सकी — दोबारा खोलें';

  @override
  String get importOpenAgain =>
      'सर्वर तक नहीं पहुँच सके — एक मिनट में दोबारा खोलें';

  @override
  String get importSheetTitle => 'रील सहेजें';

  @override
  String get importSheetBody =>
      'YouTube या Instagram लिंक पेस्ट करें। यह एक व्यंजन बन जाती है जिसे आप पका सकते हैं, क्रिएटर के साथ।';

  @override
  String get importStillWorking => 'अब भी काम चल रहा है — यह रील लंबी है';

  @override
  String get importLongWait =>
      'लंबी रील में कुछ मिनट लगते हैं। आप जा सकते हैं; तैयार होने पर व्यंजन आ जाएगा।';

  @override
  String get importCloseWait =>
      'आप इसे बंद कर सकते हैं; तैयार होने पर व्यंजन आ जाएगा।';

  @override
  String get importReading => 'पढ़ रहे हैं…';

  @override
  String get importReadLink => 'यह लिंक पढ़ें';

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
}
