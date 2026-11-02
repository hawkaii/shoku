import 'package:flutter/widgets.dart';

/// The languages Shoku ships today. This list is the single place that decides
/// both what `MaterialApp` supports and what the picker offers; adding a
/// language means adding its ARB and one row here.
const shokuSupportedLocales = <Locale>[
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('pt'),
  Locale('id'),
  Locale('hi'),
  Locale('mr'),
  Locale('bn'),
  Locale('ta'),
  Locale('te'),
];

/// Each language is named in its own script: someone who cannot read English
/// must still be able to find their language.
class ShokuLanguage {
  final Locale locale;
  final String nativeName;

  const ShokuLanguage(this.locale, this.nativeName);
}

const shokuLanguages = <ShokuLanguage>[
  ShokuLanguage(Locale('en'), 'English'),
  ShokuLanguage(Locale('hi'), 'हिन्दी'),
  ShokuLanguage(Locale('mr'), 'मराठी'),
  ShokuLanguage(Locale('bn'), 'বাংলা'),
  ShokuLanguage(Locale('ta'), 'தமிழ்'),
  ShokuLanguage(Locale('te'), 'తెలుగు'),
  ShokuLanguage(Locale('es'), 'Español'),
  ShokuLanguage(Locale('fr'), 'Français'),
  ShokuLanguage(Locale('pt'), 'Português'),
  ShokuLanguage(Locale('id'), 'Bahasa Indonesia'),
];

/// The native name for a stored locale code, or null when the code is not one
/// we ship (a build that dropped a language, or a corrupted preference).
String? shokuLanguageName(Locale? locale) {
  if (locale == null) return null;
  for (final language in shokuLanguages) {
    if (language.locale.languageCode == locale.languageCode) {
      return language.nativeName;
    }
  }
  return null;
}

/// A stored code is only trusted if this build still supports it; anything
/// else falls back to the system locale rather than to a blank app.
Locale? shokuLocaleFromCode(String? code) {
  if (code == null || code.isEmpty) return null;
  for (final locale in shokuSupportedLocales) {
    if (locale.languageCode == code) return locale;
  }
  return null;
}
