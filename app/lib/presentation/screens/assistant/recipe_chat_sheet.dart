import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../data/db/assistant_turn_repository.dart';
import '../../../data/mock/journal_data.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/assistant_service.dart';
import '../../../data/services/speech_service.dart';
import '../../state/assistant_providers.dart';
import '../../state/journal_providers.dart';
import '../../state/journal_store.dart';
import '../bot/bot_scope.dart';
import '../bot/scope_switcher.dart';
import '../profile/sign_in_sheet.dart';
import '../../widgets/kit/bot_mark.dart';
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

enum _Kind { mine, answer, diff, notice, divider }

class _Turn {
  const _Turn.mine(this.text)
      : kind = _Kind.mine,
        retry = null,
        reply = null,
        question = null;
  const _Turn.answer(this.text)
      : kind = _Kind.answer,
        retry = null,
        reply = null,
        question = null;
  const _Turn.notice(this.text, {this.retry})
      : kind = _Kind.notice,
        reply = null,
        question = null;
  const _Turn.divider(this.text)
      : kind = _Kind.divider,
        retry = null,
        reply = null,
        question = null;
  const _Turn.diff(this.reply, this.question)
      : kind = _Kind.diff,
        text = '',
        retry = null;

  /// A turn read back from this device's own memory.
  factory _Turn.restored(AssistantTurnRecord turn) =>
      turn.isMine ? _Turn.mine(turn.text) : _Turn.answer(turn.text);

  final _Kind kind;
  final String text;

  /// Set on a sign-in prompt: the question to ask again once there is a
  /// session. It is what makes the notice a door instead of a sentence.
  final String? retry;

  final AssistantReply? reply;
  final String? question;
}

/// The ask sheet: questions, answers, and one recipe change at a time.
///
/// Nothing here writes the journal directly. An edit arrives as arrays the
/// server computed against one specific version; Apply writes exactly one
/// version through the store, the same door a cook uses.
///
/// The conversation is remembered on this device, per dish, and the server is
/// never told about it: `history` is the client's own last two exchanges.
class RecipeChatSheet extends ConsumerStatefulWidget {
  const RecipeChatSheet({super.key, required this.dish, this.stepIndex});

  final Dish dish;
  final int? stepIndex;

  @override
  ConsumerState<RecipeChatSheet> createState() => _RecipeChatSheetState();
}

