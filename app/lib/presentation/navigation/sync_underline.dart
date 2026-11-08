import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/shoku_theme.dart';
import '../state/sync_providers.dart';

/// The active tab's underline doubles as the only sync signal in the app.
///
/// The rule is that it speaks only when it has news: a 2 px ink line that
/// travels while a pass is running, a still hairline when the last pass failed,
/// and nothing about sync at all when signed out — that story belongs to the
/// claim prompt, not to the navigation.
class SyncUnderline extends ConsumerWidget {
  const SyncUnderline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final c = context.colors;

    return SizedBox(
      height: 4,
      width: 24,
      child: Center(
        child: switch (status) {
          SyncStatus.syncing => _TravellingLine(color: c.ink),
          SyncStatus.offline || SyncStatus.failed => Container(
              key: const ValueKey('sync-line-unsynced'),
              width: 14,
              height: 2,
              decoration: BoxDecoration(
                color: c.ink.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          // Idle and signed-out both fall back to the ordinary "you are here"
          // marker: one says nothing is wrong, the other says nothing is ours.
          SyncStatus.idle || SyncStatus.signedOut => Container(
              key: const ValueKey('tab-marker'),
              width: 14,
              height: 3,
              decoration: BoxDecoration(
                color: c.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        },
      ),
    );
  }
}

/// A short ink line that runs end to end while a sync is in flight.
class _TravellingLine extends StatefulWidget {
  const _TravellingLine({required this.color});

  final Color color;

  @override
  State<_TravellingLine> createState() => _TravellingLineState();
}

class _TravellingLineState extends State<_TravellingLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        return SizedBox(
          key: const ValueKey('sync-line-travelling'),
          width: 10 + (14 * t),
          height: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.35 + (0.65 * t)),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      },
    );
  }
}
