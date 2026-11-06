import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/services/voice_services.dart';
import 'hands_free_controller.dart';

/// Builds a live controller. Tests override this provider with a factory that
/// injects fake audio, socket, speaker and wakelock.
final handsFreeFactoryProvider =
    Provider<HandsFreeController Function(HandsFreeSetup)>((ref) {
  return (setup) => HandsFreeController(
        socketFactory: const WebSocketVoiceSocketFactory(),
        capture: RecordVoiceAudioCapture(),
        speaker: TtsVoiceSpeaker(),
        wakelock: const WakelockPlusVoiceWakelock(),
        chime: const SystemVoiceChime(),
        ask: setup.ask,
        actions: setup.actions,
        copy: setup.copy,
        token: setup.token,
        locale: setup.locale,
        keywords: setup.keywords,
      );
});

/// A request id is per turn; the controller owns a session id separately.
String newVoiceRequestId() => const Uuid().v4();
