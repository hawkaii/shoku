import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/api_client.dart';
import '../../data/services/auth_service.dart';
import '../../data/sync/sync_repository.dart';
import '../../data/sync/sync_service.dart';
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

  /// Signed out has a ceiling. Retrying with no token is a local no-op, so a
  /// phone that has never signed in should not own a timer forever — the auth
  /// stream is what wakes it, and it does so immediately.
  static const _maxSignedOutRetries = 3;

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
    if (_ref.read(syncStatusProvider) == SyncStatus.syncing) return;

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
      await _ref.read(syncServiceProvider).sync();
      _attempt = 0;
      _signedOutRetries = 0;
      _set(SyncStatus.idle);
    } on ApiUnauthenticated {
      _set(SyncStatus.signedOut);
      _scheduleSignedOutRetry();
    } on ApiError {
      _fail(SyncStatus.failed);
    } catch (_) {
      // No network, DNS failure, server down: all the same to the user.
      _fail(SyncStatus.offline);
    } finally {
      // Whatever happened, the journal may have changed.
      await _ref.read(journalStoreProvider.notifier).refresh();
    }
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

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

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
