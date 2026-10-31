import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
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

    if (state.isIdle) return const SizedBox.shrink();

    // A settled failure is one quiet line, not a red card.
    if (state.failure != null) {
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
                  state.failure!,
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

    final detail = state.detail;
    final progress = state.progress;
    final waking = progress?.detail == 'starting';

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
                    state.headline,
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
                      progress!.waitingHint ?? '',
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
