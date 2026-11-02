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
  String get tabCookbook => 'Resep';

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
  String get journalOnTheCounter => 'di meja';

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
  String get cookbookTitle => 'Resep';

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
  String get reasonInvalidRecipe => 'Kami tidak menemukan resep di yang itu';

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
}
