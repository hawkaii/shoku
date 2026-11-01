import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../../data/services/assistant_service.dart';
import '../../../data/services/speech_service.dart';
import '../../state/assistant_providers.dart';
import '../../state/journal_providers.dart';
import '../../state/journal_store.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/mic_field.dart';
import '../../widgets/kit/motion.dart';

const _uuid = Uuid();

Future<void> showRecipeChat(
  BuildContext context, {
  required Dish dish,
  int? stepIndex,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (_) => RecipeChatSheet(dish: dish, stepIndex: stepIndex),
  );
}

enum _Kind { mine, answer, diff, notice }

class _Turn {
  const _Turn.mine(this.text)
      : kind = _Kind.mine,
        reply = null,
        question = null;
  const _Turn.answer(this.text)
      : kind = _Kind.answer,
        reply = null,
        question = null;
  const _Turn.notice(this.text)
      : kind = _Kind.notice,
        reply = null,
        question = null;
  const _Turn.diff(this.reply, this.question)
      : kind = _Kind.diff,
        text = '';

  final _Kind kind;
  final String text;
  final AssistantReply? reply;
  final String? question;
}

/// The ask sheet: questions, answers, and one recipe change at a time.
///
/// Nothing here writes the journal directly. An edit arrives as arrays the
/// server computed against one specific version; Apply writes exactly one
/// version through the store, the same door a cook uses.
class RecipeChatSheet extends ConsumerStatefulWidget {
  const RecipeChatSheet({super.key, required this.dish, this.stepIndex});

  final Dish dish;
  final int? stepIndex;

  @override
  ConsumerState<RecipeChatSheet> createState() => _RecipeChatSheetState();
}

class _RecipeChatSheetState extends ConsumerState<RecipeChatSheet> {
  final _input = TextEditingController();
  final _turns = <_Turn>[];
  final _history = <AssistantTurn>[];

  bool _thinking = false;
  bool _applying = false;
  String? _error;
  int? _appliedVersion;
  bool _cap = false;
  bool _offline = false;

  /// The one unresolved diff. Two at once would be two truths about the head.
  _Turn? _diff;
  bool _stale = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  String get _scope =>
      widget.stepIndex == null ? '' : 'About step ${widget.stepIndex! + 1}: ';

  bool get _blocked => _cap || _offline;

  bool get _canSend => !_thinking && !_applying && _diff == null && !_blocked;

