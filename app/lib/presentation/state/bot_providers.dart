import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/db/assistant_turn_repository.dart';
import '../../../data/services/assistant_service.dart';
import '../../../data/models/pantry_item.dart';
import '../state/assistant_providers.dart';
import '../state/pantry_providers.dart';
import '../state/sync_providers.dart';

const _uuid = Uuid();

enum BotTurnKind { mine, answer, notice, divider, suggestions, capture }

/// One line in the kitchen thread.
class BotTurn {
  const BotTurn.mine(this.text)
      : kind = BotTurnKind.mine,
        suggestions = const [],
        items = const [];
  const BotTurn.answer(this.text)
      : kind = BotTurnKind.answer,
        suggestions = const [],
        items = const [];
  const BotTurn.notice(this.text)
      : kind = BotTurnKind.notice,
        suggestions = const [],
        items = const [];
  const BotTurn.divider(this.text)
      : kind = BotTurnKind.divider,
        suggestions = const [],
        items = const [];
  const BotTurn.suggestions(this.suggestions)
      : kind = BotTurnKind.suggestions,
        text = '',
        items = const [];
  const BotTurn.capture(this.items)
      : kind = BotTurnKind.capture,
        text = '',
        suggestions = const [];

  final BotTurnKind kind;
  final String text;
  final List<BotSuggestion> suggestions;
  final List<BotCaptureItem> items;
}

class BotState {
  const BotState({
    this.turns = const [],
    this.thinking = false,
    this.offline = false,
    this.cap = false,
    this.draft = '',
    this.unread = false,
    this.exclude = const [],
    this.starters = const [],
  });

  final List<BotTurn> turns;
  final bool thinking;
  final bool offline;
  final bool cap;

  /// Kept across a collapse: the sheet is a drawer, not a page.
  final String draft;

  /// A reply landed while the sheet was closed.
  final bool unread;

  /// "Not this" reshuffles with the cards already seen.
  final List<String> exclude;

  /// What the empty thread offers: starters, or a dinner prompt.
  final List<String> starters;

  BotState copyWith({
    List<BotTurn>? turns,
    bool? thinking,
    bool? offline,
    bool? cap,
    String? draft,
    bool? unread,
    List<String>? exclude,
    List<String>? starters,
  }) =>
      BotState(
        turns: turns ?? this.turns,
        thinking: thinking ?? this.thinking,
        offline: offline ?? this.offline,
        cap: cap ?? this.cap,
        draft: draft ?? this.draft,
        unread: unread ?? this.unread,
        exclude: exclude ?? this.exclude,
        starters: starters ?? this.starters,
      );
}

/// The kitchen thread: what the bot says when no dish is in scope.
///
/// It never creates a dish and never writes to the fridge without the capture
/// card being confirmed. The server is stateless; the thread is this device's.
class BotController extends StateNotifier<BotState> {
  BotController(this._ref) : super(const BotState()) {
    _load();
  }

  final Ref _ref;
  int _generation = 0;

  AssistantTurnRepository get _repo => _ref.read(assistantTurnRepositoryProvider);

  Future<void> _load() async {
    try {
      final stored = await _repo.loadThread(const BotThread.kitchen());
      if (!mounted) return;
      state = state.copyWith(
        turns: [
          for (final turn in stored)
            turn.isMine ? BotTurn.mine(turn.text) : BotTurn.answer(turn.text),
        ],
        starters: _starters(),
      );
    } catch (_) {
      if (mounted) state = state.copyWith(starters: _starters());
    }
  }

  List<String> _starters() {
    final fridge = _ref.read(pantryStoreProvider);
    final stocked = fridge.where((item) => !item.wanted).length;
    if (stocked == 0) {
      return const [
        "What's in your fridge?",
        'Show me something from the Wall',
        'I have a photo of a dish',
      ];
    }
    return [
      'You have $stocked ${stocked == 1 ? 'thing' : 'things'} in the fridge. Dinner from them?',
    ];
  }

  void setDraft(String text) => state = state.copyWith(draft: text);

  void markRead() => state = state.copyWith(unread: false);

  void markUnread() => state = state.copyWith(unread: true);

  /// A new chat clears this thread only; other scopes are untouched.
  Future<void> newChat() async {
    _generation++;
    await _repo.clearThread(const BotThread.kitchen());
    if (!mounted) return;
    state = state.copyWith(
      turns: const [],
      exclude: const [],
      unread: false,
      starters: _starters(),
    );
  }

