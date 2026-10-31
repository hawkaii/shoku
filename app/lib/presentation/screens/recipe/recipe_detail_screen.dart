import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/mock_data.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/controls.dart';
import '../../widgets/kit/foundation.dart';

const _ingredients = <String, List<String>>{
  'mousse': ['4 eggs', '3 tbsp cocoa powder', '2 tbsp honey', 'pinch of salt'],
  'chicken': [
    '500 g chicken thigh',
    '3 tbsp cornflour',
    '2 tbsp soy sauce',
    '1 tbsp chilli paste',
    '2 spring onions',
  ],
  'bread': ['500 g flour', '400 ml water', '7 g yeast', '80 ml olive oil', '12 g salt'],
};

class RecipeDetailScreen extends ConsumerWidget {
  final String itemId;
  const RecipeDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final item = ref
        .watch(savedItemsProvider)
        .firstWhere((i) => i.id == itemId, orElse: () => MockData.items.first);
    final ingredients = _ingredients[item.id] ?? const ['See the original reel'];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            ShokuSpace.lg,
            ShokuSpace.sm,
            ShokuSpace.lg,
            ShokuSpace.xxxl,
          ),
          children: [
            Row(
              children: [
                ShokuIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
                ShokuChip(
                  item.sourceLabel,
                  icon: item.source == ItemSource.instagram
                      ? Icons.camera_alt_outlined
                      : Icons.play_circle_outline,
                ),
                const SizedBox(width: ShokuSpace.xs),
                ShokuChip(item.duration),
              ],
            ),
            const SizedBox(height: ShokuSpace.lg),
            Text(item.title, style: ShokuType.display.copyWith(color: c.ink)),
            const SizedBox(height: ShokuSpace.sm),
            Text(item.subtitle, style: ShokuType.body.copyWith(color: c.inkMuted)),
            const SizedBox(height: ShokuSpace.md),

            // ---- Meta strip ---------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(vertical: ShokuSpace.md),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: c.hairline, width: ShokuStroke.hairline),
                  bottom: BorderSide(color: c.hairline, width: ShokuStroke.hairline),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: ShokuStat('25m', label: 'total')),
                  Container(width: 1, height: 26, color: c.hairline),
                  Expanded(child: ShokuStat('4', label: 'servings')),
                  Container(width: 1, height: 26, color: c.hairline),
                  Expanded(
                    child: ShokuStat(
                      '${item.pantryHave}/${item.pantryNeed}',
                      label: 'pantry',
                      color: item.pantryHave >= item.pantryNeed ? c.ready : c.ink,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ShokuSpace.lg),
            ShokuLabel('ingredients'),
            const SizedBox(height: ShokuSpace.sm),
            for (final ingredient in ingredients)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: c.hairline, width: ShokuStroke.hairline),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(right: ShokuSpace.md),
                      decoration: BoxDecoration(
                        color: c.ready,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: ShokuType.body.copyWith(color: c.ink),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: ShokuSpace.xl),
            ShokuLabel('method'),
            const SizedBox(height: ShokuSpace.sm),
            for (var i = 0; i < item.body.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: ShokuSpace.lg),
                child: _Step(number: i + 1, text: item.body[i]),
              ),

            const SizedBox(height: ShokuSpace.sm),
            ShokuButton(
              'Start cooking',
              icon: Icons.play_arrow,
              onPressed: () {},
            ),
            const SizedBox(height: ShokuSpace.md),
            Center(
              child: Text(
                'Timers run inline — tap any time in a step.',
                style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A step with inline monospace pills for quantities and durations.
/// Tapping a duration starts a local countdown.
class _Step extends StatefulWidget {
  final int number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  State<_Step> createState() => _StepState();
}

class _StepState extends State<_Step> {
  static final _pattern = RegExp(
    r'(\d+\s?(?:minutes|minute|min|mins|hours|hour|h|g|kg|ml|°C))',
    caseSensitive: false,
  );

  int? _remaining;
  Timer? _timer;

  bool _isDuration(String token) {
    final t = token.toLowerCase();
    return t.contains('min') || t.contains('hour') || t.endsWith('h');
  }

  void _start(String token) {
    final match = RegExp(r'\d+').firstMatch(token);
    final amount = int.tryParse(match?.group(0) ?? '') ?? 1;
    final minutes = token.toLowerCase().contains('hour') || token.toLowerCase().endsWith('h')
        ? amount * 60
        : amount;

    _timer?.cancel();
    setState(() => _remaining = minutes * 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if ((_remaining ?? 0) <= 1) {
          timer.cancel();
          _remaining = 0;
        } else {
          _remaining = (_remaining ?? 1) - 1;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _clock {
    final seconds = _remaining ?? 0;
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in _pattern.allMatches(widget.text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: widget.text.substring(cursor, match.start)));
      }
      final token = match.group(0)!;
      final duration = _isDuration(token);
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: duration ? () => _start(token) : null,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: duration ? c.accent.withValues(alpha: 0.10) : c.surfaceAlt,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(
                  color: duration ? c.accent.withValues(alpha: 0.4) : c.hairline,
                ),
              ),
              child: Text(
                token,
                style: ShokuType.stat.copyWith(
                  fontSize: 12,
                  color: duration ? c.accent : c.ink,
                ),
              ),
            ),
          ),
        ),
      );
      cursor = match.end;
    }
    if (cursor < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(cursor)));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Text(
            widget.number.toString().padLeft(2, '0'),
            style: ShokuType.stat.copyWith(fontSize: 12, color: c.inkMuted),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: ShokuType.body.copyWith(color: c.ink),
                  children: spans,
                ),
              ),
              if (_remaining != null)
                Padding(
                  padding: const EdgeInsets.only(top: ShokuSpace.sm),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.accent,
                          borderRadius: BorderRadius.circular(ShokuRadius.chip),
                          border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                          boxShadow: [
                            BoxShadow(
                              color: c.ink,
                              offset: ShokuStroke.brutalShadow,
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          _clock,
                          style: ShokuType.stat.copyWith(
                            fontSize: 12,
                            color: context.isDark ? const Color(0xFF1A0D09) : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: ShokuSpace.sm),
                      GestureDetector(
                        onTap: () {
                          _timer?.cancel();
                          setState(() => _remaining = null);
                        },
                        child: Text(
                          'stop',
                          style: ShokuType.label.copyWith(color: c.inkMuted),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
