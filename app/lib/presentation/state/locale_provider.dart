import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/prefs.dart';

/// The language the app is drawn in. `null` means "follow the phone": Android
/// resolves it against [supportedLocales] and picks the best match.
///
/// The choice is written to prefs in the same call that changes the state, so
/// the picker can never leave an unsaved language on screen. `main()` reads the
/// stored code before the first frame and seeds the controller, which is why
/// switching language does not restart or flash.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController(super.state);

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    await Prefs.setLocaleCode(locale?.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleController, Locale?>(
  (ref) => LocaleController(null),
);
