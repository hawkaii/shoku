import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/config/shoku_config.dart';

/// The socket the API exposes, behind an interface so tests own the wire.
abstract class VoiceSocket {
  Stream<dynamic> get events;
  int? get closeCode;
  void sendText(String text);
  void sendBinary(Uint8List bytes);
  Future<void> close([int? code]);
}

abstract class VoiceSocketFactory {
  VoiceSocket connect(Uri uri);
}

class WebSocketVoiceSocketFactory implements VoiceSocketFactory {
  const WebSocketVoiceSocketFactory();

  @override
  VoiceSocket connect(Uri uri) => WebSocketVoiceSocket(
        WebSocketChannel.connect(uri),
      );
}

class WebSocketVoiceSocket implements VoiceSocket {
  WebSocketVoiceSocket(this._channel);

  final WebSocketChannel _channel;

  @override
  Stream<dynamic> get events => _channel.stream;

  @override
  int? get closeCode => _channel.closeCode;

  @override
  void sendText(String text) => _channel.sink.add(text);

  @override
  void sendBinary(Uint8List bytes) => _channel.sink.add(bytes);

  @override
  Future<void> close([int? code]) => _channel.sink.close(code);
}

/// `/v1/voice/asr` on the same host as the API, as a WebSocket.
Uri voiceSocketUri({String? baseUrl}) {
  final raw = baseUrl ?? ShokuConfig.apiBaseUrl;
  final uri = Uri.parse(raw);
  return uri.replace(
    scheme: uri.scheme == 'https' ? 'wss' : 'ws',
    path: '/v1/voice/asr',
    query: '',
  );
}

/// Mono PCM16 at 24 kHz, handed to the controller as it arrives.
abstract class VoiceAudioCapture {
  Future<void> start(void Function(Uint8List bytes) onData);
  Future<void> stop();
}

class RecordVoiceAudioCapture implements VoiceAudioCapture {
  RecordVoiceAudioCapture({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  StreamSubscription<Uint8List>? _subscription;

  @override
  Future<void> start(void Function(Uint8List bytes) onData) async {
    final stream = await _recorder.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 24000,
      numChannels: 1,
    ));
    _subscription = stream.listen(onData);
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _recorder.stop();
    } catch (_) {
      // Already stopped, or no engine in this build.
    }
  }
}

abstract class VoiceWakelock {
  Future<void> enable();
  Future<void> disable();
}

class WakelockPlusVoiceWakelock implements VoiceWakelock {
  const WakelockPlusVoiceWakelock();

  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}

/// Speech out, with completion rather than "queued": the controller needs to
/// know when the room is quiet again.
abstract class VoiceSpeaker {
  Future<void> speak(String text, {required String locale});
  Future<void> stop();
}

class TtsVoiceSpeaker implements VoiceSpeaker {
  TtsVoiceSpeaker({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  Completer<void>? _done;

  @override
  Future<void> speak(String text, {required String locale}) async {
    if (text.trim().isEmpty) return;
    final done = Completer<void>();
    _done = done;
    _tts.setCompletionHandler(() {
      if (!done.isCompleted) done.complete();
    });
    _tts.setCancelHandler(() {
      if (!done.isCompleted) done.complete();
    });
    _tts.setErrorHandler((_) {
      if (!done.isCompleted) done.complete();
    });
    try {
      await _tts.setLanguage(ttsLocale(locale));
      await _tts.setSpeechRate(0.48);
      await _tts.speak(text);
      await done.future.timeout(const Duration(seconds: 45), onTimeout: () {});
    } catch (_) {
      if (!done.isCompleted) done.complete();
    } finally {
      if (identical(_done, done)) _done = null;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    final done = _done;
    if (done != null && !done.isCompleted) done.complete();
  }
}

/// The ten app languages as the device engines name them.
String ttsLocale(String languageCode) => switch (languageCode) {
      'en' => 'en-US',
      'es' => 'es-ES',
      'fr' => 'fr-FR',
      'pt' => 'pt-BR',
      'id' => 'id-ID',
      'hi' => 'hi-IN',
      'mr' => 'mr-IN',
      'bn' => 'bn-IN',
      'ta' => 'ta-IN',
      'te' => 'te-IN',
      _ => 'en-US',
    };

/// A soft sound before the check-in line. Injected so tests never play audio.
abstract class VoiceChime {
  Future<void> play();
}

class SystemVoiceChime implements VoiceChime {
  const SystemVoiceChime();

  @override
  Future<void> play() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}
