// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get languageTitle => 'Bahasa';

  @override
  String get languageSubtitle =>
      'Shoku dalam bahasamu. Kamu bisa mengubahnya nanti di Kamu.';

  @override
  String get languageSystem => 'Bahasa sistem';

  @override
  String get languageSystemHint => 'Mengikuti bahasa ponsel ini';

  @override
  String get languageTapToContinue => 'Ketuk bahasa untuk melanjutkan';

  @override
  String get onboardingSkip => 'Lewati';

  @override
  String get onboardingStartCooking => 'Mulai memasak';

  @override
  String get onboardingShareCta => 'Bagikan reel untuk mencoba';

  @override
  String get onboardingContinue => 'Lanjutkan';

  @override
  String get onboardingOpenJournal => 'Buka jurnal saya';

  @override
  String get onboardingIntroTitle => 'Masak sekali.\nJadikan milikmu.';

  @override
  String get onboardingIntroBody =>
      'Setiap kali memasak, kamu mengubah sesuatu. Shoku mengingat perubahan itu, jadi lain kali kamu bisa memilih versi yang cocok malam ini.';

  @override
  String get onboardingShareStepLabel => '01 · BAGIKAN REEL';

  @override
  String get onboardingShareTitle =>
      'Satu ketuk, dari app yang sedang kamu buka.';

  @override
  String get onboardingShareTo => 'Bagikan ke';

  @override
  String get onboardingSaved => 'Disimpan sebagai v1 · diekstrak dalam 4 detik';

  @override
  String get onboardingJournalStepLabel => '02 · MASAK, UBAH';

  @override
  String get onboardingJournalTitle => 'Jurnalmu mengingat perubahannya.';

  @override
  String get onboardingJournalBody =>
      'Mode masak menuntunmu. Saat mengganti sesuatu, katakan. Di akhir kamu dapat satu versi — dengan foto, penilaian, dan apa yang berubah.';

  @override
  String get onboardingAltered => 'diubah';

  @override
  String get onboardingTap => 'KETUK';

  @override
  String get authSheetTitle => 'Simpan jurnalmu';

  @override
  String get authSheetBody =>
      'Masakan tetap di ponsel ini sampai kamu masuk. Masuk menaruhnya di semua perangkatmu.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Kata sandi';

  @override
  String get authWorking => 'Memproses…';

  @override
  String get authCreateAccount => 'Buat akun';

  @override
  String get authSignIn => 'Masuk';

  @override
  String get authHaveAccount => 'Saya sudah punya akun';

  @override
  String get authCreateAccountLink => 'Buat sebuah akun';

  @override
  String get authErrorEmailPassword => 'Email dan kata sandi 6+ karakter';

  @override
  String get authErrorConfirmEmail =>
      'Periksa emailmu untuk konfirmasi, lalu masuk';

  @override
  String get authErrorMismatch => 'Email dan kata sandi itu tidak cocok';

  @override
  String get authErrorUnconfirmed =>
      'Akun itu belum dikonfirmasi — periksa emailmu';

  @override
  String get authErrorExists => 'Email itu sudah punya akun — masuk saja';

  @override
  String get authErrorNoConnection => 'Tidak ada koneksi';

  @override
  String get authErrorGeneric => 'Tidak bisa masuk';

  @override
  String get authNotSignedIn => 'Belum masuk';

  @override
  String get authSignedIn => 'Sudah masuk';

  @override
  String get authLocalOnly => 'Masakan hanya ada di ponsel ini.';

  @override
  String get authSignOut => 'Keluar';

  @override
  String get tabJournal => 'Jurnal';

  @override
  String get tabCookbook => 'Buku Resep';

  @override
  String get tabFridge => 'Kulkas';

  @override
  String get tabWall => 'Dinding';

  @override
  String get tabYou => 'Kamu';

  @override
  String journalKitchenTitle(String month) {
    return 'Dapur $month';
  }

  @override
  String journalDishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hidangan',
      one: '1 hidangan',
      zero: 'Belum ada hidangan',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peningkatan',
      one: '1 peningkatan',
      zero: 'tanpa peningkatan',
    );
    return '$_temp0';
  }

  @override
  String journalCooksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'kali masak',
    );
    return '$_temp0';
  }

  @override
  String journalUpgradesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'peningkatan',
    );
    return '$_temp0';
  }

  @override
  String journalEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entri',
      one: '1 entri',
      zero: 'tanpa entri',
    );
    return '$_temp0';
  }

  @override
  String get journalOnTheCounter => 'di meja dapur';

  @override
  String get journalCookLog => 'catatan masak';

  @override
  String get journalCook => 'Masak';

  @override
  String get journalFirstPage => 'Halaman pertama kamu';

  @override
  String get journalFirstPageBody =>
      'Catat satu masakan — foto, hasilnya, dan satu hal yang kamu ubah. Itu menjadi v1.';

  @override
  String get journalStartJournal => 'Mulai jurnal →';

  @override
  String get journalNoDishes => 'Belum ada hidangan — impor reel untuk mulai';

  @override
  String get journalOpening => 'Membuka jurnalmu';

  @override
  String get journalErrorTitle => 'Jurnalmu tidak bisa dibuka';

  @override
  String get journalErrorBody => 'Masakan yang tersimpan masih di ponsel ini.';

  @override
  String get journalTryAgain => 'Coba lagi';

  @override
  String get journalSaveRecipe => 'Simpan resep';

  @override
  String get cookbookTitle => 'Buku Resep';

  @override
  String cookbookCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dimasak',
      one: '1 dimasak',
      zero: 'belum ada yang dimasak',
    );
    return '$_temp0';
  }

  @override
  String get cookbookToCook => 'Untuk dimasak';

  @override
  String get cookbookCooked => 'Sudah dimasak';

  @override
  String get cookbookNothingToCook => 'Tidak ada yang menunggu untuk dimasak.';

  @override
  String get cookbookNoCooksYet =>
      'Belum ada masakan. Pilih sesuatu dari Untuk dimasak.';

  @override
  String get cookbookNeverCooked => 'belum pernah dimasak';

  @override
  String cookbookLastCooked(String outcome) {
    return 'terakhir $outcome';
  }

  @override
  String get badgeToCook => 'UNTUK DIMASAK';

  @override
  String get badgeCooked => 'SUDAH DIMASAK';

  @override
  String badgeCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'DIMASAK $count×',
    );
    return '$_temp0';
  }

  @override
  String get badgeSignature => 'SIGNATUR';

  @override
  String get outcomeNailedIt => 'Pas sekali';

  @override
  String get outcomeGood => 'Bagus';

  @override
  String get outcomeNeedsWork => 'Perlu diperbaiki';

  @override
  String get moodQuick => 'cepat';

  @override
  String get moodProject => 'proyek';

  @override
  String get moodComfort => 'nyaman';

  @override
  String minutesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count menit',
    );
    return '$_temp0';
  }

  @override
  String get labelSample => 'Contoh';

  @override
  String get addSheetTitle => 'Impor resep';

  @override
  String get addSheetSubtitle =>
      'Satu reel menjadi satu hidangan yang bisa kamu masak dan versikan.';

  @override
  String get addSheetLinkHint => 'Tempel tautan Instagram atau YouTube';

  @override
  String get addSheetShareOption => 'Bagikan dari app lain';

  @override
  String get addSheetShareHint => 'Instagram → bagikan → Shoku';

  @override
  String get addSheetScanOption => 'Pindai barcode';

  @override
  String get addSheetScanHint => 'Tambahkan langsung ke kulkasmu';

  @override
  String get addSheetBackendNote =>
      'Ekstraksi berjalan di server — versi ini hanya antarmukanya.';

  @override
  String get importHeadline => 'Mengimpor reel';

  @override
  String get importQueued => 'Dalam antrean';

  @override
  String get importWaking => 'Membangunkan dapur…';

  @override
  String get importWaitingHint => 'Yang pertama setelah jeda butuh satu menit';

  @override
  String get importReadingReel => 'Membaca reel';

  @override
  String get importReadingAudio => 'Membaca audio';

  @override
  String get importWritingRecipe => 'Menulis resep';

  @override
  String get importWatchingVideo => 'Menonton video';

  @override
  String get importReadingCaption => 'Membaca keterangan';

  @override
  String get importReady => 'Siap';

  @override
  String get importFailedShort => 'Tidak bisa membaca yang ini';

  @override
  String get reasonUnsupportedUrl =>
      'Tautan itu bukan reel atau video yang bisa kami baca';

  @override
  String get reasonSourceBlocked =>
      'YouTube sedang memblokir server kami — coba lagi nanti atau tempel resepnya';

  @override
  String get reasonTimeout => 'Itu terlalu lama — coba lagi';

  @override
  String get reasonWorkerUnavailable =>
      'Dapur tidak bangun — coba lagi dalam satu menit';

  @override
  String get reasonTimedOut =>
      'Masih membaca — ini bisa butuh beberapa menit. Kamu bisa pergi dan hidangannya akan ada di sini saat siap';

  @override
  String get reasonGone =>
      'Impor itu sudah tidak ada di server — coba tautannya lagi';

  @override
  String get reasonInvalidRecipe => 'Kami tidak menemukan resep di video itu';

  @override
  String get reasonNoAudio => 'Video itu tidak punya apa pun untuk didengar';

  @override
  String get reasonNoText =>
      'Reel itu tidak punya keterangan atau ucapan yang bisa kami baca';

  @override
  String get reasonNoRecipe => 'Video itu tidak menunjukkan resep';

  @override
  String get reasonVisionFailed =>
      'Kami tidak bisa membaca video itu — tempel resepnya';

  @override
  String get reasonTakenDown => 'Resep itu telah dihapus';

  @override
  String get reasonUnknown => 'Tidak bisa membaca yang ini — tempel resepnya';

  @override
  String get pantryTitle => 'Kulkas';

  @override
  String pantryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item',
      one: '1 item',
      zero: 'tanpa item',
    );
    return '$_temp0';
  }

  @override
  String pantrySearchHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cari $count item',
      one: 'Cari 1 item',
      zero: 'Cari di kulkasmu',
    );
    return '$_temp0';
  }

  @override
  String pantrySelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dipilih',
      one: '1 dipilih',
      zero: 'tidak ada yang dipilih',
    );
    return '$_temp0';
  }

  @override
  String get pantryEdit => 'Ubah';

  @override
  String get pantryShelfLabel => 'masak dari kulkasmu';

  @override
  String get pantryToBuy => 'untuk dibeli';

  @override
  String get pantryInFridge => 'di kulkas';

  @override
  String get pantryEmpty =>
      'Belum ada apa pun di kulkas. Foto struk, atau bilang saja isinya.';

  @override
  String get pantryAddItems => 'Tambah item';

  @override
  String get pantryHowMuch => 'Berapa banyak?';

  @override
  String get pantryAmountExample => '2 kg';

  @override
  String get pantryCancel => 'Batal';

  @override
  String get pantryDone => 'Selesai';

  @override
  String get pantryDelete => 'Hapus';

  @override
  String get pantrySelectItems => 'Pilih item';

  @override
  String pantryDeleteCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $countString',
      one: 'Hapus 1',
    );
    return '$_temp0';
  }

  @override
  String pantryDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item dihapus',
      one: '1 item dihapus',
    );
    return '$_temp0';
  }

  @override
  String get pantrySetAmount => 'atur jumlah';

  @override
  String pantryLessItem(String name) {
    return 'Kurangi $name';
  }

  @override
  String pantryMoreItem(String name) {
    return 'Tambah $name';
  }

  @override
  String get shelfEmpty =>
      'Belum ada saran — tambahkan beberapa item dan aku akan mencocokkan dinding dan hidanganmu.';

  @override
  String shelfBuyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count untuk dibeli',
      one: '+1 untuk dibeli',
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

    return '$haveString dari $totalString';
  }

  @override
  String get pantryEditTitle => 'Ubah item';

  @override
  String get pantryNameLabel => 'nama';

  @override
  String get pantryAmountLabel => 'jumlah';

  @override
  String get pantryAmountHelp =>
      'Biarkan kosong kalau kamu tahu ada tetapi tidak tahu berapa.';

  @override
  String pantrySavedAs(String amount) {
    return 'Disimpan sebagai $amount';
  }

  @override
  String get pantrySave => 'Simpan';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitTbsp => 'sdm';

  @override
  String get unitTsp => 'sdt';

  @override
  String get unitPcs => 'buah';

  @override
  String get unitBunch => 'ikat';

  @override
  String get unitPack => 'pak';

  @override
  String get pantryAddTitle => 'Tambah ke kulkas';

  @override
  String get pantryAddIntro =>
      'Foto struk, sebutkan isi dapur, atau ketik. Tidak ada yang masuk kulkas sampai kamu melihat daftarnya.';

  @override
  String get pantryDoorPhoto => 'Foto';

  @override
  String get pantryDoorVoice => 'Suara';

  @override
  String get pantryDoorType => 'Ketik';

  @override
  String get pantryReview => 'Tinjau';

  @override
  String get pantryToAdd => 'untuk ditambahkan';

  @override
  String get pantryAiReading => 'Membaca sisanya…';

  @override
  String get pantryAmountUnknown => 'jumlah tidak diketahui';

  @override
  String pantryCouldNotRead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tidak bisa dibaca ($count)',
      one: 'Tidak bisa dibaca (1)',
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
      other: 'Tambahkan $checkedString dari $totalString',
      one: 'Tambahkan $checkedString dari 1',
    );
    return '$_temp0';
  }

  @override
  String get pantryNoteOffline =>
      'Pembaca struk butuh koneksi. Ketik atau ucapkan.';

  @override
  String get pantryNoteUnreadable =>
      'Tidak ada yang terbaca di foto itu — ketik saja.';

  @override
  String get pantryCapReached => 'Bacaan AI hari ini habis — ketik saja.';

  @override
  String get pantryPhotoButton => 'Foto atau tangkapan layar';

  @override
  String get pantryPhotoHint =>
      'Foto struk dan pembaca akan mengetiknya. Tidak ada yang masuk kulkas sampai kamu melihat daftarnya.';

  @override
  String get pantryReadingReceipt => 'Membaca struk…';

  @override
  String get pantryBackTooltip => 'Kembali ke kulkas';

  @override
  String get pantryTypeHint => '2 kg beras, satu per baris';

  @override
  String get pantryVoiceHint => 'Tahan mic dan sebutkan isi dapur';

  @override
  String get pantryWhatIsIt => 'Ini apa?';

  @override
  String get pantryVisionTitle => 'Pembaca memakai model Meta';

  @override
  String get pantryVisionBody =>
      'Foto dikirim ke model Meta untuk dibaca. Hanya dipakai untuk panggilan itu dan tidak disimpan. Barisnya masuk ke tinjauan di bawah, tempat kamu bisa memperbaiki apa pun sebelum masuk kulkas.';

  @override
  String get pantryGotIt => 'Mengerti';

  @override
  String get pantryScreenshotOrPhoto => 'Tangkapan layar atau foto';

  @override
  String get pantryCamera => 'Kamera';

  @override
  String pantryInFridgeSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item di kulkas',
      one: '1 item di kulkas',
    );
    return '$_temp0';
  }

  @override
  String get botNoDish => 'Tanpa hidangan';

  @override
  String get botDishFallback => 'Hidangan';

  @override
  String botCookingStep(int step, int total) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Memasak · langkah $stepString dari $totalString';
  }

  @override
  String get botTalkAbout => 'Bicara tentang…';

  @override
  String get botThisDish => 'Hidangan ini';

  @override
  String get botNoDishKitchen => 'Tanpa hidangan — dapur';

  @override
  String get botOpen => 'Buka';

  @override
  String get botMinimise => 'Kecilkan';

  @override
  String get botNewChat => 'Chat baru';

  @override
  String get botThinking => 'BERPIKIR';

  @override
  String get botOfflineLine =>
      'Asisten butuh koneksi. Tidak ada yang dijawab offline.';

  @override
  String get botAskKitchen => 'Tanya tentang dapur…';

  @override
  String botAskDish(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Tanya tentang hidangan ini · v$versionString';
  }

  @override
  String get botOutOfQuestions => 'Pertanyaan hari ini habis';

  @override
  String get botNoConnection => 'Tidak ada koneksi';

  @override
  String get botCapNotice =>
      'Kamu sudah memakai pertanyaan hari ini. Kembali besok.';

  @override
  String get botOfflineNotice =>
      'Asisten butuh koneksi. Tidak ada yang dijawab offline di sini.';

  @override
  String botWhichDish(String choices) {
    return 'Hidangan mana yang kamu maksud? $choices';
  }

  @override
  String botAddedToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item di kulkas.',
      one: '1 item di kulkas.',
    );
    return '$_temp0';
  }

  @override
  String get botDestructiveRefusal =>
      'Aku tidak bisa mengubah jurnalmu dari sini. Buka hidangannya (atau menu ⋯) dan alur sebenarnya akan melakukannya.';

  @override
  String botAddMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tambahkan $count yang kurang',
      one: 'Tambahkan 1 yang kurang',
    );
    return '$_temp0';
  }

  @override
  String botAddedToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item ditambahkan ke daftarmu',
      one: '1 item ditambahkan ke daftarmu',
    );
    return '$_temp0';
  }

  @override
  String get botNotThis => 'Bukan ini';

  @override
  String get botAddToFridgeQuestion => 'Tambahkan ke kulkas?';

  @override
  String botAddCountToFridge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tambahkan $count item ke kulkas',
      one: 'Tambahkan 1 item ke kulkas',
    );
    return '$_temp0';
  }

  @override
  String get botAmountUnknown => 'jumlah?';

  @override
  String botSuggestionMeta(String source, int have, int total) {
    final intl.NumberFormat haveNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String haveString = haveNumberFormat.format(have);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$source · $haveString dari $totalString';
  }

  @override
  String get botStarterFridge => 'Apa isi kulkasmu?';

  @override
  String get botStarterWall => 'Tunjukkan sesuatu dari Dinding';

  @override
  String get botStarterPhoto => 'Aku punya foto hidangan';

  @override
  String botStarterDinner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kamu punya $count barang di kulkas. Masak dari itu?',
      one: 'Kamu punya 1 barang di kulkas. Masak dari itu?',
    );
    return '$_temp0';
  }

  @override
  String chatEarlier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tampilkan sebelumnya ($count)',
      one: 'Tampilkan sebelumnya (1)',
    );
    return '$_temp0';
  }

  @override
  String chatAboutStep(int step) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'tentang langkah $stepString';
  }

  @override
  String get chatAskHint => 'Tanya, atau tahan mic';

  @override
  String get chatResolveChange => 'Selesaikan perubahan di atas';

  @override
  String get chatAsk => 'Tanya';

  @override
  String chatVersionDivider(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString mulai di sini';
  }

  @override
  String chatApplied(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'V$versionString · DITERAPKAN';
  }

  @override
  String chatOpenVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Buka v$versionString';
  }

  @override
  String get chatUndo => 'Urungkan';

  @override
  String get chatRecipeChange => 'PERUBAHAN RESEP';

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
      other: '+$count lagi',
      one: '+1 lagi',
    );
    return '$_temp0';
  }

  @override
  String chatCreatesVersion(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Membuat v$versionString — dari pesan ini';
  }

  @override
  String get chatRecompute => 'Hitung ulang';

  @override
  String get chatDiscard => 'Buang';

  @override
  String get chatNotApplied => 'TIDAK DITERAPKAN';

  @override
  String get chatNothingChanged => 'Tidak ada yang berubah di resepmu.';

  @override
  String get chatTryAgain => 'Coba lagi';

  @override
  String get chatApplying => 'Menerapkan…';

  @override
  String chatApplyAs(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Terapkan sebagai v$versionString';
  }

  @override
  String get importPasteFirst => 'Tempel tautan dulu';

  @override
  String get importNoLink => 'Reel siap tetapi server tidak mengirim tautan';

  @override
  String get importCouldNotStart => 'Kami tidak bisa memulai impor itu';

  @override
  String get importSignIn => 'Masuk dari Kamu untuk mengimpor';

  @override
  String get importUnreachable => 'Tidak bisa menghubungi server';

  @override
  String get importLostConnection =>
      'Koneksi hilang — reel masih dibaca. Buka ini lagi untuk melanjutkan';

  @override
  String get importStillOnServer =>
      'Tidak bisa menghubungi server — reel masih di sana. Buka ini lagi untuk melanjutkan';

  @override
  String get importGone =>
      'Reel itu tidak ada lagi di server — coba tautannya lagi';

  @override
  String importSaved(String title) {
    return 'Disimpan $title';
  }

  @override
  String get importNothingToSave => 'Tidak ada yang disimpan';

  @override
  String get importCouldNotSave =>
      'Resep kembali tetapi tidak bisa disimpan — buka ini lagi';

  @override
  String get importOpenAgain =>
      'Tidak bisa menghubungi server — buka ini lagi sebentar lagi';

  @override
  String get importSheetTitle => 'Simpan reel';

  @override
  String get importSheetBody =>
      'Tempel tautan YouTube atau Instagram. Itu menjadi hidangan yang bisa kamu masak, dengan kreatornya.';

  @override
  String get importStillWorking => 'Masih bekerja — reel ini panjang';

  @override
  String get importLongWait =>
      'Yang panjang butuh beberapa menit. Kamu bisa pergi; hidangannya muncul saat siap.';

  @override
  String get importCloseWait =>
      'Kamu bisa menutup ini; hidangannya muncul saat siap.';

  @override
  String get importReading => 'Membaca…';

  @override
  String get importReadLink => 'Baca tautan ini';

  @override
  String get dishSampleGate =>
      'Masuk untuk mengimpor reel milikmu dan berbicara dengan resepnya.';

  @override
  String dishCookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kali masak',
    );
    return '$_temp0';
  }

  @override
  String get dishFromVideoNote => 'dibaca dari video — jumlahnya bisa keliru';

  @override
  String dishVersionGone(int from, int to) {
    final intl.NumberFormat fromNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String fromString = fromNumberFormat.format(from);
    final intl.NumberFormat toNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String toString = toNumberFormat.format(to);

    return 'v$fromString sudah tidak ada — menampilkan v$toString';
  }

  @override
  String get dishStartCookMode => 'Mulai mode masak';

  @override
  String get dishReadRecipe => 'Baca resep ini';

  @override
  String get dishMore => 'Lainnya';

  @override
  String get dishMenuCooked => 'Aku baru saja memasak ini';

  @override
  String get dishMarkToCook => 'Tandai untuk dimasak';

  @override
  String get dishSetUpFridge => 'Atur kulkasmu';

  @override
  String dishAddMissingToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tambahkan $count yang kurang ke daftar',
    );
    return '$_temp0';
  }

  @override
  String dishAddedToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ditambahkan ke daftarmu',
    );
    return '$_temp0';
  }

  @override
  String dishIngredientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bahan',
    );
    return '$_temp0';
  }

  @override
  String dishMissingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kurang',
    );
    return '$_temp0';
  }

  @override
  String get dishPickVersion => 'Pilih versi';

  @override
  String dishVersionShowing(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString · ditampilkan';
  }

  @override
  String dishStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count langkah',
    );
    return '$_temp0';
  }

  @override
  String dishAskAboutStep(int step) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'Tanya tentang langkah $stepString';
  }

  @override
  String get dishHistory => 'RIWAYAT';

  @override
  String get dishNotCookedYet =>
      'Belum pernah dimasak. Catatan pertama menjadi v1.';

  @override
  String dishHistoryEntry(int version, String outcome) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'v$versionString · $outcome';
  }

  @override
  String get dishWhatAltered => 'Apa yang diubah';

  @override
  String get dishFromChatEdit => 'dari suntingan chat';

  @override
  String get dishNoNote => 'Tanpa catatan';

  @override
  String get dishUnavailableTitle => 'Hidangan ini tidak ada di sini';

  @override
  String get dishUnavailableBody => 'Mungkin masih dimuat, atau sudah dihapus.';

  @override
  String get dishBackToJournal => 'Kembali ke jurnal';

  @override
  String get dishImported => 'Diimpor';

  @override
  String get dishTheSource => 'sumbernya';

  @override
  String get dishViewReel => 'Lihat reel';

  @override
  String get logTitle => 'Catat masakan malam ini';

  @override
  String get logSnapResult => 'FOTO HASIL MALAM INI';

  @override
  String get logPhotoReady => 'FOTO SIAP DIUNGGAH';

  @override
  String get logHowDidItGo => 'bagaimana hasilnya';

  @override
  String get logNoteLabel => 'catatan untukmu';

  @override
  String get logNoteHint =>
      'Wajannya terlalu panas, jadi aku angkat lebih awal';

  @override
  String get logChangeLabel => 'apa yang kamu ubah';

  @override
  String get logChangeHint =>
      'Lebih banyak jeruk nipis, 2 menit lebih cepat, pakai air fryer';

  @override
  String get logSaveWithPhoto => 'Simpan dengan foto';

  @override
  String get logSaveTonight => 'Simpan malam ini';

  @override
  String logSaveUpgrade(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Simpan & naikkan ke v$versionString';
  }

  @override
  String get logSaveFailed => 'Tidak bisa menyimpan masakan itu';

  @override
  String logSaved(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Dicatat sebagai v$versionString';
  }

  @override
  String logSavedWithOutcome(int version, String outcome) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Dicatat sebagai v$versionString · $outcome';
  }

  @override
  String get debriefTitle => 'Bagaimana hasilnya?';

  @override
  String debriefSubtitle(String title, int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return '$title · menjadi v$versionString';
  }

  @override
  String get debriefAddPhoto => 'TAMBAH FOTO';

  @override
  String get debriefChangePhoto => 'GANTI FOTO';

  @override
  String get debriefRating => 'penilaian';

  @override
  String get debriefMoodLabel => 'masakan seperti apa itu';

  @override
  String get debriefChangesLabel => 'apa yang diubah dari aslinya';

  @override
  String get debriefNoChanges =>
      'Belum ada — tambahkan apa yang kamu buat berbeda.';

  @override
  String get debriefChangeHint => 'mis. 2 sdm madu, bukan 3';

  @override
  String get debriefNoteLabel => 'apa yang kurang';

  @override
  String get debriefNoteHint =>
      '“kurang asam, lain kali tambahkan jeruk nipis”';

  @override
  String get debriefPantryLabel => 'dipakai dari kulkas';

  @override
  String get debriefDeduct => 'Kurangi yang cocok';

  @override
  String debriefSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count baris tidak dikurangi',
    );
    return '$_temp0';
  }

  @override
  String debriefSave(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Simpan sebagai v$versionString';
  }

  @override
  String debriefSaveUpgrade(int version) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Simpan & naikkan ke v$versionString';
  }

  @override
  String get debriefSaveFailed => 'Tidak bisa menyimpan masakan ini';

  @override
  String debriefSaved(int version, String mood) {
    final intl.NumberFormat versionNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String versionString = versionNumberFormat.format(version);

    return 'Disimpan sebagai v$versionString · $mood';
  }

  @override
  String get wallSubtitleEmpty => 'Reel yang diimpor orang';

  @override
  String wallReelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reel',
    );
    return '$_temp0';
  }

  @override
  String get wallMoreBelow => 'lebih banyak di bawah';

  @override
  String get wallReelGone => 'Reel itu sudah tidak ada di server';

  @override
  String wallSavedToCookbook(String title) {
    return '$title disimpan ke buku resepmu';
  }

  @override
  String get wallInCookbook => 'Ada di buku resepmu';

  @override
  String get wallSaving => 'Menyimpan…';

  @override
  String get wallAddToCookbook => 'Tambah ke buku resep';

  @override
  String get wallLoadFailed => 'Dinding tidak termuat';

  @override
  String get wallEmptyTitle => 'Belum ada yang diimpor';

  @override
  String get wallEmptyBody =>
      'Impor reel dan ia muncul di sini, untuk semua orang.';

  @override
  String get wallImportReel => 'Impor reel';

  @override
  String get wallLoadMoreFailed => 'Tidak bisa memuat lagi — coba lagi';

  @override
  String get wallMoreReels => 'Reel lainnya';

  @override
  String get wallEndOfFeed => 'Itu semua reel untuk sekarang';

  @override
  String wallStepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count langkah',
    );
    return '$_temp0';
  }

  @override
  String wallIngredientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bahan',
    );
    return '$_temp0';
  }

  @override
  String get wallMethod => 'cara';

  @override
  String get wallReelLoadFailed => 'Reel ini tidak termuat';

  @override
  String get actionMarkCooked => 'Tandai sudah dimasak';

  @override
  String get actionMoveBackToCook => 'Pindahkan ke Untuk dimasak';

  @override
  String get actionNeverCooked => 'Belum pernah dimasak';

  @override
  String actionCookedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dimasak $count kali',
    );
    return '$_temp0';
  }

  @override
  String get actionStatusCookedBody =>
      'Pindah ke Sudah dimasak. Kamu bisa mengembalikannya.';

  @override
  String get actionStatusToCookBody =>
      'Pindah ke Untuk dimasak, siap dibuat lagi.';

  @override
  String get actionDeleteBody => 'Keluar dari jurnalmu. Ditanya dulu.';

  @override
  String get actionKeep => 'Simpan saja';

  @override
  String get actionRemoveTitle => 'Hapus hidangan ini?';

  @override
  String actionRemoveBody(String title) {
    return '$title keluar dari jurnalmu, bersama versi dan masakannya. Reel-nya masih ada kalau kamu mau mengimpor lagi — salinan ini tidak kembali.';
  }

  @override
  String get actionRemove => 'Hapus';

  @override
  String get profileSubtitle =>
      'Catatan tentang apa yang benar-benar kamu masak.';

  @override
  String get profileAccount => 'akun';

  @override
  String get profileComingSoon => 'Segera hadir';

  @override
  String get profileNutritionBody =>
      'Pandangan masa depan tentang bagaimana versimu mengubah hidangan.';

  @override
  String get profileSoon => 'segera';

  @override
  String get profileAppearance => 'tampilan';

  @override
  String get profileThemeSystem => 'SISTEM';

  @override
  String get profileThemeLight => 'TERANG';

  @override
  String get profileThemeDark => 'GELAP';

  @override
  String get profileHowItWorks => 'Cara kerja Shoku';

  @override
  String get profileHowItWorksBody => 'Gestur berbagi, dalam tiga langkah';

  @override
  String get profileResetJournal => 'Setel ulang jurnal';

  @override
  String get profileFooter => 'Shoku · dapur malam';

  @override
  String get helpTitle => 'Bantuan & masukan';

  @override
  String get helpSubtitle =>
      'Jawaban singkat untuk hal yang paling sering ditanya.';

  @override
  String get helpStillStuck => 'masih macet';

  @override
  String get helpStillStuckBody =>
      'Kirim tautan reel dan apa yang kamu harapkan. Itu membuat perbaikannya jauh lebih cepat.';

  @override
  String get nutritionTitle => 'Nutrisi';

  @override
  String get nutritionComingSoon => 'SEGERA HADIR';

  @override
  String get nutritionHeadline =>
      'Pandangan tentang bagaimana masakanmu berubah.';

  @override
  String get nutritionBody =>
      'Jurnalmu tetap jalan tanpanya. Saat hadir, ia hanya membaca hidangan yang kamu masak di sini.';

  @override
  String get nutritionBackToYou => 'Kembali ke Kamu';

  @override
  String get exitTitle => 'Keluar dari Shoku?';

  @override
  String get exitBody => 'Jurnalmu tersimpan. Tidak ada yang hilang.';

  @override
  String get exitKeepCooking => 'Lanjut memasak';

  @override
  String get exitExit => 'Keluar';

  @override
  String get orbAssistant => 'Asisten';

  @override
  String get orbAskAboutStep => 'Tanya tentang langkah ini';

  @override
  String timerStart(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'mulai timer $minutesString menit';
  }

  @override
  String get timerTimesUp => 'waktu habis';

  @override
  String get timerPaused => 'dijeda';

  @override
  String get timerRunning => 'berjalan';

  @override
  String timerOnStep(int step, String state) {
    final intl.NumberFormat stepNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String stepString = stepNumberFormat.format(step);

    return 'langkah $stepString · $state';
  }

  @override
  String get timerStartAgain => 'Mulai lagi';

  @override
  String get timerResume => 'Lanjutkan';

  @override
  String get timerPause => 'Jeda';

  @override
  String get timerStop => 'Hentikan';

  @override
  String get timerAlertsOff =>
      'notifikasi mati — aktifkan notifikasi untuk Shoku';

  @override
  String get timerAlertsLate =>
      'notifikasi bisa terlambat — izinkan alarm tepat di pengaturan';

  @override
  String get cookLeaveTitle => 'Keluar dari masakan ini?';

  @override
  String get cookLeaveBody =>
      'Kamu baru setengah jalan. Belum ada yang tersimpan.';

  @override
  String cookLeaveChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perubahan di masakan ini akan dibuang.',
    );
    return '$_temp0';
  }

  @override
  String cookChangedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count diubah',
    );
    return '$_temp0';
  }

  @override
  String cookStepLabel(String step) {
    return 'langkah $step';
  }

  @override
  String get cookTimerCleared =>
      'Timer dihapus — hidangan ini punya versi baru';

  @override
  String get cookBack => 'Kembali';

  @override
  String get cookFinishLog => 'Selesai & catat';

  @override
  String get cookNextStep => 'Langkah berikutnya';

  @override
  String get cookNoSteps => 'Ikuti resepnya.';

  @override
  String get micHint => 'Ketik atau tahan mic';

  @override
  String get micListening => 'Mendengar…';

  @override
  String get searchHint => 'Cari resep, catatan, akun';

  @override
  String hudStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hr',
    );
    return '$_temp0';
  }

  @override
  String hudLevel(String level) {
    return 'LVL $level';
  }

  @override
  String get botServerNotice => 'Asisten mengalami masalah — coba lagi.';

  @override
  String get botSignInNotice => 'Masuk untuk bertanya kepada asisten.';

  @override
  String get dishStopReading => 'Berhenti membaca';

  @override
  String get cookbookEmptySignedOut =>
      'Masuk untuk memulihkan resep Anda. Resep tersimpan di server, bukan di ponsel ini.';

  @override
  String get cookbookEmptyOffline =>
      'Resep Anda tidak dapat dimuat. Periksa koneksi lalu coba lagi.';

  @override
  String get importCapNotice =>
      'Impor hari ini habis. Kembali besok — atau tambahkan reel dari Dinding, yang sudah dibaca.';

  @override
  String get importCapWallHint =>
      'Atau tambahkan satu dari Dinding — sudah dibaca.';

  @override
  String botAsksLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pertanyaan tersisa hari ini',
      zero: 'tidak ada pertanyaan tersisa',
    );
    return '$_temp0';
  }
}
