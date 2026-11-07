import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/services/assistant_service.dart';
import '../../data/services/voice_command_parser.dart';
import '../../data/services/voice_services.dart';

enum HandsFreePhase { off, connecting, listening, thinking, speaking, paused }

enum HandsFreeNotice { none, offline, auth, cap }

class HandsFreeState {
  const HandsFreeState({
    required this.phase,
    this.heard = '',
    this.notice = HandsFreeNotice.none,
  });

  const HandsFreeState.off()
      : phase = HandsFreePhase.off,
        heard = '',
        notice = HandsFreeNotice.none;

  final HandsFreePhase phase;
  final String heard;
  final HandsFreeNotice notice;

  bool get isActive =>
      phase != HandsFreePhase.off && phase != HandsFreePhase.paused;
}

/// What the screen lets a command do. The controller never navigates itself.
class VoiceActions {
  const VoiceActions({
    required this.next,
    required this.back,
    required this.currentStep,
    required this.currentStepIndex,
    required this.startTimer,
    required this.timerInFinalMinute,
  });

  final void Function() next;
  final void Function() back;
  final String Function() currentStep;
  final int Function() currentStepIndex;
  final Future<void> Function(int minutes) startTimer;
  final bool Function() timerInFinalMinute;
}

/// Scripted lines, in the reader's language. Model answers are spoken as they
/// arrive; these are the words the app itself owns.
class HandsFreeCopy {
  const HandsFreeCopy({
    required this.checkIn,
    required this.help,
    required this.timerStarted,
    required this.offline,
    required this.auth,
    required this.cap,
  });

  final String checkIn;
  final String help;
  final String Function(int minutes) timerStarted;
  final String offline;
  final String auth;
  final String cap;
}

class HandsFreeController extends StateNotifier<HandsFreeState> {
  HandsFreeController({
    required VoiceSocketFactory socketFactory,
    required VoiceAudioCapture capture,
    required VoiceSpeaker speaker,
    required VoiceWakelock wakelock,
    required VoiceChime chime,
    required Future<String> Function(String question, int stepIndex) ask,
    required VoiceActions actions,
    required HandsFreeCopy copy,
    required String token,
    required String locale,
    required List<String> keywords,
    String? baseUrl,
    this.pacerInterval = const Duration(milliseconds: 20),
    this.checkInAfter = const Duration(minutes: 4),
    this.idleStopAfter = const Duration(minutes: 10),
    this.reconnectDelay = const Duration(seconds: 1),
  })  : _socketFactory = socketFactory,
        _capture = capture,
        _speaker = speaker,
        _wakelock = wakelock,
        _chime = chime,
        _ask = ask,
        _actions = actions,
        _copy = copy,
        _token = token,
        _locale = locale,
        _keywords = keywords,
        _baseUrl = baseUrl,
        super(const HandsFreeState.off());

  final VoiceSocketFactory _socketFactory;
  final VoiceAudioCapture _capture;
  final VoiceSpeaker _speaker;
  final VoiceWakelock _wakelock;
  final VoiceChime _chime;
  final Future<String> Function(String question, int stepIndex) _ask;
  final VoiceActions _actions;
  final HandsFreeCopy _copy;
  final String _token;
  final String _locale;
  final List<String> _keywords;
  final String? _baseUrl;

  final Duration pacerInterval;
  final Duration checkInAfter;
  final Duration idleStopAfter;
  final Duration reconnectDelay;

  final _sessionId = const Uuid().v4();

  VoiceSocket? _socket;
  StreamSubscription<dynamic>? _socketSub;
  Timer? _pacer;
  Timer? _checkIn;
  Timer? _idleStop;
  Timer? _reconnect;
  final List<int> _audioBuffer = <int>[];

  bool _active = false;
  bool _userStopped = false;
  bool _mounted = true;

  bool get isRunning => _active;

  /// Public read of the notifier value for widgets that hold the controller.
  HandsFreeState get snapshot => state;

  Future<void> start() async {
    if (state.isActive) return;
    _active = true;
    _userStopped = false;
    _set(const HandsFreeState(phase: HandsFreePhase.connecting));
    _resetIdleTimers();
    try {
      await _wakelock.enable();
    } catch (_) {
      // A screen that stays awake is a convenience, not the feature.
    }
    try {
      await _connect();
      await _capture.start(_onAudio);
      _startPacer();
      if (_active && state.phase == HandsFreePhase.connecting) {
        _set(const HandsFreeState(phase: HandsFreePhase.listening));
      }
    } catch (_) {
      await _fail(HandsFreeNotice.offline);
    }
  }