  Future<void> send(String raw, {bool shuffle = false}) async {
    final question = raw.trim();
    if (question.isEmpty || state.thinking) return;

    final generation = ++_generation;
    final exclude = shuffle ? state.exclude : <String>[];
    state = state.copyWith(turns: [...state.turns, BotTurn.mine(question)]);
    state = state.copyWith(
      thinking: true,
      draft: '',
      offline: false,
      cap: false,
      unread: false,
      exclude: exclude,
    );
    unawaited(_remember('user', question));

    try {
      final reply = await _ref.read(assistantServiceProvider).ask(
            scope: 'kitchen',
            question: question,
            requestId: _uuid.v4(),
            history: _history(),
            exclude: exclude,
          ).timeout(const Duration(seconds: 30));
      if (!mounted || generation != _generation) return;

      final turns = [...state.turns];
      if (reply.answer.trim().isNotEmpty) {
        turns.add(BotTurn.answer(reply.answer));
      }
      if (reply.suggestions.isNotEmpty) {
        turns.add(BotTurn.suggestions(reply.suggestions.take(3).toList()));
        state = state.copyWith(
          exclude: [
            ...exclude,
            for (final card in reply.suggestions) card.shortcode,
          ],
        );
      }
      if (reply.items.isNotEmpty) {
        turns.add(BotTurn.capture(reply.items));
      }
      if (reply.choices.isNotEmpty) {
        turns.add(BotTurn.notice(
          'Which dish did you mean? ${reply.choices.map((c) => c.title).join(' · ')}',
        ));
      }
      state = state.copyWith(turns: turns, thinking: false);
      unawaited(_remember('assistant', reply.answer));
    } on AssistantCapReached {
      if (!mounted || generation != _generation) return;
      state = state.copyWith(
        thinking: false,
        cap: true,
        turns: [
          ...state.turns,
          const BotTurn.notice(
              'You have used today’s questions. They come back tomorrow.'),
        ],
      );
    } catch (_) {
      if (!mounted || generation != _generation) return;
      // Every model intent needs the API; the bot never claims a local answer.
      state = state.copyWith(
        thinking: false,
        offline: true,
        turns: [
          ...state.turns,
          const BotTurn.notice(
              'The assistant needs a connection. Nothing here is answered offline.'),
        ],
      );
    }
  }

  /// "Not this" asks again with the cards already seen excluded.
  Future<void> reshuffle() =>
      send('Something else from the Wall', shuffle: true);

  /// Writes the confirmed capture card to the fridge. Only this does.
  Future<int> confirmCapture(List<BotCaptureItem> items) async {
    final store = _ref.read(pantryStoreProvider.notifier);
    var added = 0;
    for (final item in items) {
      await store.add(
        name: item.name,
        quantity: item.quantity,
        unit: PantryUnit.parse(item.unit),
        source: 'assistant',
      );
      added++;
    }
    if (!mounted) return added;
    state = state.copyWith(
      turns: [
        ...state.turns,
        BotTurn.notice(added == 1
            ? '1 item in the fridge.'
            : '$added items in the fridge.'),
      ],
    );
    return added;
  }

  /// Dividing a thread is not a message: it says where the conversation went.
  void insertDivider(String label) {
    state = state.copyWith(turns: [...state.turns, BotTurn.divider(label)]);
  }

  List<AssistantTurn> _history() {
    final turns = [
      for (final turn in state.turns)
        if (turn.kind == BotTurnKind.mine || turn.kind == BotTurnKind.answer)
          AssistantTurn(
            role: turn.kind == BotTurnKind.mine ? 'user' : 'assistant',
            text: turn.text,
          ),
    ];
    return turns.length <= 4 ? turns : turns.sublist(turns.length - 4);
  }

  Future<void> _remember(String role, String text) async {
    try {
      await _repo.add(
        thread: const BotThread.kitchen(),
        versionId: null,
        role: role,
        text: text,
      );
    } catch (_) {
      // Memory is best-effort: losing a line must not lose the answer.
    }
  }

  void addTurn(BotTurn turn) =>
      state = state.copyWith(turns: [...state.turns, turn]);
}

final botControllerProvider =
    StateNotifierProvider<BotController, BotState>((ref) => BotController(ref));

/// True when the app has no connection: the surface shows a slash on the orb
/// and one honest sentence, and no intent is offered as if it worked offline.
final botOfflineProvider = Provider<bool>((ref) {
  final status = ref.watch(syncStatusProvider);
  return status == SyncStatus.offline || status == SyncStatus.failed;
});
