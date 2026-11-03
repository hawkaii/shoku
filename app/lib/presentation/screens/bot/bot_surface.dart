import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/models/feed_item.dart';
import '../../../data/mock/journal_data.dart';
import '../../../data/services/assistant_service.dart';
import '../../state/bot_providers.dart';
import '../../state/journal_providers.dart';
import '../../state/pantry_providers.dart';
import '../assistant/recipe_chat_sheet.dart';
import '../../widgets/kit/bot_mark.dart';
import '../../widgets/kit/foundation.dart';
import '../wall/feed_detail_sheet.dart';
import 'bot_scope.dart';
import 'scope_switcher.dart';

/// The one assistant, as a drawer over the shell.
///
/// It is a sheet rather than a page: the cook keeps their place. Dragged up it
/// is tall enough for cards; dragged down it is a mini-bar with the last two
/// turns; swiped away it is the orb again, with the draft and thread intact.
Future<void> showBotSheet(BuildContext context, {BotScope? scope}) {
  final container = ProviderScope.containerOf(context);
  final BotScope target = scope ?? container.read<BotScope>(botScopeProvider);
  if (!target.isKitchen) return showRecipeChat(context, dish: _dish(context, target));
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const BotSurface(),
  );
}

Dish _dish(BuildContext context, BotScope scope) {
  final container = ProviderScope.containerOf(context);
  final dish = container.read(dishProvider(scope.dishId!));
  if (dish == null) throw StateError('No dish ${scope.dishId}');
  return dish;
}

enum BotSurfaceMode { normal, tall, mini }

class BotSurface extends ConsumerStatefulWidget {
  const BotSurface({super.key});

  @override
  ConsumerState<BotSurface> createState() => _BotSurfaceState();
}