  Future<void> _connect() async {
    if (!_active) return;
    if (_token.isEmpty) {
      await _fail(HandsFreeNotice.auth);
      return;
    }
    try {
      final socket = _socketFactory.connect(voiceSocketUri(baseUrl: _baseUrl));
      _socket = socket;
      _socketSub = socket.events.listen(
        _onEvent,
        onError: (Object _) {
          // The done callback owns reconnects; an error alone is not fatal.
        },
        onDone: _onSocketDone,
      );
      socket.sendText(jsonEncode({
        'authorization': 'Bearer $_token',
        'language': _locale,
        'keywords': _keywords.take(50).toList(),
        'sessionId': _sessionId,
      }));
      if (state.phase != HandsFreePhase.listening) {
        _set(HandsFreeState(
            phase: HandsFreePhase.listening, heard: state.heard));
      }
    } catch (_) {
      await _fail(HandsFreeNotice.offline);
    }
  }

  void _startPacer() {
    _pacer?.cancel();
    _pacer = Timer.periodic(pacerInterval, (_) => _sendFrame());
  }

  void _sendFrame() {
    final socket = _socket;
    if (!_active || socket == null) return;
    // Exactly one 20 ms frame per tick: 24 kHz × 0.02 s × 2 bytes = 960.
    // A larger capture chunk is held and sent over the following ticks, so the
    // server hears wall-clock time even when the OS hands us a bigger buffer.
    final Uint8List data;
    if (_audioBuffer.length >= 960) {
      data = Uint8List.fromList(_audioBuffer.sublist(0, 960));
      _audioBuffer.removeRange(0, 960);
    } else {
      data = Uint8List(960); // silence is still sent while listening
    }
    try {
      socket.sendBinary(data);
    } catch (_) {
      // A dead sink closes the socket, and the done handler reconnects.
    }
  }

  void _onAudio(Uint8List bytes) => _audioBuffer.addAll(bytes);

  void _onEvent(dynamic raw) {
    if (!_active) return;
    Map<String, dynamic>? data;
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {
        return;
      }
    } else if (raw is Map) {
      data = Map<String, dynamic>.from(raw);
    }
    if (data == null) return;