  Future<void> _send(String raw) async {
    final question = raw.trim();
    if (question.isEmpty || !_canSend) return;

    setState(() {
      _turns.add(_Turn.mine(question));
      _thinking = true;
      _error = null;
    });

    try {
      final reply = await ref.read(assistantServiceProvider).ask(
            dishId: widget.dish.id,
            versionId: widget.dish.versions.isEmpty
                ? null
                : widget.dish.versions.last.id,
            question: '$_scope$question',
            requestId: _uuid.v4(),
            history: _history,
          ).timeout(const Duration(seconds: 30));

      if (!mounted) return;
      HapticFeedback.selectionClick();
      setState(() {
        _thinking = false;
        _input.clear();
        _turns.add(_Turn.answer(reply.answer));
        _history.addAll([
          AssistantTurn(role: 'user', text: question),
          AssistantTurn(role: 'assistant', text: reply.answer),
        ]);
        while (_history.length > 4) {
          _history.removeAt(0);
        }
        if (reply.isEdit) {
          final diff = _Turn.diff(reply, question);
          _turns.add(diff);
          _diff = diff;
          _stale = false;
        }
      });

      if (reply.isEdit) {
        // A change is a decision, not a paragraph: never read it out unasked.
        await ref.read(speechServiceProvider).stop();
      } else {
        await ref.read(readAloudProvider.notifier).speak(reply.answer);
      }
    } on AssistantCapReached {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _cap = true;
        _turns.add(const _Turn.notice(
          'You have used today’s questions. They come back tomorrow.',
        ));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _offline = true;
        _turns.add(const _Turn.notice(
          'No connection — answers need the network.',
        ));
      });
    }
  }

  Future<void> _apply() async {
    final appliable = _diff?.reply?.appliable;
    if (appliable == null) return;

    setState(() {
      _applying = true;
      _error = null;
    });
    HapticFeedback.mediumImpact();

    try {
      // The precondition is checked inside the write, in the same transaction:
      // these arrays were computed against one version, and if the head has
      // moved since, nothing is written and the card offers Recompute.
      final number = await ref
          .read(journalStoreProvider.notifier)
          .applyEditVersion(
            dishId: widget.dish.id,
            baseVersionId: appliable.baseVersionId,
            ingredients: appliable.ingredients,
            steps: appliable.steps,
            stepIngredients: appliable.stepIngredients,
            changes: appliable.changes,
          )
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;
      setState(() {
        _applying = false;
        if (number == null) {
          _stale = true;
        } else {
          _appliedVersion = number;
          _diff = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _applying = false;
        _error = 'Nothing changed in your recipe.';
      });
    }
  }

  void _discard() {
    setState(() {
      _diff = null;
      _stale = false;
      _error = null;
    });
  }

  Future<void> _recompute() async {
    final question = _diff?.question;
    _discard();
    if (question != null) await _send(question);
  }

  void _openVersion(int number) {
    ref.read(inspectedVersionProvider(widget.dish.id).notifier).state = number;
    Navigator.of(context).pop();
    context.push('/dish/${widget.dish.id}');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tall = _diff != null || _appliedVersion != null;
    final readAloud = ref.watch(readAloudProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      height: MediaQuery.of(context).size.height * (tall ? 0.92 : 0.62),
      child: Padding(
        padding: EdgeInsets.only(
          left: ShokuSpace.lg,
          right: ShokuSpace.lg,
          top: ShokuSpace.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + ShokuSpace.md,
        ),
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
                Expanded(
                  child: Text('Ask about this cook',
                      style: ShokuType.h2.copyWith(color: c.ink)),
                ),
                GestureDetector(
                  key: const ValueKey('read-aloud-toggle'),
                  onTap: () => ref.read(readAloudProvider.notifier).toggle(),
                  behavior: HitTestBehavior.opaque,
                  child: ShokuChip(
                    'Read aloud',
                    icon: readAloud ? Icons.volume_up : Icons.volume_off,
                    color: readAloud ? c.accent : c.inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ShokuSpace.sm),
            Expanded(
              child: ListView(
                reverse: true,
                padding: const EdgeInsets.only(bottom: ShokuSpace.sm),
                children: [
                  for (final turn in _turns.reversed) _bubble(context, turn),
                  if (_thinking) _thinkingBubble(context),
                ],
              ),
            ),
            if (_appliedVersion != null) _appliedBar(context, _appliedVersion!),
            const SizedBox(height: ShokuSpace.sm),
            MicField(
              controller: _input,
              enabled: _canSend,
              hint: _diff != null
                  ? 'Resolve the change above'
                  : _cap
                      ? 'Out of questions for today'
                      : _offline
                          ? 'No connection'
                          : 'Ask, or hold the mic',
            ),
            const SizedBox(height: ShokuSpace.sm),
            ShokuPressable(
              key: const ValueKey('chat-send'),
              onTap: _canSend ? () => _send(_input.text) : null,
              child: AnimatedOpacity(
                duration: ShokuMotion.toggle,
                opacity: _canSend ? 1 : 0.45,
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
                        style: ShokuType.title
                            .copyWith(color: c.onAccent, fontSize: 14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(BuildContext context, _Turn turn) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: ShokuSpace.sm),
      child: switch (turn.kind) {
        _Kind.mine => Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.all(ShokuSpace.md),
              decoration: BoxDecoration(
                color: c.ink,
                borderRadius: BorderRadius.circular(ShokuRadius.card),
              ),
              child: Text(turn.text,
                  key: const ValueKey('mine-bubble'),
                  style: ShokuType.bodySmall.copyWith(color: c.canvas)),
            ),
          ),
        _Kind.answer => _AnswerBubble(text: turn.text),
        _Kind.notice => _ChatNotice(text: turn.text),
        _Kind.diff => _DiffCard(
            turn: turn,
            dish: widget.dish,
            applying: _applying,
            stale: _stale,
            error: _error,
            onApply: _apply,
            onDiscard: _discard,
            onRecompute: _recompute,
          ),
      },
    );
  }

  Widget _thinkingBubble(BuildContext context) {
    final c = context.colors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(ShokuSpace.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(ShokuRadius.card),
          border: Border.all(color: c.hairline),
        ),
        child: Text('THINKING',
            key: const ValueKey('chat-thinking'),
            style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
      ),
    );
  }

  Widget _appliedBar(BuildContext context, int number) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: ShokuSpace.sm),
      child: Row(
        children: [
          Icon(Icons.check, size: 14, color: c.ready),
          const SizedBox(width: 6),
          Text('V$number · APPLIED',
              key: const ValueKey('chat-applied'),
              style: ShokuType.label.copyWith(fontSize: 9.5, color: c.ready)),
          const Spacer(),
          TextButton(
            key: const ValueKey('chat-open-version'),
            onPressed: () => _openVersion(number),
            child: const Text('Open v2'),
          ),
          TextButton(
            key: const ValueKey('chat-undo'),
            onPressed: () {
              setState(() => _appliedVersion = null);
              // Undo is just another ask: the server returns the inverse arrays
              // and nothing is tombstoned.
              _send('undo that');
            },
            child: const Text('Undo'),
          ),
        ],
      ),
    );
  }
}

class _AnswerBubble extends ConsumerStatefulWidget {
  const _AnswerBubble({required this.text});

  final String text;

  @override
  ConsumerState<_AnswerBubble> createState() => _AnswerBubbleState();
}

class _AnswerBubbleState extends ConsumerState<_AnswerBubble> {
  bool _speaking = false;