class _BotSurfaceState extends ConsumerState<BotSurface> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  BotSurfaceMode _mode = BotSurfaceMode.normal;
  double _drag = 0;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(botControllerProvider).draft;
    if (draft.isNotEmpty) _input.text = draft;
    // Reading is a state change, and providers are not modified during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(botControllerProvider.notifier).markRead();
      _scrollToLatest();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic);
    });
  }

  void _send() {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    HapticFeedback.selectionClick();
    if (!_destructive(text)) {
      ref.read(botControllerProvider.notifier).send(text);
    }
    _scrollToLatest();
  }

  /// Destructive asks are never executed here: they name the real flow instead.
  bool _destructive(String text) {
    final lower = text.toLowerCase();
    const verbs = ['delete', 'remove the dish', 'reset', 'erase', 'clear my'];
    if (!verbs.any(lower.contains)) return false;
    ref.read(botControllerProvider.notifier).addTurn(
          BotTurn.notice(context.l10n.botDestructiveRefusal),
        );
    ref.read(botControllerProvider.notifier).setDraft('');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = ref.watch(botControllerProvider);
    final offline = ref.watch(botOfflineProvider);
    final fraction = switch (_mode) {
      BotSurfaceMode.mini => 0.24,
      BotSurfaceMode.tall => 0.92,
      _ => 0.62,
    };

    return GestureDetector(
      onVerticalDragStart: (_) => _drag = 0,
      onVerticalDragUpdate: (details) => _drag += details.delta.dy,
      onVerticalDragEnd: (_) {
        if (_drag > 120) {
          if (_mode == BotSurfaceMode.normal) {
            setState(() => _mode = BotSurfaceMode.mini);
          } else {
            Navigator.of(context).maybePop();
          }
        } else if (_drag < -120) {
          setState(() => _mode = BotSurfaceMode.tall);
        }
        _drag = 0;
      },
      child: AnimatedContainer(
        key: const ValueKey('bot-sheet'),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: MediaQuery.of(context).size.height * fraction,
        decoration: BoxDecoration(
          color: c.canvas,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(ShokuRadius.sheet)),
          border: Border.all(color: c.hairline),
        ),
        child: Column(
          children: [
            _header(context, state),
            if (offline) _offlineLine(context),
            if (_mode == BotSurfaceMode.mini)
              _mini(context, state)
            else ...[
              Expanded(child: _thread(context, state)),
              _composer(context, state, offline),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, BotState state) {
    final c = context.colors;
    final l10n = context.l10n;
    final scope = ref.watch(botScopeProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          ShokuSpace.lg, ShokuSpace.sm, ShokuSpace.sm, ShokuSpace.xs),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: ShokuSpace.sm),
            decoration: BoxDecoration(
                color: c.hairline, borderRadius: BorderRadius.circular(2)),
          ),
          Row(
            children: [
              GestureDetector(
                key: const ValueKey('bot-scope-chip'),
                onTap: () => showScopeSwitcher(context),
                child: ShokuChip(
                  botScopeLabel(ref, scope, l10n),
                  icon: Icons.expand_more,
                  color: c.accent,
                ),
              ),
              const Spacer(),
              GestureDetector(
                key: const ValueKey('bot-mini'),
                onTap: () => setState(() => _mode = _mode == BotSurfaceMode.mini
                    ? BotSurfaceMode.normal
                    : BotSurfaceMode.mini),
                child: Text(
                  _mode == BotSurfaceMode.mini ? l10n.botOpen : l10n.botMinimise,
                  style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted),
                ),
              ),
              const SizedBox(width: ShokuSpace.md),
              GestureDetector(
                key: const ValueKey('bot-close'),
                onTap: () => Navigator.of(context).maybePop(),
                child: Icon(Icons.close, size: 18, color: c.inkMuted),
              ),
            ],
          ),
          if (_mode != BotSurfaceMode.mini)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                key: const ValueKey('bot-new-chat'),
                onTap: () => ref.read(botControllerProvider.notifier).newChat(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(top: ShokuSpace.xs),
                  child: Text(l10n.botNewChat,
                      style: ShokuType.label
                          .copyWith(fontSize: 9.5, color: c.inkMuted)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _offlineLine(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          ShokuSpace.lg, 0, ShokuSpace.lg, ShokuSpace.sm),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 13, color: c.inkMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              context.l10n.botOfflineLine,
              key: const ValueKey('bot-offline'),
              style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mini(BuildContext context, BotState state) {
    final c = context.colors;
    final last = state.turns
        .where((t) => t.kind == BotTurnKind.mine || t.kind == BotTurnKind.answer)
        .toList();
    final shown = last.length <= 2 ? last : last.sublist(last.length - 2);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.lg),
        child: Column(
          key: const ValueKey('bot-mini-turns'),
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final turn in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  turn.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ShokuType.bodySmall.copyWith(
                      color: turn.kind == BotTurnKind.mine
                          ? c.ink
                          : c.inkMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _thread(BuildContext context, BotState state) {
    final c = context.colors;
    final l10n = context.l10n;
    final starters = ref.watch(botStartersProvider);
    final stocked = ref
        .watch(pantryStoreProvider)
        .where((item) => !item.wanted)
        .length;
    final starterLabels = stocked == 0
        ? [l10n.botStarterFridge, l10n.botStarterWall, l10n.botStarterPhoto]
        : [l10n.botStarterDinner(stocked)];
    return ListView(
      controller: _scroll,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.lg),
      children: [
        if (state.thinking)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: ShokuSpace.xs),
              child: Text(l10n.botThinking,
                  key: const ValueKey('bot-thinking'),
                  style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
            ),
          ),
        for (final turn in state.turns.reversed) _turn(context, turn),
        // Reversed list: the last child is at the top. The starters are
        // written in reading order, so reverse them to keep it.
        if (state.turns.isEmpty && !state.thinking) ...[
          // First open: the mark, at 32, before the three doors.
          const Padding(
            padding: EdgeInsets.only(bottom: ShokuSpace.sm),
            child: Center(
              child: BotMark(
                key: ValueKey('bot-mark-empty'),
                size: 32,
              ),
            ),
          ),
          for (var i = starters.length - 1; i >= 0; i--)
            _starter(
              context,
              starters[i],
              i < starterLabels.length ? starterLabels[i] : starters[i],
            ),
        ],
      ],
    );
  }

  Widget _starter(BuildContext context, String prompt, String label) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: ShokuSpace.sm),
      child: GestureDetector(
        onTap: () {
          ref.read(botControllerProvider.notifier).send(prompt);
          _scrollToLatest();
        },
        child: Container(
          key: ValueKey('bot-starter-${label.hashCode}'),
          width: double.infinity,
          padding: const EdgeInsets.all(ShokuSpace.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(ShokuRadius.card),
            border: Border.all(color: c.hairline),
          ),
          child: Row(
            children: [
              const BotMark(
                key: ValueKey('bot-mark-starter'),
                size: 14,
              ),
              const SizedBox(width: ShokuSpace.sm),
              Flexible(
                child: Text(label,
                    style: ShokuType.bodySmall.copyWith(color: c.ink)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _turn(BuildContext context, BotTurn turn) {
    final c = context.colors;
    final l10n = context.l10n;
    switch (turn.kind) {
      case BotTurnKind.mine:
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(top: ShokuSpace.sm),
            padding: const EdgeInsets.all(ShokuSpace.md),
            decoration: BoxDecoration(
              color: c.ink,
              borderRadius: BorderRadius.circular(ShokuRadius.card),
            ),
            child: Text(turn.text,
                style: ShokuType.bodySmall.copyWith(color: c.canvas)),
          ),
        );
      case BotTurnKind.notice:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: ShokuSpace.xs),
          child: Text(
            turn.text == 'cap'
                ? l10n.botCapNotice
                : turn.text == 'offline'
                    ? l10n.botOfflineNotice
                    : turn.text == 'server'
                        ? l10n.botServerNotice
                        : turn.text == 'signin'
                            ? l10n.botSignInNotice
                            : turn.text == 'added'
                                ? l10n.botAddedToFridge(turn.count ?? 0)
                                : turn.text,
            key: const ValueKey('bot-notice'),
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
        );
      case BotTurnKind.choices:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: ShokuSpace.xs),
          child: Text(
            l10n.botWhichDish(turn.choices.join(' · ')),
            key: const ValueKey('bot-choices'),
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
        );
      case BotTurnKind.divider:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: ShokuSpace.sm),
          child: Row(
            children: [
              Expanded(child: Divider(color: c.hairline, height: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.sm),
                child: Text(turn.text,
                    key: const ValueKey('bot-divider'),
                    style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
              ),
              Expanded(child: Divider(color: c.hairline, height: 1)),
            ],
          ),
        );
      case BotTurnKind.suggestions:
        return _suggestions(context, turn.suggestions);
      case BotTurnKind.capture:
        return _capture(context, turn.items);
      case BotTurnKind.answer:
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(top: ShokuSpace.sm),
            padding: const EdgeInsets.all(ShokuSpace.md),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(ShokuRadius.card),
              border: Border.all(color: c.hairline),
            ),
            child: Text(turn.text,
                key: const ValueKey('bot-answer'),
                style: ShokuType.bodySmall.copyWith(color: c.ink)),
          ),
        );
    }
  }

  Widget _suggestions(BuildContext context, List<BotSuggestion> cards) {
    final c = context.colors;
    final l10n = context.l10n;
    return Column(
      key: const ValueKey('bot-suggestions'),
      children: [
        for (final card in cards)
          Container(
            key: ValueKey('bot-card-${card.shortcode}'),
            margin: const EdgeInsets.only(top: ShokuSpace.sm),
            padding: const EdgeInsets.all(ShokuSpace.md),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(ShokuRadius.card),
              border: Border.all(color: c.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title,
                    style: ShokuType.title.copyWith(color: c.ink, fontSize: 14)),
                const SizedBox(height: 2),
                Text(l10n.botSuggestionMeta(card.source, card.have, card.total),
                    style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
                if (card.missing.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final missing in card.missing.take(4))
                        ShokuChip(missing, color: c.inkMuted),
                    ],
                  ),
                ],
                const SizedBox(height: ShokuSpace.sm),
                Row(
                  children: [
                    _cardAction(context, l10n.botOpen, () {
                      Navigator.of(context).maybePop();
                      showFeedDetail(context, _asFeedItem(card));
                    }, primary: true),
                    const SizedBox(width: ShokuSpace.sm),
                    if (card.missing.isNotEmpty)
                      _cardAction(
                        context,
                        l10n.botAddMissing(card.missing.length),
                        () async {
                          await ref
                              .read(pantryStoreProvider.notifier)
                              .wantMany(card.missing);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(l10n
                                  .botAddedToList(card.missing.length))));
                        },
                      ),
                    const Spacer(),
                    GestureDetector(
                      key: ValueKey('bot-card-not-this-${card.shortcode}'),
                      onTap: () {
                        ref.read(botControllerProvider.notifier).reshuffle();
                        _scrollToLatest();
                      },
                      child: Text(l10n.botNotThis,
                          style: ShokuType.label
                              .copyWith(fontSize: 9, color: c.inkMuted)),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cardAction(BuildContext context, String label, VoidCallback onTap,
      {bool primary = false}) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: primary ? c.accent : c.surfaceAlt,
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
        ),
        child: Text(label,
            style: ShokuType.label.copyWith(
                fontSize: 9.5, color: primary ? c.onAccent : c.ink)),
      ),
    );
  }

  Widget _capture(BuildContext context, List<BotCaptureItem> items) {
    final c = context.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Container(
      key: const ValueKey('bot-capture-card'),
      margin: const EdgeInsets.only(top: ShokuSpace.sm),
      padding: const EdgeInsets.all(ShokuSpace.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.card),
        border: Border.all(color: c.ink, width: ShokuStroke.brutal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.botAddToFridgeQuestion,
              style: ShokuType.title.copyWith(color: c.ink, fontSize: 14)),
          const SizedBox(height: 4),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '${item.name} · ${_amountOf(item, l10n, locale)}',
                style: ShokuType.bodySmall.copyWith(color: c.ink),
              ),
            ),
          const SizedBox(height: ShokuSpace.sm),
          _cardAction(
              context, l10n.botAddCountToFridge(items.length), () async {
            final added =
                await ref.read(botControllerProvider.notifier).confirmCapture(items);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.botAddedToFridge(added))));
          }, primary: true),
        ],
      ),
    );
  }

  static String _amountOf(
      BotCaptureItem item, AppLocalizations l10n, String locale) {
    if (item.quantity == null) return l10n.botAmountUnknown;
    final number =
        NumberFormat.decimalPattern(locale).format(item.quantity);
    return item.unit == null ? number : '$number ${item.unit}';
  }

  Widget _composer(BuildContext context, BotState state, bool offline) {
    final c = context.colors;
    final l10n = context.l10n;
    final blocked = offline || state.cap || state.thinking;
    return Padding(
      padding: EdgeInsets.fromLTRB(ShokuSpace.lg, ShokuSpace.xs,
          ShokuSpace.lg, MediaQuery.of(context).viewInsets.bottom + ShokuSpace.md),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.hairline),
              ),
              child: TextField(
                key: const ValueKey('bot-input'),
                controller: _input,
                enabled: !blocked,
                onSubmitted: (_) => _send(),
                onChanged: (value) =>
                    ref.read(botControllerProvider.notifier).setDraft(value),
                style: ShokuType.bodySmall,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: state.cap
                      ? l10n.botOutOfQuestions
                      : offline
                          ? l10n.botNoConnection
                          : l10n.botAskKitchen,
                ),
              ),
            ),
          ),
          const SizedBox(width: ShokuSpace.sm),
          GestureDetector(
            key: const ValueKey('bot-send'),
            onTap: blocked ? null : _send,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: ShokuGradients.crimsonPress,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.ink, width: ShokuStroke.brutal),
              ),
              child: Icon(Icons.arrow_upward, size: 18, color: c.onAccent),
            ),
          ),
        ],
      ),
    );
  }

  static FeedItem _asFeedItem(BotSuggestion card) => FeedItem(
        shortcode: card.shortcode,
        title: card.title,
        thumbnailUrl: card.thumbnailUrl,
        creator: card.creator,
        creatorHandle: null,
        platform: null,
        steps: const [],
        tags: const [],
        url: card.url,
      );
}
