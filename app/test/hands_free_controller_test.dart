import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/services/voice_services.dart';
import 'package:food_finder/presentation/state/hands_free_controller.dart';

class FakeSocket implements VoiceSocket {
  final _events = StreamController<dynamic>();
  final sentText = <String>[];
  final sentBinary = <Uint8List>[];
  bool closed = false;

  @override
  int? closeCode;

  @override
  Stream<dynamic> get events => _events.stream;

  @override
  void sendText(String text) => sentText.add(text);

  @override
  void sendBinary(Uint8List bytes) => sentBinary.add(bytes);

  @override
  Future<void> close([int? code]) async {
    closed = true;
    closeCode = code;
    if (!_events.isClosed) unawaited(_events.close());
  }

  void emit(Object event) => _events.add(event);

  Future<void> finish(int? code) async {
    closeCode = code;
    if (!_events.isClosed) unawaited(_events.close());
  }
}

class FakeSocketFactory implements VoiceSocketFactory {
  FakeSocket? socket;
  Uri? uri;

  @override
  VoiceSocket connect(Uri target) {
    uri = target;
    return socket = FakeSocket();
  }
}

class FakeCapture implements VoiceAudioCapture {
  void Function(Uint8List)? onData;
  bool started = false;
  bool stopped = false;
  bool fail = false;

  @override
  Future<void> start(void Function(Uint8List bytes) onData) async {
    if (fail) throw StateError('no mic');
    this.onData = onData;
    started = true;
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }

  void emit(Uint8List bytes) => onData?.call(bytes);
}

class FakeSpeaker implements VoiceSpeaker {
  final spoken = <String>[];
  String? locale;
  bool stopped = false;
  Completer<void>? gate;

  @override
  Future<void> speak(String text, {required String locale}) async {
    spoken.add(text);
    this.locale = locale;
    final waiting = gate;
    if (waiting != null) await waiting.future;
  }

  @override
  Future<void> stop() async {
    stopped = true;
    final waiting = gate;
    if (waiting != null && !waiting.isCompleted) waiting.complete();
  }
}

class FakeWakelock implements VoiceWakelock {
  bool enabled = false;
  int enabledCalls = 0;
  int disabledCalls = 0;

  @override
  Future<void> enable() async {
    enabled = true;
    enabledCalls++;
  }

  @override
  Future<void> disable() async {
    enabled = false;
    disabledCalls++;
  }
}

class FakeChime implements VoiceChime {
  int played = 0;

  @override
  Future<void> play() async => played++;
}

class _Harness {
  _Harness({
    String token = 'jwt',
    bool failCapture = false,
  }) {
    capture.fail = failCapture;
    controller = HandsFreeController(
      socketFactory: factory,
      capture: capture,
      speaker: speaker,
      wakelock: wakelock,
      chime: chime,
      ask: ask,
      actions: VoiceActions(
        next: () => events.add('next'),
        back: () => events.add('back'),
        currentStep: () => 'Mix the paneer',
        currentStepIndex: () => 0,
        startTimer: (minutes) async => events.add('timer:$minutes'),
        timerInFinalMinute: () => finalMinute,
      ),
      copy: HandsFreeCopy(
        checkIn: 'check in',
        help: 'help line',
        timerStarted: (minutes) => 'timer $minutes',
        offline: 'offline',
        auth: 'auth',
        cap: 'cap',
      ),
      token: token,
      locale: 'hi',
      keywords: const ['paneer', 'jeera'],
      baseUrl: 'http://example.test',
      reconnectDelay: const Duration(seconds: 1),
    );
  }

  final factory = FakeSocketFactory();
  final capture = FakeCapture();
  final speaker = FakeSpeaker();
  final wakelock = FakeWakelock();
  final chime = FakeChime();
  final events = <String>[];
  bool finalMinute = false;
  Completer<String>? askCompleter;
  String? lastQuestion;
  int? lastStep;

  late final HandsFreeController controller;

  Future<String> ask(String question, int step) {
    lastQuestion = question;
    lastStep = step;
    askCompleter ??= Completer<String>();
    return askCompleter!.future;
  }
}

