import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/import_service.dart';
import '../../../data/services/pending_import.dart';
import '../../state/import_providers.dart';
import '../../state/journal_store.dart';
import '../../widgets/kit/motion.dart';

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
  const ImportSheet({super.key, this.prefill});

  @override
  ConsumerState<ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends ConsumerState<ImportSheet> {
  late final TextEditingController _url =
      TextEditingController(text: widget.prefill ?? '');
  ImportProgress? _progress;
  bool _busy = false;
  String? _error;
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
    _sub?.cancel();
    _url.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_busy) return;
    final url = _url.text.trim();
    if (url.length < 8) {
      setState(() => _error = 'Paste a link first');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _progress = null;
    });
    await _sub?.cancel();
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
            _error = 'The reel is ready but the server sent no link for it';
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
        await _abandon(importReasonText(started.reason));
        return;
      }

      if (started.jobId == null) {
        setState(() {
          _busy = false;
          _error = 'We could not start that import';
        });
        return;
      }

      // Written before the first poll, so a kill in the next second still
      // leaves something to come back to.
      await pendingStore.write(PendingImport(
        url: url,
        shortcode: started.shortcode,
        jobId: started.jobId,
        startedAt: DateTime.now(),
      ));
      _watch(service, started.jobId!, started.shortcode);
    } on ApiUnauthenticated {
      setState(() {
        _busy = false;
        _error = 'Sign in from You to import';
      });
    } on ApiError catch (error) {
      setState(() {
        _busy = false;
        _error = importReasonText(error.reason);
      });
    } catch (error) {
      setState(() {
        _busy = false;
        _error = kDebugMode
            ? 'Could not reach the server ($error)'
            : 'Could not reach the server';
      });
    }
  }

  void _watch(ImportService service, String jobId, String shortcode) {
    _sub?.cancel();
    _sub = service.watch(jobId).listen(
      (progress) {
        if (!mounted) return;
        setState(() => _progress = progress);
        switch (progress.stage) {
          case ImportStage.ready:
            _finish(
              service,
              progress.shortcode.isNotEmpty ? progress.shortcode : shortcode,
            );
          case ImportStage.failed:
            if (progress.reason == 'timed_out') {
              // We stopped waiting; the worker did not. Keep the note so the
              // next open picks the finished parse up instead of re-importing.
              setState(() {
                _busy = false;
                _error = importReasonText(progress.reason);
              });
            } else {
              _abandon(importReasonText(progress.reason));
            }
          case ImportStage.queued:
          case ImportStage.extracting:
            break;
        }
      },
      onError: (Object error) {
        if (!mounted) return;
        if (error is ApiUnauthenticated) {
          _abandon('Sign in from You to import');
          return;
        }
        // The retries are spent, but the job is still the server's: the note
        // stays, and the next open resumes it rather than starting over.
        setState(() {
          _busy = false;
          _error =
              'Lost the connection — the reel is still being read. Open this again to pick it up';
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
          await _abandon(importReasonText(progress.reason));
          return;
        }
        _watch(service, jobId, pending.shortcode);
        return;
      } on ApiUnauthenticated {
        setState(() {
          _busy = false;
          _error = 'Sign in from You to import';
        });
        return;
      } on ApiError catch (error) {
        if (error.status == 404) {
          // The server has forgotten the job; there is nothing left to resume.
          await _abandon(importReasonText('gone'));
          return;
        }
        setState(() {
          _busy = false;
          _error = 'Could not check on that import — open this again in a minute';
        });
        return;
      } catch (_) {
        setState(() {
          _busy = false;
          _error =
              'Could not reach the server — the reel is still on it. Open this again to pick it up';
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
          _error = 'That reel is no longer on the server — try the link again';
        });
        return;
      }
      Navigator.of(context).pop();
      _requestSync();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved ${dish.title}')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not reach the server — open this again in a minute';
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
        SnackBar(content: Text(dish == null ? 'Nothing to save' : 'Saved ${dish.title}')),
      );
    } catch (_) {
      // Keep the note: the parse exists, only the save failed.
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'The recipe came back but could not be saved — open this again';
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
          Text('Save a reel', style: ShokuType.h2.copyWith(color: c.ink)),
          const SizedBox(height: 2),
          Text(
            'Paste a YouTube or Instagram link. It becomes a dish you can cook, with the creator attached.',
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
                Text(_progress!.label,
                    style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
              ],
            ),
            const SizedBox(height: 4),
            Text('You can close this — the dish appears when it is ready.',
                style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
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
                  _busy ? 'Reading…' : 'Read this link',
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