    switch (data['type'] ?? data['event']) {
      case 'speechStart':
        unawaited(_bargeIn());
      case 'transcript':
        // While the app is speaking the mic is muted for meaning: audio keeps
        // flowing so the server can hear a barge-in, but its words do not
        // become commands or a new "heard" line until speechStart stops TTS.
        if (state.phase == HandsFreePhase.speaking) return;
        final text =
            (data['text'] ?? data['transcript'] ?? '').toString().trim();
        if (text.isEmpty) return;
        _resetIdleTimers();
        _set(HandsFreeState(
            phase: state.phase, heard: text, notice: state.notice));
        final finalTurn = data['final'] == true || data['is_final'] == true;
        if (finalTurn) unawaited(_handleFinal(text));
      case 'speechComplete':
      case 'speechEnd':
        break;
      case 'error':
        final message = (data['message'] ?? '').toString().toLowerCase();
        if (message.contains('cap')) unawaited(_fail(HandsFreeNotice.cap));
      default:
        break; // unknown events are not ours to guess at
    }
  }

  Future<void> _bargeIn() async {
    _resetIdleTimers();
    if (state.phase != HandsFreePhase.speaking) return;
    await _speaker.stop();
    if (_active && _mounted) {
      _set(HandsFreeState(phase: HandsFreePhase.listening, heard: state.heard));
    }
  }

  Future<void> _handleFinal(String text) async {
    if (!_active) return;
    final command = parseVoiceCommand(text);
    switch (command) {
      case NextStep():
        _actions.next();
        _listenAgain();
      case PreviousStep():
        _actions.back();
        _listenAgain();
      case RepeatStep():
        await _speak(_actions.currentStep());
      case HelpCommand():
        await _speak(_copy.help);
      case StartTimer():
        await _actions.startTimer(command.minutes);
        await _speak(_copy.timerStarted(command.minutes));
      case StopHandsFree():
        await stop();
      case AskQuestion():
        await _answer(command.text);
      case IgnoredSpeech():
        break;
    }
  }

  Future<void> _answer(String question) async {
    if (!_active) return;
    _set(HandsFreeState(phase: HandsFreePhase.thinking, heard: state.heard));
    try {
      final answer = await _ask(question, _actions.currentStepIndex());
      if (!_active) return;
      await _speak(answer);
    } on AssistantCapReached {
      await _fail(HandsFreeNotice.cap);
    } catch (_) {
      await _fail(HandsFreeNotice.offline);
    }
  }

  Future<void> _speak(String text) async {
    if (!_active || text.trim().isEmpty) return;
    _set(HandsFreeState(phase: HandsFreePhase.speaking, heard: state.heard));
    await _speaker.speak(text, locale: _locale);
    if (!_active) return;
    if (_mounted && state.phase == HandsFreePhase.speaking) _listenAgain();
  }

  void _listenAgain() {
    if (!_active) return;
    _set(HandsFreeState(phase: HandsFreePhase.listening, heard: state.heard));
    // A line the app spoke is not user activity: it resets the next check-in,
    // never the ten-minute silence window that ends the session.
    _resetCheckIn();
  }

  void _resetIdleTimers() {
    _idleStop?.cancel();
    if (!_active) return;
    _idleStop = Timer(idleStopAfter, () => unawaited(stop()));
    _resetCheckIn();
  }

  void _resetCheckIn() {
    _checkIn?.cancel();
    if (!_active) return;
    _checkIn = Timer(checkInAfter, _maybeCheckIn);
  }

  Future<void> _maybeCheckIn() async {
    if (!_active) return;
    if (state.phase == HandsFreePhase.speaking ||
        _actions.timerInFinalMinute()) {
      _checkIn = Timer(const Duration(minutes: 1), _maybeCheckIn);
      return;
    }
    await _chime.play();
    if (!_active) return;
    await _speak(_copy.checkIn);
  }

  void _onSocketDone() {
    final code = _socket?.closeCode;
    _socket = null;
    _socketSub = null;
    if (!_active || _userStopped) return;
    if (code == 4401) {
      unawaited(_fail(HandsFreeNotice.auth));
    } else if (code == 4429) {
      unawaited(_fail(HandsFreeNotice.cap));
    } else if (code == 4402) {
      unawaited(_fail(HandsFreeNotice.offline));
    } else {
      _set(
          HandsFreeState(phase: HandsFreePhase.connecting, heard: state.heard));
      _reconnect = Timer(reconnectDelay, () => unawaited(_connect()));
    }
  }

  Future<void> _fail(HandsFreeNotice notice) async {
    if (!_active && state.phase == HandsFreePhase.paused) return;
    _active = false;
    await _release();
    if (_mounted) {
      _set(HandsFreeState(
        phase: HandsFreePhase.paused,
        heard: state.heard,
        notice: notice,
      ));
    }
  }

  Future<void> stop() async {
    _userStopped = true;
    _active = false;
    await _release();
    if (_mounted) _set(const HandsFreeState.off());
  }

  Future<void> _release() async {
    _pacer?.cancel();
    _pacer = null;
    _checkIn?.cancel();
    _idleStop?.cancel();
    _reconnect?.cancel();
    _audioBuffer.clear();
    await _speaker.stop();
    try {
      await _capture.stop();
    } catch (_) {}
    try {
      unawaited(_socketSub?.cancel());
    } catch (_) {}
    _socketSub = null;
    try {
      unawaited(_socket?.close());
    } catch (_) {}
    _socket = null;
    try {
      await _wakelock.disable();
    } catch (_) {}
  }

  void _set(HandsFreeState next) {
    if (_mounted) state = next;
  }

  @override
  void dispose() {
    _mounted = false;
    unawaited(_release());
    super.dispose();
  }
}

/// Everything the screen must supply to build a controller. Kept in one object
/// so a test can override the factory without knowing each dependency.
class HandsFreeSetup {
  const HandsFreeSetup({
    required this.token,
    required this.locale,
    required this.keywords,
    required this.actions,
    required this.copy,
    required this.ask,
  });

  final String token;
  final String locale;
  final List<String> keywords;
  final VoiceActions actions;
  final HandsFreeCopy copy;
  final Future<String> Function(String question, int stepIndex) ask;
}