  Future<void> _speak() async {
    final speech = ref.read(speechServiceProvider);
    if (_speaking) {
      await speech.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    setState(() => _speaking = true);
    await speech.speak(widget.text);
    if (mounted) setState(() => _speaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        padding: const EdgeInsets.all(ShokuSpace.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(ShokuRadius.card),
          border: Border.all(color: c.hairline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(widget.text,
                  key: const ValueKey('answer-bubble'),
                  style: ShokuType.bodySmall.copyWith(color: c.ink)),
            ),
            const SizedBox(width: ShokuSpace.sm),
            GestureDetector(
              onTap: _speak,
              behavior: HitTestBehavior.opaque,
              child: Icon(_speaking ? Icons.stop : Icons.volume_up,
                  size: 16, color: c.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatNotice extends StatelessWidget {
  const _ChatNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ShokuSpace.xs),
      child: Text(text,
          key: const ValueKey('chat-notice'),
          style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
    );
  }
}

/// The change, as a card: what it does, then the decision. One at a time.
class _DiffCard extends StatelessWidget {
  const _DiffCard({
    required this.turn,
    required this.dish,
    required this.applying,
    required this.stale,
    required this.error,
    required this.onApply,
    required this.onDiscard,
    required this.onRecompute,
  });

  final _Turn turn;
  final Dish dish;
  final bool applying;
  final bool stale;
  final String? error;
  final VoidCallback onApply;
  final VoidCallback onDiscard;
  final VoidCallback onRecompute;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reply = turn.reply!;
    final next = dish.versions.isEmpty ? 1 : dish.versions.last.number + 1;
    final shown = reply.edits.take(4).toList();
    final more = reply.edits.length - shown.length;

    return Container(
      key: const ValueKey('recipe-diff'),
      width: double.infinity,
      padding: const EdgeInsets.all(ShokuSpace.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.card),
        border: Border.all(color: c.ink, width: ShokuStroke.brutal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('RECIPE CHANGE',
                  style: ShokuType.label.copyWith(fontSize: 9, color: c.ink)),
              const Spacer(),
              Text('v${dish.versions.length} → v$next',
                  style: ShokuType.label.copyWith(fontSize: 9, color: c.accent)),
            ],
          ),
          const SizedBox(height: 6),
          Text(reply.answer,
              key: const ValueKey('diff-summary'),
              style: ShokuType.bodySmall.copyWith(color: c.ink)),
          const SizedBox(height: ShokuSpace.sm),
          for (final edit in shown) _delta(context, edit),
          if (more > 0)
            Text('+$more more',
                style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
          const SizedBox(height: ShokuSpace.sm),
          Text('Creates v$next — from this message',
              style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
          const SizedBox(height: ShokuSpace.sm),
          if (stale)
            _buttons(context, [
              ('Recompute', onRecompute, 'diff-recompute'),
              ('Discard', onDiscard, 'diff-discard'),
            ])
          else if (error != null) ...[
            Row(
              children: [
                ShokuChip('NOT APPLIED', color: c.danger),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Nothing changed in your recipe.',
                      key: const ValueKey('diff-error'),
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                ),
              ],
            ),
            const SizedBox(height: ShokuSpace.sm),
            _buttons(context, [
              ('Try again', onApply, 'diff-retry'),
              ('Discard', onDiscard, 'diff-discard'),
            ]),
          ] else
            Row(
              children: [
                Expanded(
                  child: _Action(
                    key: const ValueKey('diff-apply'),
                    label: applying ? 'Applying…' : 'Apply as v$next',
                    onTap: applying ? null : onApply,
                    primary: true,
                  ),
                ),
                const SizedBox(width: ShokuSpace.sm),
                Expanded(
                  child: _Action(
                    key: const ValueKey('diff-discard'),
                    label: 'Not this',
                    onTap: applying ? null : onDiscard,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _delta(BuildContext context, AssistantEdit edit) {
    final c = context.colors;
    final (marker, colour) = switch (edit.op) {
      'add' => ('+', c.ready),
      'remove' => ('−', c.danger),
      _ => ('~', c.reward),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 14,
            child: Text(marker,
                style: ShokuType.stat.copyWith(fontSize: 13, color: colour)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(edit.text,
                    style: ShokuType.bodySmall.copyWith(
                      color: c.ink,
                      decoration: edit.op == 'remove'
                          ? TextDecoration.lineThrough
                          : null,
                    )),
                if (edit.previous != null && edit.previous!.isNotEmpty)
                  Text(edit.previous!,
                      style: ShokuType.label.copyWith(
                        fontSize: 9,
                        color: c.inkMuted,
                        decoration: TextDecoration.lineThrough,
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttons(
      BuildContext context, List<(String, VoidCallback, String)> actions) {
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: ShokuSpace.sm),
          Expanded(
            child: _Action(
              key: ValueKey(actions[i].$3),
              label: actions[i].$1,
              onTap: applying ? null : actions[i].$2,
              primary: i == 0,
            ),
          ),
        ],
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    super.key,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          gradient: primary ? ShokuGradients.crimsonPress : null,
          color: primary ? null : c.surfaceAlt,
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
          border: Border.all(
            color: c.ink,
            width: primary ? ShokuStroke.brutal : ShokuStroke.hairline,
          ),
        ),
        child: Center(
          child: Text(label,
              style: ShokuType.title.copyWith(
                color: primary ? c.onAccent : c.ink,
                fontSize: 12.5,
              )),
        ),
      ),
    );
  }
}
