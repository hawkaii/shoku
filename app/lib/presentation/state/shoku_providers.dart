import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

/// Web preview helpers: `?screen=home&theme=dark` opens a screen directly.
///
/// On the web this comes from the address bar, which is the whole point of a
/// preview link. On a device `Uri.base` is the launch URL, never the intent,
/// so reading it there is dead config: a mobile build uses the
/// `--dart-define=PREVIEW_SCREEN=...` form instead (and normally none at all).
final _previewScreenRaw = kIsWeb
    ? Uri.base.queryParameters['screen']
    : const String.fromEnvironment('PREVIEW_SCREEN');
final previewScreen = (_previewScreenRaw == null || _previewScreenRaw!.isEmpty)
    ? null
    : _previewScreenRaw;

final _previewThemeRaw = kIsWeb
    ? Uri.base.queryParameters['theme']
    : const String.fromEnvironment('PREVIEW_THEME');
final previewTheme = (_previewThemeRaw == null || _previewThemeRaw!.isEmpty)
    ? null
    : _previewThemeRaw;
final previewStatic = kIsWeb
    ? Uri.base.queryParameters.containsKey('static')
    : const bool.fromEnvironment('PREVIEW_STATIC');

/// Theme mode — Account → Appearance writes here.
/// Default follows the phone: a dark-mode user should not be handed a bright
/// paper app on first launch. `theme=dark` still forces a mode for previewing.
final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => previewTheme == 'dark'
      ? ThemeMode.dark
      : previewTheme == 'light'
          ? ThemeMode.light
          : ThemeMode.system,
);

/// Onboarding gate. Previewing a screen skips the flow.
final onboardingDoneProvider =
    StateProvider<bool>((ref) => previewScreen != null);

/// Help topics shown on the help screen. Static copy, not state.
final helpTopicsProvider = Provider<List<Map<String, String>>>((ref) => const [
      {
        'q': 'How do I save a reel?',
        'a':
            'Share it from Instagram or YouTube and pick Shoku from the share sheet. It lands in Home in a few seconds.',
      },
      {
        'q': 'Why did my save fail?',
        'a':
            'Private accounts and region-locked videos cannot be read. Share the original post rather than a repost.',
      },
      {
        'q': 'What counts as a save?',
        'a':
            'One successful extraction. Retrying the same link does not use another save.',
      },
      {
        'q': 'Can I export a recipe?',
        'a':
            'Yes. Open any saved item and use Share to send it out as plain text.',
      },
    ]);
