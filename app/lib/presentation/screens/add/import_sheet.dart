import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/import_service.dart';
import '../../state/journal_store.dart';
import '../../state/sync_providers.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';

/// Import one link, with the wait made visible.
///
/// The stages are real: they come from the worker through `/v1/imports/{id}`,
/// not from a timer pretending to make progress.
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
    if ((widget.prefill ?? '').isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    }
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

    try {
      final service = ImportService(
        api: ApiClient(),
        repository: ref.read(journalRepositoryProvider),
      );
      final started = await service.start(url);

      if (started.stage == ImportStage.ready) {
        await _finish(service, started.shortcode);
        return;
      }
      if (started.jobId == null) {
        setState(() {
          _busy = false;
          _error = 'We could not start that import';
        });
        return;
      }

      _sub = service.watch(started.jobId!).listen(
        (progress) {
          if (!mounted) return;
          setState(() => _progress = progress);
          if (progress.stage == ImportStage.ready) {
            _finish(service, progress.shortcode);
          } else if (progress.stage == ImportStage.failed) {
            setState(() {
              _busy = false;
              _error = _reasonText(progress.reason);
            });
          }
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _busy = false;
            _error = error is ApiUnauthenticated
                ? 'Sign in from You to import'
                : 'Could not reach the server';
          });
        },
      );
    } on ApiUnauthenticated {
      setState(() {
        _busy = false;
        _error = 'Sign in from You to import';
      });
    } on ApiError catch (error) {
      setState(() {
        _busy = false;
        _error = _reasonText(error.reason);
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

  Future<void> _finish(ImportService service, String shortcode) async {
    try {
      final dish = await service.createDish(shortcode);
      await ref.read(journalStoreProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(syncControllerProvider).syncNow();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dish == null ? 'Nothing to save' : 'Saved ${dish.title}')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'The recipe came back but could not be saved';
      });
    }
  }

  static String _reasonText(String? reason) => switch (reason) {
        'unsupported_url' => 'That link is not a reel or video we can read',
        'source_blocked' =>
          'YouTube is blocking our server right now — try again later or paste the recipe',
        'timeout' => 'That took too long — try again',
        'invalid_recipe' => 'We could not find a recipe in that one',
        'no_audio' => 'That video has nothing to listen to',
        'taken_down' => 'That recipe was removed',
        null => 'Could not read this one — paste the recipe instead',
        _ => 'Could not read this one — paste the recipe instead',
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
          if (_progress != null) ...[
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
