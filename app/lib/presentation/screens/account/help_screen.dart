import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/foundation.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final topics = ref.watch(helpTopicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Help & feedback', style: ShokuType.h1.copyWith(color: c.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ShokuSpace.lg,
          ShokuSpace.sm,
          ShokuSpace.lg,
          ShokuSpace.xxl,
        ),
        children: [
          Text(
            'Short answers to the things people ask first.',
            style: ShokuType.body.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.lg),
          for (final topic in topics) ...[
            _FaqTile(question: topic['q']!, answer: topic['a']!),
            const SizedBox(height: ShokuSpace.sm),
          ],
          const SizedBox(height: ShokuSpace.lg),
          ShokuSurface(
            color: c.surfaceAlt,
            padding: const EdgeInsets.all(ShokuSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShokuLabel('still stuck'),
                const SizedBox(height: ShokuSpace.xs),
                Text(
                  'Send the reel link and what you expected. It makes the fix much faster.',
                  style: ShokuType.bodySmall.copyWith(color: c.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: ShokuSurface(
        padding: const EdgeInsets.all(ShokuSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: Icon(Icons.expand_more, size: 18, color: c.inkMuted),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 160),
              crossFadeState: _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: ShokuSpace.sm),
                child: Text(
                  widget.answer,
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
