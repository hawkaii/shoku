import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/utils/failure_log.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/feed_service.dart';
import 'package:food_finder/main.dart';
import 'package:food_finder/presentation/state/feed_providers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A failure whose own `toString` fails, to prove the logger cannot throw.
class _UnprintableError {
  @override
  String toString() => throw StateError('no string for you');
}

void main() {
  late DebugPrintCallback original;
  late List<String> lines;

  setUp(() {
    original = debugPrint;
    lines = [];
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) lines.add(message);
    };
  });

  tearDown(() => debugPrint = original);

  group('logFailure', () {
    test('writes one line carrying the label and the error', () {
      logFailure('feed page', 'timed out', StackTrace.current);

      expect(lines, hasLength(1));
      expect(lines.single, startsWith('[failure] feed page: timed out'));
      expect(lines.single, contains('timed out'));
    });

    test('stays one line even with a real stack trace', () {
      try {
        throw const FormatException('bad json');
      } catch (error, stack) {
        logFailure('decode', error, stack);
      }

      expect(lines, hasLength(1));
      expect(lines.single, contains('[failure] decode:'));
      expect(lines.single, contains('FormatException'));
      expect(lines.single.contains('\n'), isFalse);
    });

    test('does not require a stack', () {
      logFailure('prefs read', Exception('no plugin'));

      expect(lines, hasLength(1));
      expect(lines.single, contains('[failure] prefs read:'));
    });

    test('never throws, even when the error cannot be printed', () {
      expect(
        () => logFailure('weird', _UnprintableError(), StackTrace.current),
        returnsNormally,
      );
    });
  });

  group('installErrorHandlers', () {
    setUp(() {
      // Both back to the framework defaults a fresh isolate would have.
      FlutterError.onError = FlutterError.presentError;
      PlatformDispatcher.instance.onError = null;
      lines.clear();
    });

    tearDown(() {
      FlutterError.onError = FlutterError.presentError;
      PlatformDispatcher.instance.onError = null;
    });

    test('an async crash is logged and the app keeps running', () {
      installErrorHandlers();

      final handled = PlatformDispatcher.instance.onError!(
        StateError('a dropped future'),
        StackTrace.current,
      );

      // True is the whole point: the isolate survives a forgotten `await`.
      expect(handled, isTrue);
      expect(lines, hasLength(1));
      expect(lines.single, contains('[failure] uncaught async error:'));
      expect(lines.single, contains('a dropped future'));
    });

    test('a framework error goes through the same seam', () {
      installErrorHandlers();

      FlutterError.onError!(FlutterErrorDetails(
        exception: StateError('build threw'),
        stack: StackTrace.current,
      ));

      expect(
        lines.where((line) => line.contains('[failure] framework error:')),
        hasLength(1),
      );
    });
  });

  group('a user-visible failure keeps its documented fallback', () {
    test('a failing feed still reports failed, and is now logged', () async {
      final store = FeedStore(
        FeedService(
          api: ApiClient(
            baseUrl: 'http://localhost',
            tokenProvider: () => null,
            httpClient: MockClient((_) async => http.Response('nope', 500)),
          ),
        ),
      );

      await pumpEventQueue();

      // The Wall's contract: an empty feed that says it failed, never a crash.
      expect(store.state.failed, isTrue);
      expect(store.state.items, isEmpty);

      // What used to vanish: which request failed, and why.
      expect(
        lines.where((line) => line.contains('[failure] wall feed load:')),
        hasLength(1),
      );
      expect(lines.join('\n'), contains('ApiError'));
    });
  });
}
