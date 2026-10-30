import '../../data/services/api_client.dart';
import 'sync_repository.dart';

/// One sync pass: push what this device changed, then pull what it hasn't seen.
///
/// Order matters. Pushing first means the server has our edits before we ask
/// what changed, so the pull can't hand back the older copy of something we
/// just wrote.
class SyncService {
  SyncService({required SyncRepository repository, required ApiClient api})
      : _repository = repository,
        _api = api;

  final SyncRepository _repository;
  final ApiClient _api;

  Future<SyncOutcome> sync() async {
    final payload = await _repository.dirtyPayload();
    final hasLocalChanges = payload.values.any((rows) => rows.isNotEmpty);

    var pushed = 0;
    if (hasLocalChanges) {
      final response = await _api.syncPush(payload);
      await _repository.markClean(response);
      pushed = payload.values.fold<int>(0, (sum, rows) => sum + rows.length);
    }

    final cursor = await _repository.readCursor();
    final pull = await _api.syncPull(cursor: cursor);
    await _repository.applyPull(pull);
    await _repository.writeCursor(pull['cursor'] as String?);

    final pulled = (pull['dishes'] as List? ?? const []).length +
        (pull['versions'] as List? ?? const []).length +
        (pull['cook_logs'] as List? ?? const []).length;

    return SyncOutcome(pushed: pushed, pulled: pulled, hasMore: pull['has_more'] == true);
  }
}

class SyncOutcome {
  const SyncOutcome({required this.pushed, required this.pulled, this.hasMore = false});

  final int pushed;
  final int pulled;
  final bool hasMore;

  bool get didAnything => pushed > 0 || pulled > 0;

  @override
  String toString() => 'SyncOutcome(pushed: $pushed, pulled: $pulled, hasMore: $hasMore)';
}
