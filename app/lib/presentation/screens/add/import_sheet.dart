import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/import_service.dart';
import '../../../data/services/pending_import.dart';
import '../../state/import_providers.dart';
import '../../state/import_tracker.dart';
import '../../state/journal_store.dart';
import '../../widgets/kit/motion.dart';
import '../journal/import_card.dart';

/// Import one link, with the wait made visible.
///
/// The stages are real: they come from the worker through `/v1/imports/{id}`,
/// not from a timer pretending to make progress.
///
/// The import belongs to the server, so this sheet is only a view of it. What is
/// in flight is written down on the phone (see [PendingImportStore]); closing the
/// sheet, or the app dying, leaves the job running and the next open picks it up
/// instead of starting a second one.
Future<void> showImportSheet(BuildContext context, {String? prefill}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (_) => ImportSheet(prefill: prefill),
  );
}

class ImportSheet extends ConsumerStatefulWidget {
  final String? prefill;

  /// How long a job may run before the sheet stops calling it "Reading the
  /// reel" and says, plainly, that it is still working.
  final Duration slowAfter;

  /// The window passed to [ImportService.watch]. Null uses the service default.
  final int? watchSeconds;

  const ImportSheet({
    super.key,
    this.prefill,
    this.slowAfter = const Duration(seconds: 60),
    this.watchSeconds,
  });

