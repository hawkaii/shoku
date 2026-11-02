// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get languageTitle => 'ভাষা';

  @override
  String get languageSubtitle =>
      'শোকু আপনার ভাষায়। আপনি পরে \"আপনি\" অংশে এটি বদলাতে পারেন।';

  @override
  String get languageSystem => 'সিস্টেম ভাষা';

  @override
  String get languageSystemHint => 'ফোনের ভাষা অনুসরণ করে';

  @override
  String get languageTapToContinue => 'চালিয়ে যেতে একটি ভাষা বেছে নিন';

  @override
  String get onboardingSkip => 'এড়িয়ে যান';

  @override
  String get onboardingStartCooking => 'রান্না শুরু করুন';

  @override
  String get onboardingShareCta => 'চেষ্টা করতে একটি রিল শেয়ার করুন';

  @override
  String get onboardingContinue => 'চালিয়ে যান';

  @override
  String get onboardingOpenJournal => 'আমার জার্নাল খুলুন';

  @override
  String get onboardingIntroTitle => 'একবার রান্না করুন।\nএটিকে আপনার করুন।';

  @override
  String get onboardingIntroBody =>
      'প্রতিবার রান্না করলে আপনি কিছু বদলান। শোকু সেই বদল মনে রাখে, যাতে পরের বার আপনি আজ রাতের জন্য মানানসই সংস্করণ বেছে নিতে পারেন।';

  @override
  String get onboardingShareStepLabel => '01 · রিল শেয়ার করুন';

  @override
  String get onboardingShareTitle =>
      'এক ট্যাপ, আপনি যে অ্যাপে আছেন সেখান থেকেই।';

  @override
  String get onboardingShareTo => 'এখানে শেয়ার করুন';

  @override
  String get onboardingSaved => 'v1 হিসেবে সংরক্ষিত · 4 সেকেন্ডে বের করা';

  @override
  String get onboardingJournalStepLabel => '02 · রান্না করুন, বদলান';

  @override
  String get onboardingJournalTitle => 'আপনার জার্নাল বদলগুলো মনে রাখে।';

  @override
  String get onboardingJournalBody =>
      'কুক মোড আপনাকে পথ দেখায়। কিছু বদলালে বলুন। শেষে আপনি একটি সংস্করণ পান — ছবি, রেটিং এবং কী বদলেছে তা সহ।';

  @override
  String get onboardingAltered => 'বদলানো';

  @override
  String get onboardingTap => 'ট্যাপ করুন';

  @override
  String get authSheetTitle => 'আপনার জার্নাল রাখুন';

  @override
  String get authSheetBody =>
      'সাইন ইন না করা পর্যন্ত রান্না এই ফোনেই থাকে। সাইন ইন করলে তা আপনার সব ডিভাইসে চলে যায়।';

  @override
  String get authEmail => 'ইমেল';

  @override
  String get authPassword => 'পাসওয়ার্ড';

  @override
  String get authWorking => 'চলছে…';

  @override
  String get authCreateAccount => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get authSignIn => 'সাইন ইন করুন';

  @override
  String get authHaveAccount => 'আমার অ্যাকাউন্ট আছে';

  @override
  String get authCreateAccountLink => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get authErrorEmailPassword => 'ইমেল এবং ৬+ অক্ষরের পাসওয়ার্ড';

  @override
  String get authErrorConfirmEmail =>
      'নিশ্চিত করতে আপনার ইমেল দেখুন, তারপর সাইন ইন করুন';

  @override
  String get authErrorMismatch => 'ওই ইমেল ও পাসওয়ার্ড মেলে না';

  @override
  String get authErrorUnconfirmed =>
      'ওই অ্যাকাউন্ট এখনও নিশ্চিত নয় — আপনার ইমেল দেখুন';

  @override
  String get authErrorExists => 'ওই ইমেলে আগেই অ্যাকাউন্ট আছে — সাইন ইন করুন';

  @override
  String get authErrorNoConnection => 'কোনো সংযোগ নেই';

  @override
  String get authErrorGeneric => 'সাইন ইন করা যায়নি';

  @override
  String get authNotSignedIn => 'সাইন ইন নেই';

  @override
  String get authSignedIn => 'সাইন ইন আছেন';

  @override
  String get authLocalOnly => 'রান্না শুধু এই ফোনেই থাকে।';

  @override
  String get authSignOut => 'সাইন আউট';

  @override
  String get tabJournal => 'জার্নাল';

  @override
  String get tabCookbook => 'রান্নার বই';

  @override
  String get tabFridge => 'ফ্রিজ';

  @override
  String get tabWall => 'ওয়াল';

  @override
  String get tabYou => 'আপনি';

  @override
  String journalKitchenTitle(String month) {
    return '$month রান্নাঘর';
  }

  @override
  String journalDishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পদ',
      one: '$countটি পদ',
      zero: 'এখনও কোনো পদ নেই',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি উন্নতি',
      one: '$countটি উন্নতি',
      zero: 'কোনো উন্নতি নেই',
    );
    return '$_temp0';
  }

  @override
  String journalCooksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'বার রান্না',
      one: 'বার রান্না',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'উন্নতি',
      one: 'উন্নতি',
    );
    return '$_temp0';
  }

  @override
  String journalEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি এন্ট্রি',
      one: '$countটি এন্ট্রি',
      zero: 'কোনো এন্ট্রি নেই',
    );
    return '$_temp0';
  }

  @override
  String get journalOnTheCounter => 'কাউন্টারে';

  @override
  String get journalCookLog => 'রান্নার লগ';

  @override
  String get journalCook => 'রান্না করুন';

  @override
  String get journalFirstPage => 'আপনার প্রথম পাতা';

  @override
  String get journalFirstPageBody =>
      'একবার রান্না করুন — একটি ছবি, কেমন হলো, এবং একটি জিনিস যা আপনি বদলেছেন। সেটিই v1 হয়।';

  @override
  String get journalStartJournal => 'জার্নাল শুরু করুন →';

  @override
  String get journalNoDishes =>
      'এখনও কোনো পদ নেই — শুরু করতে একটি রিল ইমপোর্ট করুন';

  @override
  String get journalOpening => 'আপনার জার্নাল খোলা হচ্ছে';

  @override
  String get journalErrorTitle => 'আপনার জার্নাল খোলা যায়নি';

  @override
  String get journalErrorBody => 'সংরক্ষিত রান্নাগুলো এখনও এই ফোনে আছে।';

  @override
  String get journalTryAgain => 'আবার চেষ্টা করুন';

  @override
  String get journalSaveRecipe => 'একটি রেসিপি সংরক্ষণ করুন';

  @override
  String get cookbookTitle => 'রান্নার বই';

  @override
  String cookbookCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রান্না',
      one: '$countটি রান্না',
      zero: 'কিছু রান্না হয়নি',
    );
    return '$_temp0';
  }

  @override
  String get cookbookToCook => 'রান্না করতে হবে';

  @override
  String get cookbookCooked => 'রান্না হয়েছে';

  @override
  String get cookbookNothingToCook => 'রান্না করার জন্য কিছু অপেক্ষা করছে না।';

  @override
  String get cookbookNoCooksYet =>
      'এখনও কোনো রান্না নেই। রান্না করতে হবে থেকে কিছু বেছে নিন।';

  @override
  String get cookbookNeverCooked => 'কখনও রান্না হয়নি';

  @override
  String cookbookLastCooked(String outcome) {
    return 'শেষবার: $outcome';
  }

  @override
  String get badgeToCook => 'রান্না করতে হবে';

  @override
  String get badgeCooked => 'রান্না হয়েছে';

  @override
  String badgeCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'রান্না $count×',
      one: 'রান্না $count×',
    );
    return '$_temp0';
  }

  @override
  String get badgeSignature => 'সিগনেচার';

  @override
  String get outcomeNailedIt => 'একদম ঠিক';

  @override
  String get outcomeGood => 'ভালো';

  @override
  String get outcomeNeedsWork => 'উন্নতি দরকার';

  @override
  String get moodQuick => 'দ্রুত';

  @override
  String get moodProject => 'প্রজেক্ট';

  @override
  String get moodComfort => 'আরামদায়ক';

  @override
  String minutesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count মিনিট',
      one: '$count মিনিট',
    );
    return '$_temp0';
  }

  @override
  String get labelSample => 'নমুনা';

  @override
  String get addSheetTitle => 'একটি রেসিপি ইমপোর্ট করুন';

  @override
  String get addSheetSubtitle =>
      'একটি রিল একটি পদ হয়ে যায় যা আপনি রান্না ও ভার্সন করতে পারেন।';

  @override
  String get addSheetLinkHint => 'Instagram বা YouTube লিংক পেস্ট করুন';

  @override
  String get addSheetShareOption => 'অন্য অ্যাপ থেকে শেয়ার করুন';

  @override
  String get addSheetShareHint => 'Instagram → শেয়ার → Shoku';

  @override
  String get addSheetScanOption => 'বারকোড স্ক্যান করুন';

  @override
  String get addSheetScanHint => 'সরাসরি আপনার ফ্রিজে যোগ করুন';

  @override
  String get addSheetBackendNote =>
      'এক্সট্র্যাকশন সার্ভারে চলে — এই বিল্ড শুধু ইন্টারফেস।';

  @override
  String get importHeadline => 'রিল ইমপোর্ট হচ্ছে';

  @override
  String get importQueued => 'সারিতে';

  @override
  String get importWaking => 'রান্নাঘর জাগছে…';

  @override
  String get importWaitingHint => 'বিরতির পর প্রথমটিতে এক মিনিট লাগে';

  @override
  String get importReadingReel => 'রিল পড়া হচ্ছে';

  @override
  String get importReadingAudio => 'অডিও পড়া হচ্ছে';

  @override
  String get importWritingRecipe => 'রেসিপি লেখা হচ্ছে';

  @override
  String get importWatchingVideo => 'ভিডিও দেখা হচ্ছে';

  @override
  String get importReadingCaption => 'ক্যাপশন পড়া হচ্ছে';

  @override
  String get importReady => 'প্রস্তুত';

  @override
  String get importFailedShort => 'এটি পড়া যায়নি';

  @override
  String get reasonUnsupportedUrl =>
      'ওই লিংক এমন রিল বা ভিডিও নয় যা আমরা পড়তে পারি';

  @override
  String get reasonSourceBlocked =>
      'YouTube এখন আমাদের সার্ভার আটকাচ্ছে — পরে চেষ্টা করুন বা রেসিপি পেস্ট করুন';

  @override
  String get reasonTimeout => 'এতে অনেক সময় লাগল — আবার চেষ্টা করুন';

  @override
  String get reasonWorkerUnavailable =>
      'রান্নাঘর জাগেনি — এক মিনিটে আবার চেষ্টা করুন';

  @override
  String get reasonTimedOut =>
      'এখনও পড়ছি — এতে কয়েক মিনিট লাগতে পারে। আপনি চলে যেতে পারেন, প্রস্তুত হলে পদটি এখানে থাকবে';

  @override
  String get reasonGone =>
      'ওই ইমপোর্ট আর সার্ভারে নেই — লিংকটি আবার চেষ্টা করুন';

  @override
  String get reasonInvalidRecipe => 'ওটিতে আমরা কোনো রেসিপি পাইনি';

  @override
  String get reasonNoAudio => 'ওই ভিডিওতে শোনার মতো কিছু নেই';

  @override
  String get reasonNoText =>
      'ওই রিলে ক্যাপশন নেই বা আমরা পড়তে পারি এমন কথা নেই';

  @override
  String get reasonNoRecipe => 'ওই ভিডিও কোনো রেসিপি দেখায় না';

  @override
  String get reasonVisionFailed =>
      'আমরা ওই ভিডিও পড়তে পারিনি — রেসিপি পেস্ট করুন';

  @override
  String get reasonTakenDown => 'ওই রেসিপি সরিয়ে ফেলা হয়েছিল';

  @override
  String get reasonUnknown => 'এটি পড়া যায়নি — রেসিপি পেস্ট করুন';

  @override
  String get pantryTitle => 'ফ্রিজ';

  @override
  String pantryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি জিনিস',
      one: '$countটি জিনিস',
      zero: 'কোনো জিনিস নেই',
    );
    return '$_temp0';
  }

  @override
  String pantrySearchHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি জিনিস খুঁজুন',
      one: '$countটি জিনিস খুঁজুন',
      zero: 'আপনার ফ্রিজে খুঁজুন',
    );
    return '$_temp0';
  }

  @override
  String pantrySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি নির্বাচিত',
      one: '$countটি নির্বাচিত',
      zero: 'কিছু নির্বাচিত নয়',
    );
    return '$_temp0';
  }

  @override
  String get pantryEdit => 'সম্পাদনা';

  @override
  String get pantryShelfLabel => 'আপনার ফ্রিজ থেকে রান্না করুন';

  @override
  String get pantryToBuy => 'কিনতে হবে';

  @override
  String get pantryInFridge => 'ফ্রিজে';

  @override
  String get pantryEmpty =>
      'ফ্রিজে এখনও কিছু নেই। রসিদের ছবি তুলুন, বা এতে কী আছে বলুন।';

  @override
  String get pantryAddItems => 'জিনিস যোগ করুন';

  @override
  String get pantryHowMuch => 'কত?';

  @override
  String get pantryAmountExample => '2 kg';

  @override
  String get pantryCancel => 'বাতিল';

  @override
  String get pantryDone => 'হয়ে গেছে';

  @override
  String get pantryDelete => 'মুছুন';

  @override
  String get pantrySelectItems => 'জিনিস বাছুন';

  @override
  String pantryDeleteCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countStringটি মুছুন',
      one: '$countStringটি মুছুন',
    );
    return '$_temp0';
  }

  @override
  String pantryDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি জিনিস মুছে ফেলা হয়েছে',
      one: '$countটি জিনিস মুছে ফেলা হয়েছে',
    );
    return '$_temp0';
  }

  @override
  String get pantrySetAmount => 'পরিমাণ ঠিক করুন';

  @override
  String pantryLessItem(String name) {
    return '$name কম';
  }

  @override
  String pantryMoreItem(String name) {
    return '$name বেশি';
  }

  @override
  String get shelfEmpty =>
      'এখনও কোনো পরামর্শ নেই — কিছু জিনিস যোগ করুন, আমি ওয়াল ও আপনার পদ মিলাব।';

  @override
  String shelfBuyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$countটি কিনতে হবে',
      one: '+$countটি কিনতে হবে',
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

    return '$totalString-এর মধ্যে $haveString';
  }

  @override
  String get pantryEditTitle => 'জিনিস সম্পাদনা';

  @override
  String get pantryNameLabel => 'নাম';

  @override
  String get pantryAmountLabel => 'পরিমাণ';

  @override
  String get pantryAmountHelp =>
      'জানেন জিনিস আছে কিন্তু কত তা জানেন না, তবে খালি রাখুন।';

  @override
  String pantrySavedAs(String amount) {
    return '$amount হিসেবে সংরক্ষিত';
  }

  @override
  String get pantrySave => 'সংরক্ষণ';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitTbsp => 'টেবিল চামচ';

  @override
  String get unitTsp => 'চা চামচ';

  @override
  String get unitPcs => 'পিস';

  @override
  String get unitBunch => 'আঁটি';

  @override
  String get unitPack => 'প্যাক';

  @override
  String get pantryAddTitle => 'ফ্রিজে যোগ করুন';

  @override
  String get pantryAddIntro =>
      'রসিদের ছবি তুলুন, রান্নাঘরে কী আছে বলুন, বা লিখুন। আপনি তালিকা না দেখা পর্যন্ত কিছুই ফ্রিজে ঢোকে না।';

  @override
  String get pantryDoorPhoto => 'ছবি';

  @override
  String get pantryDoorVoice => 'কণ্ঠ';

  @override
  String get pantryDoorType => 'লিখুন';

  @override
  String get pantryReview => 'পর্যালোচনা';

  @override
  String get pantryToAdd => 'যোগ করতে হবে';

  @override
  String get pantryAiReading => 'বাকিটা পড়া হচ্ছে…';

  @override
  String get pantryAmountUnknown => 'পরিমাণ অজানা';

  @override
  String pantryCouldNotRead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'পড়া যায়নি ($count)',
      one: 'পড়া যায়নি ($count)',
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
      other: '$totalString-এর মধ্যে $checkedString যোগ করুন',
      one: '$totalString-এর মধ্যে $checkedString যোগ করুন',
    );
    return '$_temp0';
  }

  @override
  String get pantryNoteOffline => 'রসিদ পড়তে সংযোগ দরকার। লিখুন বা বলুন।';

  @override
  String get pantryNoteUnreadable => 'ওই ছবিতে পড়ার মতো কিছু ছিল না — লিখুন।';

  @override
  String get pantryCapReached => 'আজকের AI পড়া শেষ — লিখুন।';

  @override
  String get pantryPhotoButton => 'ছবি বা স্ক্রিনশট';

  @override
  String get pantryPhotoHint =>
      'রসিদের ছবি তুলুন, পাঠক তা লিখে দেবে। আপনি তালিকা না দেখা পর্যন্ত কিছুই ফ্রিজে ঢোকে না।';

  @override
  String get pantryReadingReceipt => 'রসিদ পড়া হচ্ছে…';

  @override
  String get pantryBackTooltip => 'ফ্রিজে ফিরুন';

  @override
  String get pantryTypeHint => '2 kg চাল, প্রতি লাইনে একটি';

  @override
  String get pantryVoiceHint => 'মাইক চেপে ধরে বলুন রান্নাঘরে কী আছে';

  @override
  String get pantryWhatIsIt => 'এটি কী?';

  @override
  String get pantryVisionTitle => 'পাঠক Meta-র মডেল ব্যবহার করে';

  @override
  String get pantryVisionBody =>
      'ছবিটি পড়ার জন্য Meta-র মডেলে পাঠানো হয়। এটি শুধু ওই এক কলের জন্য ব্যবহৃত হয় এবং সংরক্ষণ করা হয় না। লাইনগুলো নিচের পর্যালোচনায় আসে, যেখানে ফ্রিজে ঢোকার আগে আপনি যা চান ঠিক করতে পারেন।';

  @override
  String get pantryGotIt => 'বুঝেছি';

  @override
  String get pantryScreenshotOrPhoto => 'স্ক্রিনশট বা ছবি';

  @override
  String get pantryCamera => 'ক্যামেরা';

  @override
  String pantryInFridgeSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ফ্রিজে $countটি জিনিস',
      one: 'ফ্রিজে $countটি জিনিস',
    );
    return '$_temp0';
  }

  @override
  String get botNoDish => 'পদ ছাড়া';

  @override
  String get botDishFallback => 'পদ';

  @override
  String botCookingStep(int step, int total) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'রান্না · ধাপ $stepString / $totalString';
  }

  @override
  String get botTalkAbout => 'এটি নিয়ে কথা…';

  @override
  String get botThisDish => 'এই পদ';

  @override
  String get botNoDishKitchen => 'পদ ছাড়া — রান্নাঘর';

  @override
  String get botOpen => 'খুলুন';

  @override
  String get botMinimise => 'ছোট করুন';

  @override
  String get botNewChat => 'নতুন চ্যাট';

  @override
  String get botThinking => 'ভাবছে';

  @override
  String get botOfflineLine =>
      'সহায়কের সংযোগ দরকার। অফলাইনে কিছু উত্তর হয় না।';

  @override
  String get botAskKitchen => 'রান্নাঘর নিয়ে জিজ্ঞাসা করুন…';

  @override
  String botAskDish(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'এই পদ নিয়ে জিজ্ঞাসা করুন · v$versionString';
  }

  @override
  String get botOutOfQuestions => 'আজকের প্রশ্ন শেষ';

  @override
  String get botNoConnection => 'কোনো সংযোগ নেই';

  @override
  String get botCapNotice => 'আপনি আজকের প্রশ্ন ব্যবহার করেছেন। কাল আবার আসবে।';

  @override
  String get botOfflineNotice =>
      'সহায়কের সংযোগ দরকার। এখানে অফলাইনে কিছু উত্তর হয় না।';

  @override
  String botWhichDish(String choices) {
    return 'কোন পদটি বলেছেন? $choices';
  }

  @override
  String botAddedToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ফ্রিজে $countটি জিনিস।',
      one: 'ফ্রিজে $countটি জিনিস।',
    );
    return '$_temp0';
  }

  @override
  String get botDestructiveRefusal =>
      'আমি এখান থেকে আপনার জার্নাল বদলাতে পারি না। পদটি (বা তার ⋯ মেনু) খুলুন, আসল প্রবাহ তা করবে।';

  @override
  String botAddMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি অনুপস্থিত যোগ করুন',
      one: '$countটি অনুপস্থিত যোগ করুন',
    );
    return '$_temp0';
  }

  @override
  String botAddedToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি জিনিস আপনার তালিকায় যোগ হয়েছে',
      one: '$countটি জিনিস আপনার তালিকায় যোগ হয়েছে',
    );
    return '$_temp0';
  }

  @override
  String get botNotThis => 'এটি নয়';

  @override
  String get botAddToFridgeQuestion => 'ফ্রিজে যোগ করবেন?';

  @override
  String botAddCountToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ফ্রিজে $countটি জিনিস যোগ করুন',
      one: 'ফ্রিজে $countটি জিনিস যোগ করুন',
    );
    return '$_temp0';
  }

  @override
  String get botAmountUnknown => 'পরিমাণ?';

  @override
  String botSuggestionMeta(String source, int have, int total) {
    final intl.NumberFormat haveNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String haveString = haveNumberFormat.format(have);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$source · $totalString-এর মধ্যে $haveString';
  }

  @override
  String get botStarterFridge => 'আপনার ফ্রিজে কী আছে?';

  @override
  String get botStarterWall => 'আমাকে ওয়াল থেকে কিছু দেখান';

  @override
  String get botStarterPhoto => 'আমার কাছে একটি পদের ছবি আছে';

  @override
  String botStarterDinner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আপনার ফ্রিজে $countটি জিনিস আছে। সেগুলো দিয়ে রাতের খাবার?',
      one: 'আপনার ফ্রিজে $countটি জিনিস আছে। সেগুলো দিয়ে রাতের খাবার?',
    );
    return '$_temp0';
  }

  @override
  String chatEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আগেরগুলো দেখান ($count)',
      one: 'আগেরটি দেখান ($count)',
    );
    return '$_temp0';
  }

  @override
  String chatAboutStep(int step) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'ধাপ $stepString নিয়ে';
  }

  @override
  String get chatAskHint => 'জিজ্ঞাসা করুন, বা মাইক চেপে ধরুন';

  @override
  String get chatResolveChange => 'উপরের পরিবর্তনটি সমাধান করুন';

  @override
  String get chatAsk => 'জিজ্ঞাসা';

  @override
  String chatVersionDivider(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString এখান থেকে শুরু';
  }

  @override
  String chatApplied(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'V$versionString · প্রয়োগ হয়েছে';
  }

  @override
  String chatOpenVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString খুলুন';
  }

  @override
  String get chatUndo => 'ফিরিয়ে নিন';

  @override
  String get chatRecipeChange => 'রেসিপি পরিবর্তন';

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
      other: '+$count আরও',
      one: '+$count আরও',
    );
    return '$_temp0';
  }

  @override
  String chatCreatesVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString তৈরি করে — এই বার্তা থেকে';
  }

  @override
  String get chatRecompute => 'আবার হিসাব করুন';

  @override
  String get chatDiscard => 'বাদ দিন';

  @override
  String get chatNotApplied => 'প্রয়োগ হয়নি';

  @override
  String get chatNothingChanged => 'আপনার রেসিপিতে কিছু বদলায়নি।';

  @override
  String get chatTryAgain => 'আবার চেষ্টা করুন';

  @override
  String get chatApplying => 'প্রয়োগ হচ্ছে…';

  @override
  String chatApplyAs(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString হিসেবে প্রয়োগ করুন';
  }

  @override
  String get importPasteFirst => 'আগে একটি লিংক পেস্ট করুন';

  @override
  String get importNoLink => 'রিল প্রস্তুত কিন্তু সার্ভার কোনো লিংক পাঠায়নি';

  @override
  String get importCouldNotStart => 'ওই ইমপোর্ট শুরু করা যায়নি';

  @override
  String get importSignIn => 'ইমপোর্ট করতে আপনি থেকে সাইন ইন করুন';

  @override
  String get importUnreachable => 'সার্ভারে পৌঁছানো যায়নি';

  @override
  String get importLostConnection =>
      'সংযোগ চলে গেছে — রিল এখনও পড়া হচ্ছে। আবার খুলে চালিয়ে যান';

  @override
  String get importStillOnServer =>
      'সার্ভারে পৌঁছানো যায়নি — রিল এখনও সেখানে। আবার খুলে চালিয়ে যান';

  @override
  String get importGone => 'ওই রিল আর সার্ভারে নেই — লিংকটি আবার চেষ্টা করুন';

  @override
  String importSaved(String title) {
    return '$title সংরক্ষিত';
  }

  @override
  String get importNothingToSave => 'সংরক্ষণ করার কিছু নেই';

  @override
  String get importCouldNotSave =>
      'রেসিপি ফিরে এসেছে কিন্তু সংরক্ষণ করা যায়নি — আবার খুলুন';

  @override
  String get importOpenAgain =>
      'সার্ভারে পৌঁছানো যায়নি — এক মিনিটে আবার খুলুন';

  @override
  String get importSheetTitle => 'রিল সংরক্ষণ করুন';

  @override
  String get importSheetBody =>
      'YouTube বা Instagram লিংক পেস্ট করুন। এটি একটি পদ হয়ে যায় যা আপনি রান্না করতে পারেন, নির্মাতাসহ।';

  @override
  String get importStillWorking => 'এখনও কাজ চলছে — এই রিলটি লম্বা';

  @override
  String get importLongWait =>
      'লম্বা রিলে কয়েক মিনিট লাগে। আপনি চলে যেতে পারেন; প্রস্তুত হলে পদটি আসবে।';

  @override
  String get importCloseWait =>
      'আপনি এটি বন্ধ করতে পারেন; প্রস্তুত হলে পদটি আসবে।';

  @override
  String get importReading => 'পড়া হচ্ছে…';

  @override
  String get importReadLink => 'এই লিংকটি পড়ুন';

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
