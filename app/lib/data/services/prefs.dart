import 'package:shared_preferences/shared_preferences.dart';

const _onboardingKey = 'onboarding_done';
const _seededKey = 'journal_seeded';
const _visionDisclosureKey = 'receipt_vision_disclosure';
const _localeKey = 'app_locale';

/// Onboarding is persisted, not in-memory: it must not replay on every launch.
class Prefs {
  static Future<bool> onboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> setOnboardingDone(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, value);
  }

  /// Whether the demo kitchen has been written once. A flag, not a row count:
  /// deleting every dish must not resurrect the seed data.
  static Future<bool> journalSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seededKey) ?? false;
  }

  static Future<void> setJournalSeeded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seededKey, value);
  }

  /// One disclosure, once: the image leaves the phone for Meta's model.
  static Future<bool> receiptVisionSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_visionDisclosureKey) ?? false;
  }

  static Future<void> setReceiptVisionSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_visionDisclosureKey, value);
  }

  /// The chosen language code, or null for "follow the phone". Stored as a
  /// code rather than a locale: it outlives any one build of the app.
  static Future<String?> localeCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }

  static Future<void> setLocaleCode(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, code);
    }
  }

  const Prefs._();
}
