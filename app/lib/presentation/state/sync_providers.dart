import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/sample_recipe.dart';
import '../../data/services/api_client.dart';
import '../../data/services/auth_service.dart';
import '../../data/sync/sync_repository.dart';
import '../../data/sync/sync_service.dart';
import '../state/auth_providers.dart';

export '../state/auth_providers.dart';
import '../state/journal_store.dart';

enum SyncStatus { idle, syncing, offline, signedOut, failed }

/// Where the retry delays come from: 2 s, 4 s, 8 s, then every 30 s.
///
/// A backoff is not a punishment. It is the difference between "this device is
/// offline and will try again" and "this device gave up the first time and the
/// journal stays empty until you reload the page".
class SyncBackoff {
  static const List<Duration> delays = [
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 30),
  ];

  static Duration delayFor(int attempt) =>
      delays[attempt.clamp(0, delays.length - 1)];

  const SyncBackoff._();
}

/// Owns when sync happens and what the UI is allowed to say about it.
///
/// Everything here is quiet by design: a failed sync is not an error dialog,
/// it is a state the journal puts up with until the next attempt.
class SyncController {
  SyncController(this._ref);

  final Ref _ref;

  Timer? _retry;
  int _attempt = 0;
  int _signedOutRetries = 0;
  bool _disposed = false;

  /// A pass is in flight right now.
  bool _passRunning = false;

  /// Something asked for a pass while one was running.
  ///
  /// That request used to be dropped on the floor (`if (status == syncing)
  /// return;`), so an edit made in the middle of a pass waited for resume, the
  /// 30 s retry, or the next edit before it left the device. It is now
  /// remembered and run exactly once when the current pass ends.
  bool _pending = false;

  /// Signed out has a ceiling. Retrying with no token is a local no-op, so a
  /// phone that has never signed in should not own a timer forever — the auth
  /// stream is what wakes it, and it does so immediately.
  static const _maxSignedOutRetries = 6;

  void dispose() {
    _disposed = true;
    _retry?.cancel();
  }

  /// The auth state changed. New information resets the backoff: a fresh token
  /// deserves an attempt now, not at the end of somebody else's 30 seconds.
  Future<void> onAuthChanged(ShokuAuthEvent event) async {
    if (_disposed) return;
    if (event == ShokuAuthEvent.signedOut) {
      _retry?.cancel();
      _retry = null;
      _attempt = 0;
      _set(SyncStatus.signedOut);
      return;
    }
    _attempt = 0;
    _signedOutRetries = 0;
    _retry?.cancel();
    _retry = null;
    // The sample belongs to signed-out kitchens. It goes before the first push
    // so its rows can never travel to the server.
    await _ref
        .read(journalStoreProvider.notifier)
        .dropSample(sampleId: SampleRecipe.dishId);
    await syncNow();
  }

  /// Back on screen. Only worth a pass if the last one left something unsettled.
  Future<void> onResume() async {
    if (_disposed) return;
    if (_ref.read(syncStatusProvider) == SyncStatus.idle) return;
    _attempt = 0;
    _signedOutRetries = 0;
    await syncNow();
  }

  Future<void> syncNow() async {
    if (_disposed) return;
    if (_passRunning) {
      // Not dropped: remembered. The flag is cleared as each pass starts, so a
      // burst of requests during one pass collapses into a single follow-up.
      _pending = true;
      return;
    }

    _passRunning = true;
    try {
      do {
        _pending = false;
        await _pass();
      } while (_pending && !_disposed);
    } finally {
      _passRunning = false;
    }
  }

