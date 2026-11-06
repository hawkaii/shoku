import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'pending_share.dart';

/// What arrives from the system share sheet, reduced to the raw strings the app
/// reads.
///
/// One method per plugin call, and nothing else: a share is a platform event,
/// and a test cannot fire one. [FakeShareSource] in the tests is the same three
/// calls, so the cold-start path is exercised without a channel.
abstract interface class ShareSource {
  /// The share that launched this process, if there was one.
  Future<List<String>> initial();

  /// Shares that arrive while the app is already running.
  Stream<List<String>> stream();

  /// Tells the plugin the payload has been dealt with, so it is not read again.
  Future<void> reset();
}

/// The real thing, over `receive_sharing_intent`.
class ReceiveSharingIntentSource implements ShareSource {
  const ReceiveSharingIntentSource();

  @override
  Future<List<String>> initial() async {
    final files = await ReceiveSharingIntent.instance.getInitialMedia();
    return [for (final file in files) file.path];
  }

  @override
  Stream<List<String>> stream() => ReceiveSharingIntent.instance
      .getMediaStream()
      .map((files) => [for (final file in files) file.path]);

  @override
  Future<void> reset() => ReceiveSharingIntent.instance.reset();
}

/// Injected so a test can deliver a share without a platform channel.
final shareSourceProvider = Provider<ShareSource>(
  (ref) => const ReceiveSharingIntentSource(),
);

/// The note a share leaves on disk until a sheet opens it.
final pendingShareStoreProvider = Provider<PendingShareStore>(
  (ref) => PendingShareStore(),
);

/// The share waiting for a screen to take it.
final pendingShareProvider = StateProvider<PendingShare?>((ref) => null);

/// Share intake, alive for the whole app rather than for the shell.
///
/// `AppShell` is built by the router, which is redirected to `/welcome` and then
/// `/splash` until the first install and the session are settled — so intake
/// started there misses every share that arrives during that window. Watched
/// from `ShokuApp` instead: one instance, one subscription, started on the first
/// build and disposed with the app.
final shareIntakeProvider = Provider<ShareIntake>((ref) {
  final intake = ShareIntake(
    source: ref.watch(shareSourceProvider),
    store: ref.watch(pendingShareStoreProvider),
    onShare: (share) => ref.read(pendingShareProvider.notifier).state = share,
  );
  ref.onDispose(intake.dispose);
  unawaited(intake.start());
  return intake;
});

/// Turns a platform share into a [PendingShare], written down immediately.
class ShareIntake {
  ShareIntake({
    required this.source,
    required this.store,
    required this.onShare,
  });

  final ShareSource source;
  final PendingShareStore store;

  /// Called after the note is on disk, so a listener finds both.
  final void Function(PendingShare share) onShare;

  StreamSubscription<List<String>>? _sub;
  Future<void>? _started;

  /// Completes once the launching share has been read and written down.
  ///
  /// The app never waits for this — the sheet opens from the listener either
  /// way — but a test needs to know when the cold-start read is done.
  Future<void> get ready => _started ?? Future<void>.value();

  Future<void> start() => _started ??= _run();

  Future<void> _run() async {
    try {
      await _ingest(await source.initial());
    } catch (_) {
      // No platform channel (web, desktop): nothing launched the app from a
      // share, and that is not a failure.
    }
    _sub = source.stream().listen(_ingest);
  }

  Future<void> _ingest(List<String> parts) async {
    // An empty payload is the plugin saying "nothing here". Acknowledge it, so
    // the launching intent is not offered again on the next read.
    if (parts.isEmpty) {
      await _reset();
      return;
    }
    final share = PendingShare(url: _firstUrl(parts), sharedAt: DateTime.now());
    // On disk before anything else: a process that dies between the share and
    // the sheet still leaves the next launch something to open.
    await store.write(share);
    await _reset();
    onShare(share);
  }

  Future<void> _reset() async {
    try {
      await source.reset();
    } catch (_) {
      // Platform not available; there is nothing to clear.
    }
  }

  static final _urlPattern = RegExp(r'https?://[^\s]+');

  /// The first link anywhere in the share. Instagram sends the reel URL as the
  /// shared text; a browser may send it after a title line.
  static String? _firstUrl(List<String> parts) {
    for (final part in parts) {
      final match = _urlPattern.firstMatch(part);
      if (match != null) return match.group(0);
    }
    return null;
  }

  void dispose() => _sub?.cancel();
}
