import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Read-aloud, per device.
///
/// Off by default: an app that starts talking in a kitchen is an app you turn
/// off. The toggle is remembered on this phone, not synced — it is a preference
/// about this room, not about the recipe.
class SpeechService {
  SpeechService({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    // The button is a toggle, so the service has to know when speech actually
    // ends — not just when it starts.
    _tts.setCompletionHandler(() => speaking.value = false);
    _tts.setCancelHandler(() => speaking.value = false);
    _tts.setErrorHandler((_) => speaking.value = false);
  }

  static const _key = 'read_aloud';

  final FlutterTts _tts;

  /// True while the engine is speaking. The header and step speakers listen to
  /// this so a second tap stops instead of starting over.
  final speaking = ValueNotifier<bool>(false);

  Future<bool> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (_) {
      // Optional platform work: no prefs store (web preview) means the toggle
      // starts off, which is the shipped default anyway.
      return false;
    }
  }

  Future<void> remember(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, enabled);
    } catch (_) {
      // Optional platform work: a prefs store that cannot write costs a repeat
      // of the setting, not the setting.
    }
  }

  /// Reads an answer or a step. Never called for a diff or a notice.
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.setSpeechRate(0.48);
      speaking.value = true;
      await _tts.speak(text);
    } catch (_) {
      // Optional platform work: no engine here (web, a silent phone). The text
      // is still on screen, so the failure is the voice, not the recipe.
      speaking.value = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Optional platform work: no TTS engine means nothing was speaking, so
      // there is nothing to stop. The flag is corrected below regardless.
    }
    speaking.value = false;
  }
}

class ReadAloud extends StateNotifier<bool> {
  ReadAloud(this._speech) : super(false) {
    _restore();
  }

  final SpeechService _speech;

  Future<void> _restore() async {
    final enabled = await _speech.load();
    if (!mounted) return;
    state = enabled;
  }

  Future<void> toggle() async {
    state = !state;
    await _speech.remember(state);
    if (!state) await _speech.stop();
  }

  Future<void> speak(String text) async {
    if (state) await _speech.speak(text);
  }

  Future<void> stop() => _speech.stop();
}

final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());

final readAloudProvider = StateNotifierProvider<ReadAloud, bool>(
  (ref) => ReadAloud(ref.watch(speechServiceProvider)),
);
