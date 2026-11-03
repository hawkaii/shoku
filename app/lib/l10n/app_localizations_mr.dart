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
  String get tabCookbook => 'पाकपुस्तक';

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
  String get journalCookLog => 'शिजवण्याचा लॉग';

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
  String get cookbookTitle => 'पाकपुस्तक';

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
      'अजून स्वयंपाक नाही. शिजवायचे यादीतून काहीतरी निवडा.';

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
      'एक रील एक पदार्थ बनते जो तुम्ही शिजवू आणि आवृत्ती करू शकता.';

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

  @override
  String get pantryTitle => 'फ्रिज';

  @override
  String pantryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तू',
      one: '1 वस्तू',
      zero: 'काही वस्तू नाही',
    );
    return '$_temp0';
  }

  @override
  String pantrySearchHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तू शोधा',
      one: '1 वस्तू शोधा',
      zero: 'तुमच्या फ्रिजमध्ये शोधा',
    );
    return '$_temp0';
  }

  @override
  String pantrySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count निवडले',
      one: '1 निवडले',
      zero: 'काहीही निवडले नाही',
    );
    return '$_temp0';
  }

  @override
  String get pantryEdit => 'बदला';

  @override
  String get pantryShelfLabel => 'तुमच्या फ्रिजमधून शिजवा';

  @override
  String get pantryToBuy => 'खरेदी करायचे';

  @override
  String get pantryInFridge => 'फ्रिजमध्ये';

  @override
  String get pantryEmpty =>
      'फ्रिजमध्ये अजून काहीही नाही. पावतीचा फोटो घ्या, किंवा त्यात काय आहे ते सांगा.';

  @override
  String get pantryAddItems => 'वस्तू जोडा';

  @override
  String get pantryHowMuch => 'किती?';

  @override
  String get pantryAmountExample => '2 kg';

  @override
  String get pantryCancel => 'रद्द करा';

  @override
  String get pantryDone => 'झाले';

  @override
  String get pantryDelete => 'काढा';

  @override
  String get pantrySelectItems => 'वस्तू निवडा';

  @override
  String pantryDeleteCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString काढा',
      one: '1 काढा',
    );
    return '$_temp0';
  }

  @override
  String pantryDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तू काढल्या',
      one: '1 वस्तू काढली',
    );
    return '$_temp0';
  }

  @override
  String get pantrySetAmount => 'प्रमाण ठरवा';

  @override
  String pantryLessItem(String name) {
    return '$name कमी';
  }

  @override
  String pantryMoreItem(String name) {
    return '$name जास्त';
  }

  @override
  String get shelfEmpty =>
      'अजून सूचना नाहीत — काही वस्तू जोडा, मी वॉल आणि तुमचे पदार्थ जुळवीन.';

  @override
  String shelfBuyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count खरेदी करायचे',
      one: '+1 खरेदी करायचे',
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

    return '$totalString पैकी $haveString';
  }

  @override
  String get pantryEditTitle => 'वस्तू बदला';

  @override
  String get pantryNameLabel => 'नाव';

  @override
  String get pantryAmountLabel => 'प्रमाण';

  @override
  String get pantryAmountHelp =>
      'वस्तू आहे हे माहीत असेल पण किती नाही, तर रिकामे ठेवा.';

  @override
  String pantrySavedAs(String amount) {
    return '$amount म्हणून जतन';
  }

  @override
  String get pantrySave => 'जतन करा';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitTbsp => 'मोठा चमचा';

  @override
  String get unitTsp => 'लहान चमचा';

  @override
  String get unitPcs => 'नग';

  @override
  String get unitBunch => 'गड्डी';

  @override
  String get unitPack => 'पॅक';

  @override
  String get pantryAddTitle => 'फ्रिजमध्ये जोडा';

  @override
  String get pantryAddIntro =>
      'पावतीचा फोटो घ्या, स्वयंपाकघरात काय आहे ते सांगा, किंवा लिहा. तुम्ही यादी पाहेपर्यंत काहीही फ्रिजमध्ये जात नाही.';

  @override
  String get pantryDoorPhoto => 'फोटो';

  @override
  String get pantryDoorVoice => 'आवाज';

  @override
  String get pantryDoorType => 'लिहा';

  @override
  String get pantryReview => 'तपासा';

  @override
  String get pantryToAdd => 'जोडायचे';

  @override
  String get pantryAiReading => 'उरलेले वाचत आहोत…';

  @override
  String get pantryAmountUnknown => 'प्रमाण अज्ञात';

  @override
  String pantryCouldNotRead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'वाचता आले नाही ($count)',
      one: 'वाचता आले नाही (1)',
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
      other: '$totalString पैकी $checkedString जोडा',
      one: '1 पैकी $checkedString जोडा',
    );
    return '$_temp0';
  }

  @override
  String get pantryNoteOffline =>
      'पावती वाचण्यासाठी कनेक्शन हवे. लिहा किंवा बोला.';

  @override
  String get pantryNoteUnreadable =>
      'त्या फोटोत वाचण्यासारखे काही नव्हते — लिहा.';

  @override
  String get pantryCapReached => 'आजची AI वाचने संपली — लिहा.';

  @override
  String get pantryPhotoButton => 'फोटो किंवा स्क्रीनशॉट';

  @override
  String get pantryPhotoHint =>
      'पावतीचा फोटो घ्या आणि वाचणारा ती लिहील. तुम्ही यादी पाहेपर्यंत काहीही फ्रिजमध्ये जात नाही.';

  @override
  String get pantryReadingReceipt => 'पावती वाचली जात आहे…';

  @override
  String get pantryBackTooltip => 'फ्रिजवर परत';

  @override
  String get pantryTypeHint => '2 kg भात, एका ओळीत एक';

  @override
  String get pantryVoiceHint =>
      'माइक दाबून धरा आणि स्वयंपाकघरात काय आहे ते सांगा';

  @override
  String get pantryWhatIsIt => 'हे काय आहे?';

  @override
  String get pantryVisionTitle => 'वाचणारा Meta चा मॉडेल वापरतो';

  @override
  String get pantryVisionBody =>
      'फोटो वाचण्यासाठी Meta च्या मॉडेलला पाठवला जातो. तो फक्त त्या एका कॉलसाठी वापरला जातो आणि साठवला जात नाही. ओळी खालील तपासणीत येतात, जिथे फ्रिजमध्ये जाण्यापूर्वी तुम्ही काहीही दुरुस्त करू शकता.';

  @override
  String get pantryGotIt => 'समजले';

  @override
  String get pantryScreenshotOrPhoto => 'स्क्रीनशॉट किंवा फोटो';

  @override
  String get pantryCamera => 'कॅमेरा';

  @override
  String pantryInFridgeSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'फ्रिजमध्ये $count वस्तू',
      one: 'फ्रिजमध्ये 1 वस्तू',
    );
    return '$_temp0';
  }

  @override
  String get botNoDish => 'पदार्थ नाही';

  @override
  String get botDishFallback => 'पदार्थ';

  @override
  String botCookingStep(int step, int total) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'शिजवताना · पायरी $stepString / $totalString';
  }

  @override
  String get botTalkAbout => 'याबद्दल बोला…';

  @override
  String get botThisDish => 'हा पदार्थ';

  @override
  String get botNoDishKitchen => 'पदार्थ नाही — स्वयंपाकघर';

  @override
  String get botOpen => 'उघडा';

  @override
  String get botMinimise => 'लहान करा';

  @override
  String get botNewChat => 'नवीन चॅट';

  @override
  String get botThinking => 'विचार करत आहोत';

  @override
  String get botOfflineLine =>
      'सहाय्यकाला कनेक्शन हवे. ऑफलाइन काहीही उत्तर मिळत नाही.';

  @override
  String get botAskKitchen => 'स्वयंपाकघराबद्दल विचारा…';

  @override
  String botAskDish(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'या पदार्थाबद्दल विचारा · v$versionString';
  }

  @override
  String get botOutOfQuestions => 'आजचे प्रश्न संपले';

  @override
  String get botNoConnection => 'कनेक्शन नाही';

  @override
  String get botCapNotice => 'तुम्ही आजचे प्रश्न वापरले. ते उद्या परत येतील.';

  @override
  String get botOfflineNotice =>
      'सहाय्यकाला कनेक्शन हवे. इथे ऑफलाइन काहीही उत्तर मिळत नाही.';

  @override
  String botWhichDish(String choices) {
    return 'तुमचा अर्थ कोणता पदार्थ होता? $choices';
  }

  @override
  String botAddedToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'फ्रिजमध्ये $count वस्तू.',
      one: 'फ्रिजमध्ये 1 वस्तू.',
    );
    return '$_temp0';
  }

  @override
  String get botDestructiveRefusal =>
      'मी इथून तुमची जर्नल बदलू शकत नाही. पदार्थ (किंवा त्याचा ⋯ मेनू) उघडा, खरा प्रवाह ते करेल.';

  @override
  String botAddMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गहाळ जोडा',
      one: '1 गहाळ जोडा',
    );
    return '$_temp0';
  }

  @override
  String botAddedToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तू तुमच्या यादीत जोडल्या',
      one: '1 वस्तू तुमच्या यादीत जोडली',
    );
    return '$_temp0';
  }

  @override
  String get botNotThis => 'हे नाही';

  @override
  String get botAddToFridgeQuestion => 'फ्रिजमध्ये जोडायचे?';

  @override
  String botAddCountToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'फ्रिजमध्ये $count वस्तू जोडा',
      one: 'फ्रिजमध्ये 1 वस्तू जोडा',
    );
    return '$_temp0';
  }

  @override
  String get botAmountUnknown => 'प्रमाण?';

  @override
  String botSuggestionMeta(String source, int have, int total) {
    final intl.NumberFormat haveNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String haveString = haveNumberFormat.format(have);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$source · $totalString पैकी $haveString';
  }

  @override
  String get botStarterFridge => 'तुमच्या फ्रिजमध्ये काय आहे?';

  @override
  String get botStarterWall => 'मला वॉलवरून काही दाखवा';

  @override
  String get botStarterPhoto => 'माझ्याकडे एका पदार्थाचा फोटो आहे';

  @override
  String botStarterDinner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'तुमच्या फ्रिजमध्ये $count गोष्टी आहेत. त्यांनी रात्रीचे जेवण?',
      one: 'तुमच्या फ्रिजमध्ये 1 गोष्ट आहे. तिच्याने रात्रीचे जेवण?',
    );
    return '$_temp0';
  }

  @override
  String chatEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'मागील दाखवा ($count)',
      one: 'मागील दाखवा (1)',
    );
    return '$_temp0';
  }

  @override
  String chatAboutStep(int step) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'पायरी $stepString बद्दल';
  }

  @override
  String get chatAskHint => 'विचारा, किंवा माइक दाबून धरा';

  @override
  String get chatResolveChange => 'वरचा बदल सोडवा';

  @override
  String get chatAsk => 'विचारा';

  @override
  String chatVersionDivider(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString इथून सुरू';
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

    return 'v$versionString उघडा';
  }

  @override
  String get chatUndo => 'पूर्ववत करा';

  @override
  String get chatRecipeChange => 'रेसिपी बदल';

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
      other: '+$count अजून',
      one: '+1 अजून',
    );
    return '$_temp0';
  }

  @override
  String chatCreatesVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString तयार करते — या संदेशातून';
  }

  @override
  String get chatRecompute => 'पुन्हा मोजा';

  @override
  String get chatDiscard => 'सोडा';

  @override
  String get chatNotApplied => 'लागू नाही';

  @override
  String get chatNothingChanged => 'तुमच्या रेसिपीत काहीही बदलले नाही.';

  @override
  String get chatTryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get chatApplying => 'लागू होत आहे…';

  @override
  String chatApplyAs(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString म्हणून लागू करा';
  }

  @override
  String get importPasteFirst => 'आधी लिंक पेस्ट करा';

  @override
  String get importNoLink => 'रील तयार आहे पण सर्व्हरने लिंक पाठवला नाही';

  @override
  String get importCouldNotStart => 'ते इंपोर्ट सुरू होऊ शकले नाही';

  @override
  String get importSignIn => 'इंपोर्टसाठी तुम्ही मध्ये साइन इन करा';

  @override
  String get importUnreachable => 'सर्व्हरपर्यंत पोहोचता आले नाही';

  @override
  String get importLostConnection =>
      'कनेक्शन गेले — रील अजून वाचली जात आहे. पुन्हा उघडून पूर्ण करा';

  @override
  String get importStillOnServer =>
      'सर्व्हरपर्यंत पोहोचता आले नाही — रील अजून तिथे आहे. पुन्हा उघडून पूर्ण करा';

  @override
  String get importGone => 'ती रील आता सर्व्हरवर नाही — लिंक पुन्हा वापरून पहा';

  @override
  String importSaved(String title) {
    return '$title जतन केले';
  }

  @override
  String get importNothingToSave => 'जतन करण्यासाठी काही नाही';

  @override
  String get importCouldNotSave =>
      'रेसिपी परत आली पण जतन होऊ शकली नाही — पुन्हा उघडा';

  @override
  String get importOpenAgain =>
      'सर्व्हरपर्यंत पोहोचता आले नाही — एका मिनिटात पुन्हा उघडा';

  @override
  String get importSheetTitle => 'रील जतन करा';

  @override
  String get importSheetBody =>
      'YouTube किंवा Instagram लिंक पेस्ट करा. ती एक पदार्थ बनते जो तुम्ही शिजवू शकता, निर्मात्यासह.';

  @override
  String get importStillWorking => 'अजून काम चालू आहे — ही रील लांब आहे';

  @override
  String get importLongWait =>
      'लांब रीलला काही मिनिटे लागतात. तुम्ही जाऊ शकता; तयार झाल्यावर पदार्थ येईल.';

  @override
  String get importCloseWait =>
      'तुम्ही हे बंद करू शकता; तयार झाल्यावर पदार्थ येईल.';

  @override
  String get importReading => 'वाचत आहोत…';

  @override
  String get importReadLink => 'ही लिंक वाचा';

  @override
  String get dishSampleGate =>
      'तुमच्या रील इंपोर्ट करण्यासाठी आणि रेसिपीशी बोलण्यासाठी साइन इन करा.';

  @override
  String dishCookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वेळा शिजवले',
      one: '1 वेळ शिजवले',
    );
    return '$_temp0';
  }

  @override
  String get dishFromVideoNote => 'व्हिडिओतून वाचले — प्रमाण चुकू शकते';

  @override
  String dishVersionGone(int from, int to) {
    final intl.NumberFormat fromNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String fromString = fromNumberFormat.format(from);
    final intl.NumberFormat toNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String toString = toNumberFormat.format(to);

    return 'v$fromString आता नाही — v$toString दाखवत आहोत';
  }

  @override
  String get dishStartCookMode => 'कुक मोड सुरू करा';

  @override
  String get dishReadRecipe => 'ही रेसिपी वाचा';

  @override
  String get dishMore => 'अधिक';

  @override
  String get dishMenuCooked => 'मी नुकतेच हे शिजवले';

  @override
  String get dishMarkToCook => 'शिजवायचे म्हणून चिन्हांकित करा';

  @override
  String get dishSetUpFridge => 'तुमचा फ्रिज सेट करा';

  @override
  String dishAddMissingToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'यादीत $count गहाळ जोडा',
      one: 'यादीत 1 गहाळ जोडा',
    );
    return '$_temp0';
  }

  @override
  String dishAddedToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'तुमच्या यादीत $count जोडले',
      one: 'तुमच्या यादीत 1 जोडले',
    );
    return '$_temp0';
  }

  @override
  String dishIngredientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सामग्री',
      one: '1 सामग्री',
    );
    return '$_temp0';
  }

  @override
  String dishMissingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गहाळ',
      one: '1 गहाळ',
    );
    return '$_temp0';
  }

  @override
  String get dishPickVersion => 'एक आवृत्ती निवडा';

  @override
  String dishVersionShowing(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString · दाखवत आहोत';
  }

  @override
  String dishStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पायऱ्या',
      one: '1 पायरी',
    );
    return '$_temp0';
  }

  @override
  String dishAskAboutStep(int step) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'पायरी $stepString बद्दल विचारा';
  }

  @override
  String get dishHistory => 'इतिहास';

  @override
  String get dishNotCookedYet => 'अजून शिजवलेले नाही. पहिला लॉग v1 होतो.';

  @override
  String dishHistoryEntry(int version, String outcome) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString · $outcome';
  }

  @override
  String get dishWhatAltered => 'काय बदलले';

  @override
  String get dishFromChatEdit => 'चॅट संपादनातून';

  @override
  String get dishNoNote => 'टीप नाही';

  @override
  String get dishUnavailableTitle => 'हा पदार्थ इथे नाही';

  @override
  String get dishUnavailableBody =>
      'कदाचित अजून लोड होत आहे, किंवा काढून टाकला आहे.';

  @override
  String get dishBackToJournal => 'जर्नलवर परत';

  @override
  String get dishImported => 'इंपोर्ट केले';

  @override
  String get dishTheSource => 'स्रोत';

  @override
  String get dishViewReel => 'रील पाहा';

  @override
  String get logTitle => 'आजच्या रात्रीचे शिजवणे नोंदवा';

  @override
  String get logSnapResult => 'आजच्या रात्रीचा निकाल फोटोत घ्या';

  @override
  String get logPhotoReady => 'फोटो अपलोडसाठी तयार';

  @override
  String get logHowDidItGo => 'कसे झाले';

  @override
  String get logNoteLabel => 'तुमच्यासाठी एक टीप';

  @override
  String get logNoteHint => 'पॅन जास्त गरम झाला होता, म्हणून लवकर काढला';

  @override
  String get logChangeLabel => 'काय बदलले';

  @override
  String get logChangeHint =>
      'जास्त लिंबू, 2 मिनिटे कमी, तळण्याऐवजी एअर फ्रायरमध्ये';

  @override
  String get logSaveWithPhoto => 'फोटोसह जतन करा';

  @override
  String get logSaveTonight => 'आज रात्री जतन करा';

  @override
  String logSaveUpgrade(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'जतन करा आणि v$versionString बनवा';
  }

  @override
  String get logSaveFailed => 'ते शिजवणे जतन होऊ शकले नाही';

  @override
  String logSaved(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString म्हणून नोंदवले';
  }

  @override
  String logSavedWithOutcome(int version, String outcome) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString म्हणून नोंदवले · $outcome';
  }

  @override
  String get debriefTitle => 'कसे झाले?';

  @override
  String debriefSubtitle(String title, int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return '$title · v$versionString होईल';
  }

  @override
  String get debriefAddPhoto => 'फोटो जोडा';

  @override
  String get debriefChangePhoto => 'फोटो बदला';

  @override
  String get debriefRating => 'रेटिंग';

  @override
  String get debriefMoodLabel => 'कसले शिजवणे होते';

  @override
  String get debriefChangesLabel => 'मूळपासून काय बदलले';

  @override
  String get debriefNoChanges => 'अजून काही नाही — जे वेगळे केले ते जोडा.';

  @override
  String get debriefChangeHint => 'उदा. 3 ऐवजी 2 मोठे चमचे मध';

  @override
  String get debriefNoteLabel => 'काय कमी होते';

  @override
  String get debriefNoteHint => '“आंबटपणा कमी होता, पुढच्या वेळी लिंबू घाला”';

  @override
  String get debriefPantryLabel => 'फ्रिजमधून वापरले';

  @override
  String get debriefDeduct => 'जे जुळते ते वजा करा';

  @override
  String debriefSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ओळी वजा केल्या नाहीत',
      one: '1 ओळ वजा केली नाही',
    );
    return '$_temp0';
  }

  @override
  String debriefSave(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString म्हणून जतन करा';
  }

  @override
  String debriefSaveUpgrade(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'जतन करा आणि v$versionString बनवा';
  }

  @override
  String get debriefSaveFailed => 'हे शिजवणे जतन होऊ शकले नाही';

  @override
  String debriefSaved(int version, String mood) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString म्हणून जतन केले · $mood';
  }

  @override
  String get wallSubtitleEmpty => 'लोकांनी इंपोर्ट केलेल्या रील';

  @override
  String wallReelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रील',
      one: '1 रील',
    );
    return '$_temp0';
  }

  @override
  String get wallMoreBelow => 'आणखी खाली';

  @override
  String get wallReelGone => 'ती रील आता सर्व्हरवर नाही';

  @override
  String wallSavedToCookbook(String title) {
    return '$title तुमच्या पाकपुस्तकात जतन केले';
  }

  @override
  String get wallInCookbook => 'तुमच्या पाकपुस्तकात';

  @override
  String get wallSaving => 'जतन करत आहोत…';

  @override
  String get wallAddToCookbook => 'पाकपुस्तकात जोडा';

  @override
  String get wallLoadFailed => 'वॉल लोड झाली नाही';

  @override
  String get wallEmptyTitle => 'अजून काहीही इंपोर्ट केलेले नाही';

  @override
  String get wallEmptyBody => 'एक रील इंपोर्ट करा आणि ती इथे सर्वांसाठी येईल.';

  @override
  String get wallImportReel => 'रील इंपोर्ट करा';

  @override
  String get wallLoadMoreFailed =>
      'आणखी लोड होऊ शकले नाही — पुन्हा प्रयत्न करा';

  @override
  String get wallMoreReels => 'आणखी रील';

  @override
  String get wallEndOfFeed => 'सध्या एवढ्याच रील';

  @override
  String wallStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पायऱ्या',
      one: '1 पायरी',
    );
    return '$_temp0';
  }

  @override
  String wallIngredientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सामग्री',
      one: '1 सामग्री',
    );
    return '$_temp0';
  }

  @override
  String get wallMethod => 'पद्धत';

  @override
  String get wallReelLoadFailed => 'ही रील लोड झाली नाही';

  @override
  String get actionMarkCooked => 'शिजवले म्हणून चिन्हांकित करा';

  @override
  String get actionMoveBackToCook => 'परत शिजवायच्या यादीत न्या';

  @override
  String get actionNeverCooked => 'कधीच शिजवलेले नाही';

  @override
  String actionCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वेळा शिजवले',
      one: '1 वेळ शिजवले',
    );
    return '$_temp0';
  }

  @override
  String get actionStatusCookedBody =>
      'हे शिजवलेल्यांत जाते. तुम्ही परत आणू शकता.';

  @override
  String get actionStatusToCookBody =>
      'हे शिजवायच्या यादीत जाते, पुन्हा बनवण्यासाठी तयार.';

  @override
  String get actionDeleteBody => 'तुमच्या जर्नलमधून निघते. आधी विचारते.';

  @override
  String get actionKeep => 'ठेवा';

  @override
  String get actionRemoveTitle => 'हा पदार्थ काढायचा?';

  @override
  String actionRemoveBody(String title) {
    return '$title त्याच्या आवृत्त्या आणि शिजवण्यांसह तुमच्या जर्नलमधून निघतो. पुन्हा इंपोर्ट करायचे असेल तर रील तिथेच आहे — ही प्रत परत येणार नाही.';
  }

  @override
  String get actionRemove => 'काढा';

  @override
  String get profileSubtitle => 'तुम्ही खरंच काय शिजवले याची नोंद.';

  @override
  String get profileAccount => 'खाते';

  @override
  String get profileComingSoon => 'लवकरच';

  @override
  String get profileNutritionBody =>
      'भविष्यात एक नजर — तुमच्या आवृत्त्या पदार्थ कसा बदलतात.';

  @override
  String get profileSoon => 'लवकरच';

  @override
  String get profileAppearance => 'स्वरूप';

  @override
  String get profileThemeSystem => 'सिस्टम';

  @override
  String get profileThemeLight => 'फिकट';

  @override
  String get profileThemeDark => 'गडद';

  @override
  String get profileHowItWorks => 'Shoku कसे चालते';

  @override
  String get profileHowItWorksBody => 'शेअरची हालचाल, तीन पायऱ्यांत';

  @override
  String get profileResetJournal => 'जर्नल रीसेट करा';

  @override
  String get profileFooter => 'Shoku · संध्याकाळचे स्वयंपाकघर';

  @override
  String get helpTitle => 'मदत आणि अभिप्राय';

  @override
  String get helpSubtitle => 'लोक सर्वात आधी जे विचारतात त्याला छोटी उत्तरे.';

  @override
  String get helpStillStuck => 'तरीही अडकले आहे';

  @override
  String get helpStillStuckBody =>
      'रीलची लिंक आणि तुम्हाला काय अपेक्षित होते ते पाठवा. त्याने दुरुस्ती खूप जलद होते.';

  @override
  String get nutritionTitle => 'पोषण';

  @override
  String get nutritionComingSoon => 'लवकरच येत आहे';

  @override
  String get nutritionHeadline => 'तुमचा स्वयंपाक कसा बदलतो याची एक नजर.';

  @override
  String get nutritionBody =>
      'तुमचे जर्नल याशिवाय चालते. जेव्हा हे येईल, तेव्हा इथे शिजवलेली जेवणंच वाचेल.';

  @override
  String get nutritionBackToYou => 'तुम्ही वर परत';

  @override
  String get exitTitle => 'Shoku सोडायचे?';

  @override
  String get exitBody => 'तुमचे जर्नल जतन आहे. काहीही हरवत नाही.';

  @override
  String get exitKeepCooking => 'शिजवत राहा';

  @override
  String get exitExit => 'बाहेर';

  @override
  String get orbAssistant => 'सहाय्यक';

  @override
  String get orbAskAboutStep => 'या पायरीबद्दल विचारा';

  @override
  String timerStart(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString मिनिटांचा टाइमर सुरू करा';
  }

  @override
  String get timerTimesUp => 'वेळ संपली';

  @override
  String get timerPaused => 'थांबलेला';

  @override
  String get timerRunning => 'चालू';

  @override
  String timerOnStep(int step, String state) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'पायरी $stepString · $state';
  }

  @override
  String get timerStartAgain => 'पुन्हा सुरू करा';

  @override
  String get timerResume => 'पुढे चालू करा';

  @override
  String get timerPause => 'थांबवा';

  @override
  String get timerStop => 'बंद करा';

  @override
  String get timerAlertsOff => 'सूचना बंद आहेत — Shoku साठी सूचना सुरू करा';

  @override
  String get timerAlertsLate =>
      'सूचना उशिरा येऊ शकतात — सेटिंग्जमध्ये अचूक अलार्म द्या';

  @override
  String get cookLeaveTitle => 'हे शिजवणे सोडायचे?';

  @override
  String get cookLeaveBody =>
      'तुम्ही अर्ध्या वाटेवर आहात. अजून काहीही जतन झालेले नाही.';

  @override
  String cookLeaveChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'या शिजवण्यातील $count बदल टाकून दिले जातील.',
      one: 'या शिजवण्यातील 1 बदल टाकून दिला जाईल.',
    );
    return '$_temp0';
  }

  @override
  String cookChangedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बदलले',
      one: '1 बदलले',
    );
    return '$_temp0';
  }

  @override
  String cookStepLabel(String step) {
    return 'पायरी $step';
  }

  @override
  String get cookTimerCleared => 'टाइमर हटवला — या पदार्थाची नवी आवृत्ती आहे';

  @override
  String get cookBack => 'मागे';

  @override
  String get cookFinishLog => 'पूर्ण करा आणि नोंदवा';

  @override
  String get cookNextStep => 'पुढची पायरी';

  @override
  String get cookNoSteps => 'रेसिपीचे पालन करा.';

  @override
  String get micHint => 'लिहा किंवा माइक दाबून ठेवा';

  @override
  String get micListening => 'ऐकत आहोत…';

  @override
  String get searchHint => 'रेसिपी, टिपा, हँडल शोधा';

  @override
  String hudStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिवस',
      one: '1 दिवस',
    );
    return '$_temp0';
  }

  @override
  String hudLevel(String level) {
    return 'स्तर $level';
  }

  @override
  String get botServerNotice => 'सहाय्यकाला अडचण आली — पुन्हा प्रयत्न करा.';

  @override
  String get botSignInNotice => 'सहाय्यकाला विचारण्यासाठी साइन इन करा.';

  @override
  String get dishStopReading => 'वाचन थांबवा';

  @override
  String get cookbookEmptySignedOut =>
      'तुमच्या रेसिपी परत मिळवण्यासाठी साइन इन करा. त्या सर्व्हरवर आहेत, या फोनवर नाहीत.';

  @override
  String get cookbookEmptyOffline =>
      'तुमच्या रेसिपी लोड होऊ शकल्या नाहीत. कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';
}