class _RecipeChatSheetState extends ConsumerState<RecipeChatSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _turns = <_Turn>[];

  /// The turns behind the sheet, oldest first: restored and this session's.
  final _stored = <AssistantTurnRecord>[];

  int _total = 0;
  bool _loading = true;

  /// The version the sheet is talking about. History never crosses it.
  String? _versionId;
  int _versionNumber = 1;

  /// A step scope the cook can drop with the chip's x.
  bool _stepScope = true;

  bool _thinking = false;
  bool _applying = false;
  String? _error;
  int? _appliedVersion;
  bool _cap = false;
  /// Asks left today, when the server last said.
  int? _remaining;
  bool _offline = false;

  /// One sign-in at a time: the prompt is not a button that stacks sheets.
  bool _signingIn = false;

  /// The one unresolved diff. Two at once would be two truths about the head.
  _Turn? _diff;
  bool _stale = false;

  @override
  void initState() {
    super.initState();
    _versionId = _headId(widget.dish);
    _versionNumber = _numberOf(widget.dish, _versionId);
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// The list is reversed, so offset zero is the newest turn. Anything appended
  /// is only *visible* once the edge is brought back into view — a bubble the
  /// cook has to scroll to find is a bubble they never saw.
  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
      );
    });
  }

  static String? _headId(Dish dish) =>
      dish.versions.isEmpty ? null : dish.versions.last.id;

  static int _numberOf(Dish dish, String? versionId) {
    final index = dish.versions.indexWhere((v) => v.id == versionId);
    return index < 0 ? dish.versions.length : index + 1;
  }

  Future<void> _load() async {
    final repo = ref.read(assistantTurnRepositoryProvider);
    try {
      final total = await repo.count(widget.dish.id);
      final last = await repo.load(widget.dish.id);
      if (!mounted) return;
      setState(() {
        _total = total;
        _stored
          ..clear()
          ..addAll(last);
        _turns
          ..clear()
          ..addAll([for (final turn in last) _Turn.restored(turn)]);
        _loading = false;
      });
    } catch (_) {
      // A chat that cannot be read is still a chat that can be started.
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showEarlier() async {
    final repo = ref.read(assistantTurnRepositoryProvider);
    final all = await repo.load(widget.dish.id, limit: _total);
    if (!mounted) return;
    final already = _stored.length;
    final older = all.length <= already ? const <AssistantTurnRecord>[] : all.sublist(0, all.length - already);
    setState(() {
      _stored
        ..clear()
        ..addAll(all);
      _turns.insertAll(0, [for (final turn in older) _Turn.restored(turn)]);
    });
  }

  Future<void> _clear() async {
    if (_thinking || _applying) return;
    await ref.read(assistantTurnRepositoryProvider).clear(widget.dish.id);
    if (!mounted) return;
    setState(() {
      _stored.clear();
      _turns.clear();
      _total = 0;
      _diff = null;
      _appliedVersion = null;
      _error = null;
      _stale = false;
    });
  }

  /// The last two exchanges **at this version**. Anything said about an older
  /// version is context the server must not get: it would answer about a
  /// recipe that no longer matches the one on screen.
  List<AssistantTurn> _history() {
    final relevant = [
      for (final turn in _stored)
        if (turn.versionId == _versionId) turn,
    ];
    final tail = relevant.length <= 4
        ? relevant
        : relevant.sublist(relevant.length - 4);
    return [
      for (final turn in tail)
        AssistantTurn(role: turn.role, text: turn.text),
    ];
  }

  /// The version changed while the sheet was open (an applied edit, or a fork
  /// from elsewhere). Old turns stay readable behind a divider; new ones start
  /// the context again.
  void _movedTo(Dish dish) {
    final head = _headId(dish);
    if (!mounted || head == null || head == _versionId) return;
    setState(() {
      _versionId = head;
      _versionNumber = _numberOf(dish, head);
      _turns.add(_Turn.divider('v$_versionNumber'));
    });
  }

  String get _scope => widget.stepIndex != null && _stepScope
      ? '${context.l10n.chatAboutStep(widget.stepIndex! + 1)}: '
      : '';

  bool get _blocked => _cap || _offline;

  bool get _canSend => !_thinking && !_applying && _diff == null && !_blocked;

  Future<void> _remember(String role, String text) async {
    try {
      final turn = await ref.read(assistantTurnRepositoryProvider).add(
            dishId: widget.dish.id,
            versionId: _versionId,
            role: role,
            text: text,
          );
      _stored.add(turn);
      _total++;
    } catch (_) {
      // Memory is best-effort: losing a line must not lose the answer.
    }
  }

  Future<void> _send(String raw, {bool retrying = false}) async {
    final question = raw.trim();
    if (question.isEmpty || !_canSend) return;

    final history = _history();
    setState(() {
      // The field empties the moment the turn is accepted, not when the answer
      // lands: the question is already in the list, so nothing is lost by
      // letting the cook start typing the next one.
      _input.clear();
      // A retry after sign-in repeats a question that is already in the thread;
      // adding it twice would read as two asks.
      if (!retrying) _turns.add(_Turn.mine(question));
      _thinking = true;
      _error = null;
    });
    _scrollToLatest();
    unawaited(_remember('user', question));

    try {
      final reply = await ref.read(assistantServiceProvider).ask(
            scope: 'dish',
            dishId: widget.dish.id,
            versionId: _versionId,
            // In cook mode the question is about the step on screen.
            stepIndex: widget.stepIndex,
            question: '$_scope$question',
            requestId: _uuid.v4(),
            history: history,
          ).timeout(const Duration(seconds: 30));

      if (!mounted) return;
      HapticFeedback.selectionClick();
      setState(() {
        _thinking = false;
        _remaining = reply.remaining;
        _turns.add(_Turn.answer(reply.answer));
        if (reply.isEdit) {
          final diff = _Turn.diff(reply, question);
          _turns.add(diff);
          _diff = diff;
          _stale = false;
        }
      });
      _scrollToLatest();
      unawaited(_remember('assistant', reply.answer));
      if (reply.isEdit) {
        // A change is a decision, not a paragraph: never read it out unasked.
        await ref.read(speechServiceProvider).stop();
      }
    } on AssistantCapReached {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _cap = true;
        _remaining = 0;
        _turns.add(_Turn.notice(context.l10n.botCapNotice));
      });
      _scrollToLatest();
    } on ApiUnauthenticated {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _turns.add(_Turn.notice(
          context.l10n.botSignInNotice,
          retry: question,
        ));
      });
      _scrollToLatest();
    } on ApiError {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _turns.add(_Turn.notice(context.l10n.botServerNotice));
      });
      _scrollToLatest();
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _offline = true;
        _turns.add(_Turn.notice(context.l10n.botOfflineNotice));
      });
      _scrollToLatest();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _offline = true;
        _turns.add(_Turn.notice(context.l10n.botOfflineNotice));
      });
      _scrollToLatest();
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
        _error = context.l10n.chatNothingChanged;
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

  /// A 401 is a door, not a wall: the prompt opens the sheet, and the question
  /// the cook already asked is sent again once a session lands. Single-flight —
  /// one sheet, one retry, no double send.
  Future<void> _signInAndRetry(_Turn notice) async {
    final question = notice.retry;
    if (question == null || _signingIn) return;
    setState(() => _signingIn = true);
    final signedIn = await showSignInSheet(context);
    if (!mounted) return;
    setState(() {
      _signingIn = false;
      // A successful prompt has served its purpose; a dismissed one stays so
      // the cook can tap it again.
      if (signedIn) _turns.remove(notice);
    });
    if (!signedIn || !_canSend) return;
    await _send(question, retrying: true);
  }

  void _openVersion(int number) {
    ref.read(inspectedVersionProvider(widget.dish.id).notifier).state = number;
    Navigator.of(context).pop();
    context.push('/dish/${widget.dish.id}');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final watched = ref.watch(dishProvider(widget.dish.id)) ?? widget.dish;
    final head = _headId(watched);
    if (head != null && head != _versionId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _movedTo(watched));
    }
    final tall = _diff != null || _appliedVersion != null;

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
                // 22 px inside a 32 px hairline ring: the bot's own face.
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.hairline),
                    color: c.surface,
                  ),
                  child: const Center(child: BotMark(size: 22)),
                ),
                const SizedBox(width: ShokuSpace.sm),
                Expanded(
                  child: Text(
                    l10n.botAskDish(_versionNumber),
                    key: const ValueKey('chat-title'),
                    style: ShokuType.h2.copyWith(color: c.ink),
                  ),
                ),
                GestureDetector(
                  key: const ValueKey('bot-new-chat'),
                  onTap: _turns.isEmpty ? null : _clear,
                  behavior: HitTestBehavior.opaque,
                  child: Text(l10n.botNewChat,
                      style: ShokuType.label.copyWith(
                          fontSize: 9.5, color: c.inkMuted)),
                ),
              ],
            ),
            if (_remaining != null && _remaining! <= 5) ...[
              const SizedBox(height: ShokuSpace.xs),
              Text(
                l10n.botAsksLeft(_remaining!),
                key: const ValueKey('chat-asks-left'),
                style: ShokuType.bodySmall
                    .copyWith(color: c.inkMuted, fontSize: 11.5),
              ),
            ],
            if (widget.stepIndex != null && _stepScope) ...[
              const SizedBox(height: ShokuSpace.xs),
              Row(
                children: [
                  GestureDetector(
                    key: const ValueKey('chat-step-chip'),
                    onTap: () => setState(() => _stepScope = false),
                    behavior: HitTestBehavior.opaque,
                    child: ShokuChip(
                      l10n.chatAboutStep(widget.stepIndex! + 1),
                      icon: Icons.close,
                      color: c.accent,
                    ),
                  ),
                ],
              ),
            ],
            if (_total > _stored.length)
              Center(
                child: GestureDetector(
                  key: const ValueKey('chat-earlier'),
                  onTap: _showEarlier,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: ShokuSpace.xs),
                    child: Text(
                      l10n.chatEarlier(_total - _stored.length),
                      style: ShokuType.label
                          .copyWith(fontSize: 9.5, color: c.inkMuted),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: ShokuSpace.sm),
            Expanded(
              child: ListView(
                controller: _scroll,
                reverse: true,
                padding: const EdgeInsets.only(bottom: ShokuSpace.sm),
                children: [
                  // First, because the list is reversed: this is the bottom
                  // edge, where the cook is looking.
                  if (_thinking) _thinkingBubble(context),
                  if (_loading)
                    const SizedBox.shrink()
                  else
                    for (final turn in _turns.reversed) _bubble(context, turn),
                ],
              ),
            ),
            if (_appliedVersion != null) _appliedBar(context, _appliedVersion!),
            const SizedBox(height: ShokuSpace.sm),
            // The scope is never silent: it is above the input, always.
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                key: const ValueKey('bot-scope-chip'),
                onTap: () => showScopeSwitcher(context),
                child: ShokuChip(
                  botScopeLabel(ref, BotScope(dishId: widget.dish.id), l10n),
                  icon: Icons.expand_more,
                  color: c.accent,
                ),
              ),
            ),
            const SizedBox(height: ShokuSpace.sm),
            MicField(
              controller: _input,
              enabled: _canSend,
              hint: _diff != null
                  ? l10n.chatResolveChange
                  : _cap
                      ? l10n.botOutOfQuestions
                      : _offline
                          ? l10n.botNoConnection
                          : l10n.chatAskHint,
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
                    child: Text(l10n.chatAsk,
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
    final l10n = context.l10n;
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
        _Kind.notice => _ChatNotice(
            text: turn.text,
            onTap: turn.retry == null ? null : () => _signInAndRetry(turn),
          ),
        _Kind.divider => Padding(
            padding: const EdgeInsets.symmetric(vertical: ShokuSpace.sm),
            child: Row(
              children: [
                Expanded(child: Divider(color: c.hairline, height: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.sm),
                  child: Text(l10n.chatVersionDivider(_versionNumber),
                      key: const ValueKey('chat-version-divider'),
                      style:
                          ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
                ),
                Expanded(child: Divider(color: c.hairline, height: 1)),
              ],
            ),
          ),
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
        child: Text(context.l10n.botThinking,
            key: const ValueKey('chat-thinking'),
            style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
      ),
    );
  }

  Widget _appliedBar(BuildContext context, int number) {
    final c = context.colors;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: ShokuSpace.sm),
      child: Row(
        children: [
          Icon(Icons.check, size: 14, color: c.ready),
          const SizedBox(width: 6),
          Text(l10n.chatApplied(number),
              key: const ValueKey('chat-applied'),
              style: ShokuType.label.copyWith(fontSize: 9.5, color: c.ready)),
          const Spacer(),
          TextButton(
            key: const ValueKey('chat-open-version'),
            onPressed: () => _openVersion(number),
            child: Text(l10n.chatOpenVersion(number)),
          ),
          TextButton(
            key: const ValueKey('chat-undo'),
            onPressed: () {
              setState(() => _appliedVersion = null);
              // Undo is just another ask: the server returns the inverse arrays
              // and nothing is tombstoned.
              _send('undo that');
            },
            child: Text(l10n.chatUndo),
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
              key: const ValueKey('answer-speaker'),
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
  const _ChatNotice({required this.text, this.onTap});

  final String text;

  /// A notice with a door: tapping it opens sign-in and then retries.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = ShokuType.bodySmall.copyWith(color: c.inkMuted);
    final action = onTap;
    if (action == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: ShokuSpace.xs),
        child: Text(text,
            key: const ValueKey('chat-notice'),
            style: style),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ShokuSpace.xs),
      child: GestureDetector(
        key: const ValueKey('chat-notice-signin'),
        onTap: action,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: ShokuSpace.md, vertical: 10),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(ShokuRadius.chip),
            border: Border.all(color: c.accent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.login, size: 14, color: c.accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(text,
                    key: const ValueKey('chat-notice'),
                    style: style.copyWith(color: c.ink)),
              ),
            ],
          ),
        ),
      ),
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
    final l10n = context.l10n;
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
              Text(l10n.chatRecipeChange,
                  style: ShokuType.label.copyWith(fontSize: 9, color: c.ink)),
              const Spacer(),
              Text(l10n.chatVersionArrow(dish.versions.length, next),
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
            Text(l10n.chatMoreEdits(more),
                style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
          const SizedBox(height: ShokuSpace.sm),
          Text(l10n.chatCreatesVersion(next),
              style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
          const SizedBox(height: ShokuSpace.sm),
          if (stale)
            _buttons(context, [
              (l10n.chatRecompute, onRecompute, 'diff-recompute'),
              (l10n.chatDiscard, onDiscard, 'diff-discard'),
            ])
          else if (error != null) ...[
            Row(
              children: [
                ShokuChip(l10n.chatNotApplied, color: c.danger),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(l10n.chatNothingChanged,
                      key: const ValueKey('diff-error'),
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                ),
              ],
            ),
            const SizedBox(height: ShokuSpace.sm),
            _buttons(context, [
              (l10n.chatTryAgain, onApply, 'diff-retry'),
              (l10n.chatDiscard, onDiscard, 'diff-discard'),
            ]),
          ] else
            Row(
              children: [
                Expanded(
                  child: _Action(
                    key: const ValueKey('diff-apply'),
                    label: applying
                        ? l10n.chatApplying
                        : l10n.chatApplyAs(next),
                    onTap: applying ? null : onApply,
                    primary: true,
                  ),
                ),
                const SizedBox(width: ShokuSpace.sm),
                Expanded(
                  child: _Action(
                    key: const ValueKey('diff-discard'),
                    label: l10n.botNotThis,
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