  @override
  ConsumerState<ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends ConsumerState<ImportSheet> {
  late final TextEditingController _url =
      TextEditingController(text: widget.prefill ?? '');
  ImportProgress? _progress;
  bool _busy = false;
  String? _error;

  /// Shown instead of an error when the window runs out: the job is still on the
  /// server, so nothing has failed.
  String? _stillReading;
  bool _slow = false;
  Timer? _slowTimer;
  StreamSubscription<ImportProgress>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if ((widget.prefill ?? '').isNotEmpty) {
        _start();
      } else {
        _resume();
      }
    });
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    _sub?.cancel();
    _url.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_busy) return;
    final url = _url.text.trim();
    if (url.length < 8) {
      setState(() => _error = context.l10n.importPasteFirst);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _progress = null;
      _stillReading = null;
      _slow = false;
    });
    await _sub?.cancel();
    _slowTimer?.cancel();
    final service = ref.read(importServiceProvider);
    final pendingStore = ref.read(pendingImportStoreProvider);

    try {
      final started = await service.start(url);

      // A cached reel comes back ready with no job at all: there is nothing to
      // wait for, so this is a finish, not an error.
      if (started.stage == ImportStage.ready) {
        if (started.shortcode.isEmpty) {
          setState(() {
            _busy = false;
            _error = context.l10n.importNoLink;
          });
          return;
        }
        await pendingStore.write(PendingImport(
          url: url,
          shortcode: started.shortcode,
          startedAt: DateTime.now(),
        ));
        await _finish(service, started.shortcode);
        return;
      }

      if (started.stage == ImportStage.failed) {
        if (!mounted) return;
        await _abandon(reasonText(context.l10n, started.reason));
        return;
      }

      if (started.jobId == null) {
        setState(() {
          _busy = false;
          _error = context.l10n.importCouldNotStart;
        });
        return;
      }

      // Written before the first poll, so a kill in the next second still
      // leaves something to come back to.
      final pending = PendingImport(
        url: url,
        shortcode: started.shortcode,
        jobId: started.jobId,
        startedAt: DateTime.now(),
      );
      await pendingStore.write(pending);
      // The Journal shows it too, from the same record, once the sheet closes.
      await ref.read(importTrackerProvider.notifier).adopt(pending);
      _watch(service, started.jobId!, started.shortcode);
    } on ApiUnauthenticated {
      setState(() {
        _busy = false;
        _error = context.l10n.importSignIn;
      });
    } on ApiError catch (error) {
      setState(() {
        _busy = false;
        _error = reasonText(context.l10n, error.reason);
      });
    } catch (error) {
      setState(() {
        _busy = false;
        _error = context.l10n.importUnreachable;
      });
    }
  }

  void _watch(ImportService service, String jobId, String shortcode) {
    _sub?.cancel();
    _slowTimer?.cancel();
    _slow = false;
    // A long reel is normal, not broken: after a minute, say so.
    _slowTimer = Timer(widget.slowAfter, () {
      if (mounted) setState(() => _slow = true);
    });

    _sub = service.watch(jobId, seconds: widget.watchSeconds).listen(
      (progress) {
        if (!mounted) return;
        setState(() {
          _progress = progress;
          _stillReading = null;
        });
        switch (progress.stage) {
          case ImportStage.ready:
            _slowTimer?.cancel();
            _finish(
              service,
              progress.shortcode.isNotEmpty ? progress.shortcode : shortcode,
            );
          case ImportStage.failed:
            if (progress.reason == 'timed_out') {
              // We stopped waiting; the worker did not. Nothing has failed: the
              // note stays, and the copy says it can be left.
              _slowTimer?.cancel();
              setState(() {
                _busy = false;
                _stillReading = reasonText(context.l10n, progress.reason);
              });
            } else {
              _slowTimer?.cancel();
              _abandon(reasonText(context.l10n, progress.reason));
            }
          case ImportStage.queued:
          case ImportStage.extracting:
            break;
        }
      },
      onError: (Object error) {
        if (!mounted) return;
        if (error is ApiUnauthenticated) {
          _abandon(context.l10n.importSignIn);
          return;
        }
        // The retries are spent, but the job is still the server's: the note
        // stays, and the next open resumes it rather than starting over.
        setState(() {
          _busy = false;
          _error = context.l10n.importLostConnection;
        });
      },
    );
  }

  /// Picks up an import that outlived the last opening of this sheet.
  Future<void> _resume() async {
    final pending = await ref.read(pendingImportStoreProvider).read();
    if (pending == null || !mounted) return;

    setState(() {
      _busy = true;
      _error = null;
      _stillReading = null;
      _slow = false;
      _url.text = pending.url;
    });
    final service = ref.read(importServiceProvider);

    final jobId = pending.jobId;
    if (jobId != null) {
      try {
        final progress = await service.pollOnce(jobId);
        if (!mounted) return;
        setState(() => _progress = progress);
        if (progress.stage == ImportStage.ready) {
          await _finish(
            service,
            progress.shortcode.isNotEmpty ? progress.shortcode : pending.shortcode,
          );
          return;
        }
        if (progress.stage == ImportStage.failed) {
          await _abandon(reasonText(context.l10n, progress.reason));
          return;
        }
        _watch(service, jobId, pending.shortcode);
        return;
      } on ApiUnauthenticated {
        setState(() {
          _busy = false;
          _error = context.l10n.importSignIn;
        });
        return;
      } on ApiError catch (error) {
        if (error.status == 404) {
          // The server has forgotten the job; there is nothing left to resume.
          await _abandon(reasonText(context.l10n, 'gone'));
          return;
        }
        setState(() {
          _busy = false;
          _error = context.l10n.importOpenAgain;
        });
        return;
      } catch (_) {
        setState(() {
          _busy = false;
          _error = context.l10n.importStillOnServer;
        });
        return;
      }
    }

    // No job: the parse was already cached when the app went away, so the
    // shortcode is the only handle left. The content endpoint is the short way
    // back — never a second import of the same reel.
    try {
      final dish = await service.createDish(pending.shortcode);
      await ref.read(pendingImportStoreProvider).clear();
      await ref.read(journalStoreProvider.notifier).refresh();
      if (!mounted) return;
      if (dish == null) {
        setState(() {
          _busy = false;
          _progress = null;
          _error = context.l10n.importGone;
        });
        return;
      }
      Navigator.of(context).pop();
      _requestSync();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.importSaved(dish.title))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = context.l10n.importOpenAgain;
      });
    }
  }

  Future<void> _finish(ImportService service, String shortcode) async {
    try {
      final dish = await service.createDish(shortcode);
      await ref.read(pendingImportStoreProvider).clear();
      await ref.read(journalStoreProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.of(context).pop();
      _requestSync();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(dish == null
                ? context.l10n.importNothingToSave
                : context.l10n.importSaved(dish.title))),
      );
    } catch (_) {
      // Keep the note: the parse exists, only the save failed.
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = context.l10n.importCouldNotSave;
      });
    }
  }

  Future<void> _abandon(String message) async {
    await ref.read(pendingImportStoreProvider).clear();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
    });
  }

  /// The import changed the journal, so the sync layer gets its usual nudge.
  void _requestSync() {
    unawaited(ref.read(syncHookProvider)?.call() ?? Future<void>.value());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final showProgress = _progress != null &&
        _busy &&
        _progress!.stage != ImportStage.failed;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ShokuSpace.lg,
        ShokuSpace.lg,
        ShokuSpace.lg,
        MediaQuery.of(context).viewInsets.bottom + ShokuSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.importSheetTitle, style: ShokuType.h2.copyWith(color: c.ink)),
          const SizedBox(height: 2),
          Text(
            l10n.importSheetBody,
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(ShokuRadius.chip),
              border: Border.all(color: c.hairline),
            ),
            child: TextField(
              controller: _url,
              enabled: !_busy,
              keyboardType: TextInputType.url,
              style: ShokuType.body.copyWith(color: c.ink),
              decoration: InputDecoration(
                hintText: 'https://…',
                hintStyle: ShokuType.body.copyWith(color: c.inkMuted),
                border: InputBorder.none,
              ),
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: ShokuSpace.md),
            Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.6, color: c.accent),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _slow
                        ? l10n.importStillWorking
                        : stageText(l10n, _progress) ?? '',
                    key: const ValueKey('import-stage'),
                    style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _slow
                  ? l10n.importLongWait
                  : (_progress!.detail == 'starting'
                      ? l10n.importWaitingHint
                      : l10n.importCloseWait),
              key: const ValueKey('import-hint'),
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
            ),
          ],
          if (_stillReading != null) ...[
            const SizedBox(height: ShokuSpace.sm),
            // Not an error: the job is still on the server and the next open
            // picks it up. Muted, because nothing has gone wrong.
            Text(
              _stillReading!,
              key: const ValueKey('import-still-reading'),
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: ShokuSpace.sm),
            Text(_error!, style: ShokuType.bodySmall.copyWith(color: c.danger)),
          ],
          const SizedBox(height: ShokuSpace.lg),
          ShokuPressable(
            onTap: _busy ? null : _start,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: _busy ? null : ShokuGradients.crimsonPress,
                color: _busy ? c.surfaceAlt : null,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.ink, width: ShokuStroke.brutal),
              ),
              child: Center(
                child: Text(
                  _busy ? l10n.importReading : l10n.importReadLink,
                  style: ShokuType.title.copyWith(color: c.onAccent, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
