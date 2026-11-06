import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/import_service.dart';
import '../../core/utils/failure_log.dart';
import '../../data/services/pending_import.dart';
import 'import_providers.dart';
import 'journal_store.dart';

/// An import that is in flight, as the rest of the app can see it.
///
/// The sheet is only a view of a job that lives on the server, so the record on
/// the phone is the truth about whether anything is running. This watches it:
/// one poller, alive as long as the Journal is, so a 60-second cold boot is
/// visible instead of looking like a freeze.
class ImportTrackerState {
  const ImportTrackerState({
    this.pending,
    this.title,
    this.progress,
    this.reason,
  });

  /// The import in flight, or null when there is nothing running.
  final PendingImport? pending;

  /// The reel's own name, once the server knows it. Null until then — the app
  /// never invents one from the URL.
  final String? title;

  final ImportProgress? progress;

  /// The API's failure code, kept as a code until a widget can give it words in
  /// the reader's language. Never server prose.
  final String? reason;

  bool get isRunning => pending != null;
  bool get isIdle => pending == null && reason == null;

  /// What the card says first: the reel's name, else its stage, else the fact
  /// that something is being imported. The stage's words live in the widget, so
  /// this getter only answers "is there a name".
  String get headline {
    final name = title?.trim();
    if (name != null && name.isNotEmpty) return name;
    return '';
  }

  ImportTrackerState copyWith({
    PendingImport? pending,
    String? title,
    ImportProgress? progress,
    String? reason,
    bool clearPending = false,
    bool clearReason = false,
  }) =>
      ImportTrackerState(
        pending: clearPending ? null : (pending ?? this.pending),
        title: title ?? this.title,
        progress: progress ?? this.progress,
        reason: clearReason ? null : (reason ?? this.reason),
      );
}

class ImportTracker extends StateNotifier<ImportTrackerState> {
  ImportTracker({
    required ImportService service,
    required PendingImportStore store,
    required Future<void> Function() onDishWritten,
  })  : _service = service,
        _store = store,
        _onDishWritten = onDishWritten,
        super(const ImportTrackerState());

  final ImportService _service;
  final PendingImportStore _store;
  final Future<void> Function() _onDishWritten;

  /// How often the card refreshes itself. Cheap: one GET per tick, and only
  /// while something is actually running.
  static const pollInterval = Duration(seconds: 4);

  Timer? _timer;
  bool _polling = false;
  bool _disposed = false;

  /// Picks up an import that outlived the last opening of the app.
  Future<void> restore() async {
    try {
      final pending = await _store.read();
      if (pending == null || _disposed) return;
      _adopt(pending);
    } catch (error, stack) {
      // No store, no tracker — the app still cooks, but the note it could not
      // read is why an import sometimes has to be started again.
      logFailure('import: restoring the pending note failed', error, stack);
    }
  }

  /// A new import started in the sheet.
  Future<void> adopt(PendingImport pending) async {
    if (pending.jobId == null) return;
    _adopt(pending);
  }

  void _adopt(PendingImport pending) {
    if (pending.jobId == null) return;
    state = ImportTrackerState(
      pending: pending,
      title: state.pending?.jobId == pending.jobId ? state.title : null,
      progress: state.pending?.jobId == pending.jobId ? state.progress : null,
      reason: null,
    );
    _timer?.cancel();
    // Look once immediately, so the card has a stage to show within a second.
    unawaited(_poll());
  }

  Future<void> _poll() async {
    if (_disposed || _polling) return;
    final pending = state.pending;
    if (pending?.jobId == null) return;

    _polling = true;
    try {
      final progress = await _service.pollOnce(pending!.jobId!);
      if (_disposed) return;
      state = state.copyWith(progress: progress, title: progress.title);

      if (progress.stage == ImportStage.ready) {
        await _finish(pending);
        return;
      }
      if (progress.stage == ImportStage.failed) {
        await _store.clear();
        state = ImportTrackerState(
          reason: progress.reason ?? 'unknown',
        );
        return; // a failure is not polled again
      }
    } catch (error, stack) {
      // A dropped poll is not a failed import; the next tick tries again.
      logFailure('import: polling the job failed', error, stack);
    } finally {
      _polling = false;
    }

    if (_disposed) return;
    // If something else finished it (the open sheet, say), stand down.
    if (await _store.read() == null) {
      if (!_disposed) state = const ImportTrackerState();
      return;
    }
    if (_disposed) return;
    _timer = Timer(pollInterval, _poll);
  }

  Future<void> _finish(PendingImport pending) async {
    try {
      await _service.createDish(pending.shortcode);
      // createDish is idempotent by shortcode, so the sheet finishing first
      // cannot produce a second dish.
      await _onDishWritten();
    } catch (error, stack) {
      // Leave it running: the next tick tries again rather than losing it.
      logFailure('import: the tracker could not save the dish', error, stack);
      if (!_disposed) _timer = Timer(pollInterval, _poll);
      return;
    }
    await _store.clear();
    if (!_disposed) state = const ImportTrackerState();
  }

  /// Takes a settled failure off the screen. Nothing else is forgotten: the
  /// server still has the reel, and the import can be started again.
  void dismiss() {
    state = const ImportTrackerState();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}

final importTrackerProvider =
    StateNotifierProvider<ImportTracker, ImportTrackerState>((ref) {
  final tracker = ImportTracker(
    service: ref.watch(importServiceProvider),
    store: ref.watch(pendingImportStoreProvider),
    onDishWritten: () => ref.read(journalStoreProvider.notifier).refresh(),
  );
  // Riverpod disposes the notifier itself; its dispose() cancels the poller.
  tracker.restore();
  return tracker;
});
