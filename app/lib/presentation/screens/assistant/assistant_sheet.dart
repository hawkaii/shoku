import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/mic_field.dart';

Future<void> showAssistantSheet(
  BuildContext context, {
  required Dish dish,
  VoidCallback? onLogChange,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (_) => AssistantSheet(dish: dish, onLogChange: onLogChange),
  );
}

class _Turn {
  final String text;
  final bool mine;
  const _Turn(this.text, {this.mine = false});
}

/// Answers only. Nothing here can mutate a recipe — that is the whole point of
/// separating advice from cooking.
class AssistantSheet extends ConsumerStatefulWidget {
  final Dish dish;
  final VoidCallback? onLogChange;
  const AssistantSheet({super.key, required this.dish, this.onLogChange});

  @override
  ConsumerState<AssistantSheet> createState() => _AssistantSheetState();
}

class _AssistantSheetState extends ConsumerState<AssistantSheet> {
  final _input = TextEditingController();
  final _turns = <_Turn>[
    const _Turn(
      'Ask me anything about tonight’s cook — substitutions, measurements, doneness. I answer, I don’t edit your recipe.',
    ),
  ];

  static const _suggestions = [
    'No measuring cup — how much is 2 tbsp?',
    'No honey, what works instead?',
    'How do I know the whites are whipped enough?',
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send(String text) {
    final question = text.trim();
    if (question.isEmpty) return;
    setState(() {
      _turns.add(_Turn(question, mine: true));
      _turns.add(_Turn(_answer(question)));
      _input.clear();
    });
  }

  String _answer(String q) {
    final lower = q.toLowerCase();
    if (lower.contains('tbsp') || lower.contains('measuring') || lower.contains('cup')) {
      return '1 tbsp ≈ 15 ml, 1 tsp ≈ 5 ml. A standard mug holds about 240 ml, so 2 tbsp of cocoa is roughly one heaped dessert spoon — about 12 g.';
    }
    if (lower.contains('honey') || lower.contains('substitut')) {
      return 'For ${widget.dish.title}: swap honey 1:1 for maple syrup, or use 3/4 the amount of sugar and add a splash of water. If you have neither, a ripe banana mashed in adds sweetness and body.';
    }
    if (lower.contains('whipped') || lower.contains('whites') || lower.contains('peak')) {
      return 'Lift the whisk: soft peaks droop over and disappear, stiff peaks stand. For a mousse you want soft — if it looks like shaving foam you have gone too far, fold gently and it will still set.';
    }
    if (lower.contains('doneness') || lower.contains('how long')) {
      return 'Go by sound and touch over the clock: the pan should hiss when the food goes in, then quieten. For this dish, pull it 30 seconds before it looks done — it keeps cooking off the heat.';
    }
    return 'For ${widget.dish.title}, I’d keep the method and change one variable at a time. Tell me what you have in the kitchen and I’ll suggest the closest swap.';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(
        left: ShokuSpace.lg,
        right: ShokuSpace.lg,
        top: ShokuSpace.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + ShokuSpace.lg,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.62,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: ShokuSpace.md),
                decoration: BoxDecoration(
                  color: c.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: c.accent),
                const SizedBox(width: ShokuSpace.sm),
                Text('Ask about this cook', style: ShokuType.h2.copyWith(color: c.ink)),
                const Spacer(),
                ShokuChip('answers only', icon: Icons.lock_outline),
              ],
            ),
            const SizedBox(height: ShokuSpace.md),
            Expanded(
              child: ListView.separated(
                itemCount: _turns.length,
                separatorBuilder: (_, __) => const SizedBox(height: ShokuSpace.sm),
                itemBuilder: (context, i) {
                  final turn = _turns[i];
                  return Align(
                    alignment: turn.mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78,
                      ),
                      padding: const EdgeInsets.all(ShokuSpace.md),
                      decoration: BoxDecoration(
                        color: turn.mine ? c.ink : c.surface,
                        borderRadius: BorderRadius.circular(ShokuRadius.card),
                        border: Border.all(color: turn.mine ? c.ink : c.hairline),
                      ),
                      child: Text(
                        turn.text,
                        style: ShokuType.bodySmall.copyWith(
                          color: turn.mine ? c.canvas : c.ink,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: ShokuSpace.sm),
            SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final s in _suggestions)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ShokuChip(s, onTap: () => _send(s)),
                    ),
                ],
              ),
            ),
            if (widget.onLogChange != null) ...[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onLogChange!();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: surfaceTint(context),
                    borderRadius: BorderRadius.circular(ShokuRadius.chip),
                    border: Border.all(color: c.hairline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bolt, size: 14, color: c.reward),
                      const SizedBox(width: 6),
                      Text('Log a change to this cook',
                          style: ShokuType.label.copyWith(fontSize: 9.5, color: c.ink)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: ShokuSpace.sm),
            ],
            MicField(
              controller: _input,
              hint: 'Ask, or hold the mic',
              maxLines: 2,
            ),
            const SizedBox(height: ShokuSpace.sm),
            GestureDetector(
              onTap: () => _send(_input.text),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: ShokuGradients.crimsonPress,
                  borderRadius: BorderRadius.circular(ShokuRadius.chip),
                  border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                ),
                child: Center(
                  child: Text('Ask',
                      style: ShokuType.title.copyWith(color: c.onAccent, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Color surfaceTint(BuildContext context) => Theme.of(context).extension<dynamic>() != null
    ? context.colors.surfaceAlt
    : Colors.transparent;