  /// One pass. [syncNow] decides when this runs; this decides what it does.
  Future<void> _pass() async {
    _retry?.cancel();
    _retry = null;

    // No token, no request. The 401 would tell us the same thing, and a round
    // trip per backoff tick is not how anybody should learn they are signed out.
    if (_ref.read(authServiceProvider).accessToken == null) {
      _set(SyncStatus.signedOut);
      _scheduleSignedOutRetry();
      return;
    }

    _set(SyncStatus.syncing);
    try {
      await _ref.read(syncServiceProvider).sync(
            onProgress: _setProgress,
          );
      _attempt = 0;
      _signedOutRetries = 0;
      _set(SyncStatus.idle);
    } on ApiUnauthenticated {
      _set(SyncStatus.signedOut);
      _scheduleSignedOutRetry();
    } on ApiError {
      _fail(SyncStatus.failed);
    } on SyncPageLimitExceeded {
      // Not "offline": the network answered, it just would not stop paging.
      // Reported as a failed pass so the retry loop owns it.
      _fail(SyncStatus.failed);
    } catch (_) {
      // No network, DNS failure, server down: all the same to the user.
      _fail(SyncStatus.offline);
    } finally {
      _setProgress(null);
      // Whatever happened, the journal may have changed.
      await _ref.read(journalStoreProvider.notifier).refresh();
    }
  }

  void _setProgress(SyncProgress? progress) {
    if (_disposed) return;
    _ref.read(syncProgressProvider.notifier).state = progress;
  }

  void _fail(SyncStatus status) {
    _set(status);
    _scheduleRetry();
  }

  void _scheduleRetry() {
    _retry?.cancel();
    if (_disposed) return;
    final delay = SyncBackoff.delayFor(_attempt);
    _attempt++;
    _retry = Timer(delay, () {
      if (!_disposed) unawaited(syncNow());
    });
  }

  void _scheduleSignedOutRetry() {
    if (_signedOutRetries >= _maxSignedOutRetries) return;
    _signedOutRetries++;
    _scheduleRetry();
  }

  void _set(SyncStatus status) {
    if (_ref.read(syncStatusProvider) != status) {
      _ref.read(syncStatusProvider.notifier).state = status;
    }
  }
}

final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);

/// How far a paginated restore has got, or null when no pass is running.
///
/// A separate provider on purpose: the status enum is a switch the sync line and
/// its tests read by value, and growing it with a `restoring` case would change
/// what every existing `syncing` test means. This carries the number instead, so
/// "restoring 2 pages / 1,000 rows" is available to the UI without moving the
/// line's contract.
final syncProgressProvider = StateProvider<SyncProgress?>((ref) => null);

/// Supabase's session events, as the app actually cares about them.
///
/// This exists because nothing used to listen. A sync pass that ran before the
/// token was ready reported `signedOut` and stayed there — no retry, no second
/// attempt — so the journal looked empty until the page was reloaded. The
/// stream is the wake-up call that was missing.
final authEventProvider = StreamProvider<ShokuAuthEvent>((ref) {
  try {
    return ref.watch(authServiceProvider).events;
  } catch (_) {
    // Auth unavailable (web preview, missing config): signed-out is a valid,
    // quiet state and must not stop the app from opening.
    return const Stream<ShokuAuthEvent>.empty();
  }
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    repository: SyncRepository(
      ref.watch(databaseProvider),
      ref.watch(journalRepositoryProvider),
    ),
    api: ApiClient(auth: ref.watch(authServiceProvider)),
  );
});

/// The sync layer's own wiring: auth in, retries out.
///
/// Watching this provider (see [ShokuApp]) is what subscribes to the auth
/// stream, so there is exactly one listener and it lives with the controller
/// that acts on it.
final syncControllerProvider = Provider<SyncController>((ref) {
  final controller = SyncController(ref);
  ref.onDispose(controller.dispose);

  ref.listen<AsyncValue<ShokuAuthEvent>>(
    authEventProvider,
    (previous, next) {
      final event = next.valueOrNull;
      if (event == null || event == ShokuAuthEvent.other) return;
      unawaited(controller.onAuthChanged(event));
    },
    fireImmediately: true,
  );

  return controller;
});
