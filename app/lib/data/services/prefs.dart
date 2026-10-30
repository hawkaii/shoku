import 'package:shared_preferences/shared_preferences.dart';

const _onboardingKey = 'onboarding_done';

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

  const Prefs._();
}
