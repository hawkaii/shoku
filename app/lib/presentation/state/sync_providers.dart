import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/api_client.dart';
import '../../data/sync/sync_repository.dart';
import '../../data/sync/sync_service.dart';
import '../state/journal_store.dart';

enum SyncStatus { idle, syncing, offline, signedOut, failed }

/// Owns when sync happens and what the UI is allowed to say about it.
///
/// Everything here is quiet by design: a failed sync is not an error dialog,
/// it is a state the journal puts up with until the next attempt.
class SyncController {
  SyncController(this._ref);

  final Ref _ref;

  Future<void> syncNow() async {
    final status = _ref.read(syncStatusProvider);
    if (status == SyncStatus.syncing) return;

    _set(SyncStatus.syncing);
    try {
      await _ref.read(syncServiceProvider).sync();
      _set(SyncStatus.idle);
    } on ApiUnauthenticated {
      _set(SyncStatus.signedOut);
    } on ApiError {
      _set(SyncStatus.failed);
    } catch (_) {
      // No network, DNS failure, server down: all the same to the user.
      _set(SyncStatus.offline);
    } finally {
      // Whatever happened, the journal may have changed.
      await _ref.read(journalStoreProvider.notifier).refresh();
    }
  }

  void _set(SyncStatus status) {
    if (_ref.read(syncStatusProvider) != status) {
      _ref.read(syncStatusProvider.notifier).state = status;
    }
  }
}

final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    repository: SyncRepository(
      ref.watch(databaseProvider),
      ref.watch(journalRepositoryProvider),
    ),
    api: ApiClient(),
  );
});

final syncControllerProvider = Provider<SyncController>(
  (ref) => SyncController(ref),
);
