import '../../data/services/api_client.dart';
import 'sync_repository.dart';

/// One sync pass: push what this device changed, then pull what it hasn't seen.
///
/// Order matters. Pushing first means the server has our edits before we ask
/// what changed, so the pull can't hand back the older copy of something we
/// just wrote.
///
/// The pull is a loop, not a request. `/v1/sync/pull` paginates at 500 rows per
/// table and answers `has_more: true` with a cursor pointing at the last row it
/// sent. A client that writes that cursor and stops has declared the rest of the
/// table "already seen": those rows never arrive again, on that device or any
/// later one. So a pass follows every page before it stores a cursor.
class SyncService {
  SyncService({
    required SyncRepository repository,
    required ApiClient api,
    this.maxPages = 40,
    this.pageTimeLimit = const Duration(minutes: 2),
  })  : _repository = repository,
        _api = api;

  final SyncRepository _repository;
  final ApiClient _api;

  /// The ceiling on one pull.
  ///
  /// Forty pages is twenty thousand rows per table — far beyond a real journal,
  /// and still a pass that ends. A bound exists because "follow `has_more`
  /// forever" is one server bug away from a sync that never returns; the cap is
  /// a visible failure instead of a silent stop (see [SyncPageLimitExceeded]).
  final int maxPages;

  /// The wall-clock twin of [maxPages]: a page that never arrives is a hang,
  /// and a hang is not a sync.
  final Duration pageTimeLimit;

  Future<SyncOutcome> sync({void Function(SyncProgress)? onProgress}) async {
    final payload = await _repository.dirtyPayload();
    final hasLocalChanges = payload.values.any((rows) => rows.isNotEmpty);

    var pushed = 0;
    if (hasLocalChanges) {
      final response = await _api.syncPush(payload);
      await _repository.markClean(response);
      pushed = payload.values.fold<int>(0, (sum, rows) => sum + rows.length);
    }

    var pulled = 0;
    var pages = 0;
    var cursor = await _repository.readCursor();
    // The furthest position the server has actually handed us. The last page of
    // a converged pull reports `cursor: null` (the server only mints one while
    // there is more to read), so the last non-null cursor is the one that
    // resumes after real rows rather than from the top.
    var resumeCursor = cursor;
    final startedAt = DateTime.now();

    while (true) {
      final page = await _api.syncPull(cursor: cursor);
      // Applied before the cursor can move: rows already written are never
      // lost to a later failure, and every merge rule here is idempotent, so a
      // retry that re-reads this page cannot duplicate anything.
      await _repository.applyPull(page);

      pages++;
      pulled += _rowsIn(page);
      final incoming = page['cursor'] as String?;
      if (incoming != null && incoming.isNotEmpty) resumeCursor = incoming;
      final hasMore = page['has_more'] == true;
      onProgress?.call(
        SyncProgress(pages: pages, rows: pulled, hasMore: hasMore),
      );

      if (!hasMore) break;

      if (pages >= maxPages ||
          DateTime.now().difference(startedAt) >= pageTimeLimit) {
        // Nothing is persisted here on purpose. The cursor stays where it was,
        // so the next pass starts at the first row nobody has seen instead of
        // stepping over the pages this one failed to read.
        throw SyncPageLimitExceeded(
          pages: pages,
          rows: pulled,
          limit: maxPages,
        );
      }

      // `has_more` without a cursor cannot be resumed. Ask for the same page
      // again rather than inventing a position; the cap turns a server that
      // never stops into the failure above instead of a spin.
      cursor = incoming ?? cursor;
    }

    await _repository.writeCursor(resumeCursor);

    return SyncOutcome(pushed: pushed, pulled: pulled, pages: pages);
  }

  /// Every table the server can send, counted the same way for the progress
  /// line and for the outcome. Photos and pantry rows are pages too; a count
  /// that skipped them would under-report a restore.
  static int _rowsIn(Map<String, dynamic> pull) {
    var total = 0;
    for (final table in const [
      'dishes',
      'versions',
      'cook_logs',
      'photos',
      'pantry_items',
    ]) {
      total += (pull[table] as List? ?? const []).length;
    }
    return total;
  }
}

/// How far a multi-page pull has got.
///
/// Reported per page so the sync line can say "restoring" with a number behind
/// it instead of a spinner that never ends.
class SyncProgress {
  const SyncProgress({
    required this.pages,
    required this.rows,
    required this.hasMore,
  });

  final int pages;
  final int rows;
  final bool hasMore;

  @override
  String toString() =>
      'SyncProgress(pages: $pages, rows: $rows, hasMore: $hasMore)';
}

/// A pull that did not finish inside [SyncService.maxPages] or
/// [SyncService.pageTimeLimit].
///
/// Deliberately an error rather than an early return: a pull that stops early
/// without saying so is the defect this loop exists to remove, and the
/// controller has to be able to report it and retry.
class SyncPageLimitExceeded implements Exception {
  const SyncPageLimitExceeded({
    required this.pages,
    required this.rows,
    required this.limit,
  });

  final int pages;
  final int rows;
  final int limit;

  @override
  String toString() =>
      'SyncPageLimitExceeded(pages: $pages, rows: $rows, limit: $limit)';
}

class SyncOutcome {
  const SyncOutcome({
    required this.pushed,
    required this.pulled,
    this.pages = 1,
  });

  final int pushed;
  final int pulled;

  /// Pull requests this pass made. More than one means the server paginated.
  final int pages;

  bool get didAnything => pushed > 0 || pulled > 0;

  @override
  String toString() =>
      'SyncOutcome(pushed: $pushed, pulled: $pulled, pages: $pages)';
}
