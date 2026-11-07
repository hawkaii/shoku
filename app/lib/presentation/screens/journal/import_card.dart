import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../data/services/import_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../state/import_tracker.dart';

/// A running import, at the top of the Journal.
///
/// It answers one question — is the thing I started actually working? — without
/// the sheet, and without a dialog. It sits above the scroll view so it cannot
/// scroll away, and it disappears the moment the dish lands.
class JournalImportCard extends ConsumerWidget {
  const JournalImportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importTrackerProvider);
    final c = context.colors;
    final l10n = context.l10n;

    if (state.isIdle) return const SizedBox.shrink();

    // A settled failure is one quiet line, not a red card.
    if (state.reason != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          ShokuSpace.lg,
          ShokuSpace.sm,
          ShokuSpace.lg,
          0,
        ),
        child: Container(
          key: const ValueKey('import-card-failed'),
          padding: const EdgeInsets.symmetric(
            horizontal: ShokuSpace.md,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(ShokuRadius.card),
            border: Border.all(color: c.hairline),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 15, color: c.inkMuted),
              const SizedBox(width: ShokuSpace.sm),
              Expanded(
                child: Text(
                  reasonText(l10n, state.reason),
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(importTrackerProvider.notifier).dismiss(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: ShokuSpace.sm),
                  child: Icon(Icons.close, size: 15, color: c.inkMuted),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final progress = state.progress;
    final waking = progress?.detail == 'starting';
    final stage = stageText(l10n, progress);
    final hasName = state.title?.trim().isNotEmpty == true;
    final headline =
        hasName ? state.title!.trim() : stage ?? l10n.importHeadline;
    final detail = hasName ? stage : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShokuSpace.lg,
        ShokuSpace.sm,
        ShokuSpace.lg,
        0,
      ),
      child: Container(
        key: const ValueKey('import-card'),
        padding: const EdgeInsets.all(ShokuSpace.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(ShokuRadius.card),
          border: Border.all(color: c.hairline),
        ),
        child: Row(
          children: [
            // A live mark, so the card reads as working rather than frozen.
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: waking ? c.reward : c.accent,
              ),
            ),
            const SizedBox(width: ShokuSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    key: const ValueKey('import-card-headline'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      key: const ValueKey('import-card-stage'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                    ),
                  ] else if (waking) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n.importWaitingHint,
                      key: const ValueKey('import-card-stage'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The stage's words, chosen here rather than in the tracker: the tracker keeps
/// the server's code and the screen gives it the reader's language.
String? stageText(AppLocalizations l10n, ImportProgress? progress) {
  if (progress == null) return null;
  if (progress.detail == 'starting') return l10n.importWaking;
  return switch (progress.stage) {
    ImportStage.queued => l10n.importQueued,
    ImportStage.extracting => switch (progress.detail) {
        'transcribing' => l10n.importReadingAudio,
        'structuring' => l10n.importWritingRecipe,
        'watching' => l10n.importWatchingVideo,
        'caption_only' => l10n.importReadingCaption,
        _ => l10n.importReadingReel,
      },
    ImportStage.ready => l10n.importReady,
    ImportStage.failed => l10n.importFailedShort,
  };
}

/// One reason code, one sentence. A code we have never seen gets the generic
/// line rather than printing whatever prose the server sent.
String reasonText(AppLocalizations l10n, String? reason) => switch (reason) {
      'unsupported_url' => l10n.reasonUnsupportedUrl,
      'source_blocked' => l10n.reasonSourceBlocked,
      'timeout' => l10n.reasonTimeout,
      'worker_unavailable' => l10n.reasonWorkerUnavailable,
      'timed_out' => l10n.reasonTimedOut,
      'gone' => l10n.reasonGone,
      'invalid_recipe' => l10n.reasonInvalidRecipe,
      'no_audio' => l10n.reasonNoAudio,
      'no_text' => l10n.reasonNoText,
      'no_recipe' => l10n.reasonNoRecipe,
      'vision_failed' => l10n.reasonVisionFailed,
      'taken_down' => l10n.reasonTakenDown,
      _ => l10n.reasonUnknown,
    };