void main() {
  test('connecting, thinking, speaking, then paused on an auth close', () {
    fakeAsync((async) {
      final h = _Harness();
      h.controller.start();
      async.flushMicrotasks();

      expect(h.controller.snapshot.phase, HandsFreePhase.listening);
      expect(h.wakelock.enabled, isTrue);
      expect(h.capture.started, isTrue);

      h.factory.socket!.emit(jsonEncode({
        'type': 'transcript',
        'text': 'is this done?',
        'final': true,
      }));
      async.flushMicrotasks();
      expect(h.controller.snapshot.phase, HandsFreePhase.thinking);
      expect(h.lastQuestion, 'is this done?');
      expect(h.lastStep, 0);

      h.speaker.gate = Completer<void>();
      h.askCompleter!.complete('It is done.');
      async.flushMicrotasks();
      expect(h.controller.snapshot.phase, HandsFreePhase.speaking);
      expect(h.speaker.spoken.last, 'It is done.');
      expect(h.speaker.locale, 'hi');

      h.speaker.gate!.complete();
      async.flushMicrotasks();
      expect(h.controller.snapshot.phase, HandsFreePhase.listening);

      h.factory.socket!.finish(4401);
      async.flushMicrotasks();
      expect(h.controller.snapshot.phase, HandsFreePhase.paused);
      expect(h.controller.snapshot.notice, HandsFreeNotice.auth);
      expect(h.wakelock.enabled, isFalse);
      expect(h.capture.stopped, isTrue);
    });
  });

  test('transcripts are ignored while the app is speaking', () {
    fakeAsync((async) {
      final h = _Harness();
      h.controller.start();
      async.flushMicrotasks();

      h.speaker.gate = Completer<void>();
      h.factory.socket!.emit(jsonEncode({
        'type': 'transcript',
        'text': 'how long?',
        'final': true,
      }));
      async.flushMicrotasks();
      h.askCompleter!.complete('A while.');
      async.flushMicrotasks();
      expect(h.controller.snapshot.phase, HandsFreePhase.speaking);

      h.factory.socket!.emit(jsonEncode({
        'type': 'transcript',
        'text': 'next',
        'final': true,
      }));
      async.flushMicrotasks();

      expect(h.events, isEmpty, reason: 'the mic is muted for meaning');
      expect(h.controller.snapshot.heard, 'how long?');
    });
  });

  test('barge-in stops TTS and returns to listening', () {
    fakeAsync((async) {
      final h = _Harness();
      h.controller.start();
      async.flushMicrotasks();

      h.speaker.gate = Completer<void>();
      h.factory.socket!.emit(jsonEncode({
        'type': 'transcript',
        'text': 'how long?',
        'final': true,
      }));
      async.flushMicrotasks();
      h.askCompleter!.complete('A while.');
      async.flushMicrotasks();
      expect(h.controller.snapshot.phase, HandsFreePhase.speaking);

      h.factory.socket!.emit(jsonEncode({'type': 'speechStart'}));
      async.flushMicrotasks();

      expect(h.speaker.stopped, isTrue);
      expect(h.controller.snapshot.phase, HandsFreePhase.listening);
    });
  });

  test('commands run locally and a timer speaks its confirmation', () {
    fakeAsync((async) {
      final h = _Harness();
      h.controller.start();
      async.flushMicrotasks();

      h.factory.socket!.emit(jsonEncode({
        'type': 'transcript',
        'text': 'start a 5 minute timer',
        'final': true,
      }));
      async.flushMicrotasks();

      expect(h.events, contains('timer:5'));
      expect(h.speaker.spoken, contains('timer 5'));
      expect(h.controller.snapshot.phase, HandsFreePhase.listening);
    });
  });

  test('check-in fires after four idle minutes with a chime and a line', () {
    fakeAsync((async) {
      final h = _Harness();
      h.controller.start();
      async.flushMicrotasks();

      async.elapse(const Duration(minutes: 3, seconds: 59));
      expect(h.chime.played, 0);

      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(h.chime.played, 1);
      expect(h.speaker.spoken, contains('check in'));
    });
  });

  test('check-in waits out a timer’s final minute', () {
    fakeAsync((async) {
      final h = _Harness()..finalMinute = true;
      h.controller.start();
      async.flushMicrotasks();

      async.elapse(const Duration(minutes: 4));
      async.flushMicrotasks();
      expect(h.chime.played, 0);

      h.finalMinute = false;
      async.elapse(const Duration(minutes: 1));
      async.flushMicrotasks();
      expect(h.chime.played, 1);
    });
  });

  test('ten minutes of silence ends the session and releases everything', () {
    fakeAsync((async) {
      final h = _Harness();
      h.controller.start();
      async.flushMicrotasks();

      async.elapse(const Duration(minutes: 10));
      async.flushMicrotasks();

      expect(h.controller.snapshot.phase, HandsFreePhase.off);
      expect(h.wakelock.enabled, isFalse);
      expect(h.capture.stopped, isTrue);
      expect(h.factory.socket!.closed, isTrue);
    });
  });

  test('stop releases the wakelock, mic and socket', () {
    fakeAsync((async) {
      final h = _Harness();
      h.controller.start();
      async.flushMicrotasks();

      h.controller.stop();
      async.flushMicrotasks();

      expect(h.controller.snapshot.phase, HandsFreePhase.off);
      expect(h.wakelock.disabledCalls, greaterThanOrEqualTo(1));
      expect(h.capture.stopped, isTrue);
      expect(h.factory.socket!.closed, isTrue);
      expect(h.speaker.stopped, isTrue);
    });
  });

  test('the first frame is the contract, then paced PCM frames', () {
    fakeAsync((async) {
      final h = _Harness();
      h.controller.start();
      async.flushMicrotasks();

      final hello =
          jsonDecode(h.factory.socket!.sentText.single) as Map<String, dynamic>;
      expect(hello['authorization'], 'Bearer jwt');
      expect(hello['language'], 'hi');
      expect(hello['keywords'], ['paneer', 'jeera']);
      expect((hello['sessionId'] as String).isNotEmpty, isTrue);

      async.elapse(const Duration(milliseconds: 25));
      expect(h.factory.socket!.sentBinary, isNotEmpty);
      expect(h.factory.socket!.sentBinary.first.length, 960);

      h.capture.emit(Uint8List.fromList(List.filled(960, 7)));
      async.elapse(const Duration(milliseconds: 20));
      expect(h.factory.socket!.sentBinary.last.length, 960);
      expect(h.factory.socket!.sentBinary.last.any((b) => b == 0), isFalse);
    });
  });

  test('a clean upstream close reconnects before the session ends', () {
    fakeAsync((async) {
      final h = _Harness();
      h.controller.start();
      async.flushMicrotasks();
      final first = h.factory.socket!;

      first.finish(1000);
      async.flushMicrotasks();
      expect(h.controller.snapshot.phase, HandsFreePhase.connecting);

      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(h.factory.socket, isNot(same(first)));
      expect(h.factory.socket!.sentText, hasLength(1));
    });
  });

  test('no token pauses with the auth notice and never connects', () {
    fakeAsync((async) {
      final h = _Harness(token: '');
      h.controller.start();
      async.flushMicrotasks();

      expect(h.controller.snapshot.phase, HandsFreePhase.paused);
      expect(h.controller.snapshot.notice, HandsFreeNotice.auth);
      expect(h.factory.socket, isNull);
    });
  });

  test('a cap close pauses with the cap notice', () {
    fakeAsync((async) {
      final h = _Harness();
      h.controller.start();
      async.flushMicrotasks();

      h.factory.socket!.finish(4429);
      async.flushMicrotasks();

      expect(h.controller.snapshot.phase, HandsFreePhase.paused);
      expect(h.controller.snapshot.notice, HandsFreeNotice.cap);
    });
  });

  test('an upstream failure pauses with the offline notice', () {
    fakeAsync((async) {
      final h = _Harness();
      h.controller.start();
      async.flushMicrotasks();

      h.factory.socket!.finish(4402);
      async.flushMicrotasks();

      expect(h.controller.snapshot.phase, HandsFreePhase.paused);
      expect(h.controller.snapshot.notice, HandsFreeNotice.offline);
    });
  });

  test('a mic that cannot open degrades to the offline notice', () {
    fakeAsync((async) {
      final h = _Harness(failCapture: true);
      h.controller.start();
      async.flushMicrotasks();

      expect(h.controller.snapshot.phase, HandsFreePhase.paused);
      expect(h.controller.snapshot.notice, HandsFreeNotice.offline);
      expect(h.wakelock.enabled, isFalse);
    });
  });
}
