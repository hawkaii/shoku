import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/labels.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/shoku_text.dart';
import '../../../data/models/fridge_match.dart';
import '../../../data/mock/journal_data.dart';
import '../../../data/services/speech_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../state/journal_providers.dart';
import '../../state/journal_store.dart';
import '../../state/pantry_providers.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/bot_orb.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/status_badge.dart';
import '../../widgets/kit/step_ingredients.dart';
import '../assistant/recipe_chat_sheet.dart';
import '../bot/bot_scope.dart';
import '../log/debrief_sheet.dart';

/// The dish, as a kitchen would hand it to you.
///
/// The order is deliberate: what it is, whether you can cook it tonight, then
/// the two lists folded away until you want them. The cook button never moves.
class DishScreen extends ConsumerStatefulWidget {
  final String dishId;
  const DishScreen({super.key, required this.dishId});

  @override
  ConsumerState<DishScreen> createState() => _DishScreenState();
}

class _DishScreenState extends ConsumerState<DishScreen> {
  bool _ingredientsOpen = false;
  bool _stepsOpen = false;
  bool _historyOpen = false;

  /// The version last rendered, for the one note the page has to say out loud:
  /// "v3 is gone — showing v4".
  String? _lastVersionId;
  int _lastNumber = 1;
  String? _goneNote;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final dish = ref.watch(dishProvider(widget.dishId));
    if (dish == null || dish.versions.isEmpty) {
      return _DishUnavailable(dishId: widget.dishId);
    }
    final inspected = ref
        .watch(inspectedVersionProvider(widget.dishId))
        .clamp(1, dish.versions.length);
    final version = dish.versions[inspected - 1];
    final stepLines = version.steps.isNotEmpty ? version.steps : dish.steps;
    final pantry = ref.watch(pantryStoreProvider);
    final matcher = FridgeMatcher(pantry);
    final coverage = FridgeCoverage(
      matches: [for (final line in version.ingredients) matcher.match(line)],
      lines: version.ingredients,
      unset: matcher.isUnset,
    );

    _noteIfVersionWent(dish, version, inspected, l10n);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _header(context, dish, version),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      ShokuSpace.lg,
                      ShokuSpace.sm,
                      ShokuSpace.lg,
                      ShokuSpace.lg,
                    ),
                    children: [
                      ShokuDishImage(
                        url: dish.coverUrl,
                        title: dish.title,
                        height: 140,
                        radius: ShokuRadius.card,
                        heroTag: true,
                      ),
                      const SizedBox(height: ShokuSpace.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dish.title,
                                    style: ShokuType.h1.copyWith(color: c.ink)),
                                if (dish.subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(dish.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: ShokuType.bodySmall
                                          .copyWith(color: c.inkMuted)),
                                ],
                                if (dish.isSample) ...[
                                  const SizedBox(height: 6),
                                  ShokuChip(l10n.labelSample,
                                      color: c.reward, filled: true),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.dishSampleGate,
                                    key: const ValueKey('sample-gate'),
                                    style: ShokuType.bodySmall
                                        .copyWith(color: c.inkMuted),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: ShokuSpace.sm),
                          Text(
                            l10n.dishCookCount(dish.cookCount),
                            style: ShokuType.stat
                                .copyWith(fontSize: 11, color: c.inkMuted),
                          ),
                        ],
                      ),
                      if (version.tags.contains('from video')) ...[
                        const SizedBox(height: ShokuSpace.xs),
                        Text(
                          l10n.dishFromVideoNote,
                          key: const ValueKey('from-video-note'),
                          style:
                              ShokuType.bodySmall.copyWith(color: c.inkMuted),
                        ),
                      ],
                      if (_goneNote != null) ...[
                        const SizedBox(height: ShokuSpace.xs),
                        Text(
                          _goneNote!,
                          key: const ValueKey('version-gone-note'),
                          style:
                              ShokuType.bodySmall.copyWith(color: c.inkMuted),
                        ),
                      ],
                      const SizedBox(height: ShokuSpace.md),
                      _fridgeStrip(context, dish, coverage),
                      const SizedBox(height: ShokuSpace.md),
                      _ingredients(context, dish, version, inspected, coverage),
                      const SizedBox(height: ShokuSpace.md),
                      _steps(context, dish, version, stepLines),
                      const SizedBox(height: ShokuSpace.md),
                      _history(context, dish, version),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 12,
              child: BotOrb(scope: BotScope(dishId: dish.id)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            ShokuSpace.lg,
            ShokuSpace.sm,
            ShokuSpace.lg,
            ShokuSpace.md,
          ),
          child: ShokuPressable(
            key: const ValueKey('cook-mode-button'),
            onTap: () => context.push('/cook/${widget.dishId}'),
            child: Container(
              width: double.infinity,
              // A fixed height, not padding: a bottom bar is laid out with the
              // screen's height available, and a bare Center would take it all.
              height: 50,
              decoration: BoxDecoration(
                gradient: ShokuGradients.crimsonPress,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                boxShadow: [
                  BoxShadow(
                      color: c.ink,
                      offset: ShokuStroke.brutalShadow,
                      blurRadius: 0),
                ],
              ),
              child: Center(
                child: Text(l10n.dishStartCookMode,
                    style: ShokuType.title
                        .copyWith(color: c.onAccent, fontSize: 14)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A version can disappear through a sync from another device. Saying so
  /// beats silently renumbering the page under the cook's eyes.
  void _noteIfVersionWent(
    Dish dish,
    RecipeVersion version,
    int inspected,
    AppLocalizations l10n,
  ) {
    if (_lastVersionId != null &&
        _lastVersionId != version.id &&
        !dish.versions.any((v) => v.id == _lastVersionId)) {
      final gone = _lastNumber;
      final showing = _numberOf(version, inspected);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _goneNote = l10n.dishVersionGone(gone, showing);
          });
        }
      });
    }
    _lastVersionId = version.id;
    _lastNumber = _numberOf(version, inspected);
  }

  /// Versions that came from a reel carry number 0; the page counts positions.
  int _numberOf(RecipeVersion version, int inspected) =>
      version.number > 0 ? version.number : inspected;

  Widget _header(BuildContext context, Dish dish, RecipeVersion version) {
    final c = context.colors;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShokuSpace.lg,
        ShokuSpace.sm,
        ShokuSpace.md,
        ShokuSpace.xs,
      ),
      child: Row(
        children: [
          ShokuPressable(
            key: const ValueKey('dish-back'),
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.hairline),
              ),
              child: Icon(Icons.arrow_back, size: 17, color: c.ink),
            ),
          ),
          const SizedBox(width: ShokuSpace.sm),
          StatusBadge(status: dish.status, cookCount: dish.cookCount),
          const Spacer(),
          ValueListenableBuilder<bool>(
            valueListenable: ref.read(speechServiceProvider).speaking,
            builder: (context, speaking, _) => IconButton(
              key: const ValueKey('dish-speak'),
              icon: Icon(
                  speaking ? Icons.stop_circle_outlined : Icons.volume_up,
                  size: 17,
                  color: speaking ? c.accent : c.inkMuted),
              tooltip: speaking ? l10n.dishStopReading : l10n.dishReadRecipe,
              onPressed: () => _speakAll(dish, version),
            ),
          ),
          PopupMenuButton<String>(
            key: const ValueKey('dish-overflow'),
            icon: Icon(Icons.more_horiz, size: 19, color: c.inkMuted),
            tooltip: l10n.dishMore,
            color: c.surface,
            onSelected: (value) {
              switch (value) {
                case 'cooked':
                  showDebriefSheet(context, dish: dish);
                case 'status':
                  final next = dish.status == DishStatus.toCook
                      ? DishStatus.cooked
                      : DishStatus.toCook;
                  ref
                      .read(journalStoreProvider.notifier)
                      .setStatus(widget.dishId, next);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                key: const ValueKey('dish-menu-cook'),
                value: 'cooked',
                child: Text(l10n.dishMenuCooked),
              ),
              PopupMenuItem(
                key: const ValueKey('dish-menu-status'),
                value: 'status',
                child: Text(dish.status == DishStatus.toCook
                    ? l10n.actionMarkCooked
                    : l10n.dishMarkToCook),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _speakAll(Dish dish, RecipeVersion version) async {
    final speech = ref.read(speechServiceProvider);
    if (speech.speaking.value) {
      await speech.stop();
      return;
    }
    final steps = version.steps.isNotEmpty ? version.steps : dish.steps;
    await speech.speak([
      dish.title,
      if (version.ingredients.isNotEmpty) version.ingredients.join(', '),
      for (var i = 0; i < steps.length; i++) 'Step ${i + 1}. ${steps[i]}',
    ].join('. '));
  }

  Widget _fridgeStrip(
      BuildContext context, Dish dish, FridgeCoverage coverage) {
    final c = context.colors;
    final l10n = context.l10n;
    return Container(
      key: const ValueKey('fridge-strip'),
      padding: const EdgeInsets.all(ShokuSpace.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.card),
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        children: [
          Icon(
            coverage.unset
                ? Icons.kitchen_outlined
                : coverage.missing == 0
                    ? Icons.check_circle_outline
                    : Icons.shopping_basket_outlined,
            size: 15,
            color:
                coverage.missing == 0 && !coverage.unset ? c.ready : c.inkMuted,
          ),
          const SizedBox(width: ShokuSpace.sm),
          Expanded(
            child: Text(
              coverage.strip,
              key: const ValueKey('fridge-strip-copy'),
              style: ShokuType.bodySmall.copyWith(color: c.ink),
            ),
          ),
          if (coverage.unset)
            TextButton(
              key: const ValueKey('fridge-setup'),
              onPressed: () => context.go('/pantry'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.dishSetUpFridge,
                  style:
                      ShokuType.label.copyWith(fontSize: 9.5, color: c.accent)),
            )
          else if (coverage.missing > 0)
            ShokuPressable(
              key: const ValueKey('fridge-add-missing'),
              onTap: () => _addMissing(coverage),
              child: Text(
                l10n.dishAddMissingToList(coverage.missingNames.length),
                style: ShokuType.label.copyWith(fontSize: 9.5, color: c.accent),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addMissing(FridgeCoverage coverage) async {
    final names = coverage.missingNames;
    if (names.isEmpty) return;
    final l10n = context.l10n;
    final store = ref.read(pantryStoreProvider.notifier);
    final ids = await store.wantMany(names);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.dishAddedToList(ids.length)),
        action: SnackBarAction(
          label: l10n.chatUndo,
          onPressed: () => store.removeMany(ids),
        ),
      ),
    );
  }

  Widget _ingredients(
    BuildContext context,
    Dish dish,
    RecipeVersion version,
    int inspected,
    FridgeCoverage coverage,
  ) {
    final c = context.colors;
    final l10n = context.l10n;
    final missing = coverage.missing;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.card),
        border: Border.all(color: c.hairline),
      ),
      child: Column(
        children: [
          InkWell(
            key: const ValueKey('ingredients-toggle'),
            onTap: () => setState(() => _ingredientsOpen = !_ingredientsOpen),
            borderRadius: BorderRadius.circular(ShokuRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(ShokuSpace.md),
              child: Row(
                children: [
                  Icon(Icons.egg_outlined, size: 15, color: c.inkMuted),
                  const SizedBox(width: ShokuSpace.sm),
                  Expanded(
                    child: Text(
                      metaLine([
                        l10n.dishIngredientsCount(version.ingredients.length),
                        if (!coverage.unset && missing > 0)
                          l10n.dishMissingCount(missing),
                      ]),
                      style:
                          ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                    ),
                  ),
                  PopupMenuButton<int>(
                    key: const ValueKey('version-picker'),
                    tooltip: l10n.dishPickVersion,
                    color: c.surface,
                    onSelected: (number) => ref
                        .read(inspectedVersionProvider(widget.dishId).notifier)
                        .state = number,
                    itemBuilder: (context) => [
                      for (var v = 1; v <= dish.versions.length; v++)
                        PopupMenuItem(
                          value: v,
                          child: Text(
                            v == inspected ? l10n.dishVersionShowing(v) : 'v$v',
                            style: ShokuType.bodySmall,
                          ),
                        ),
                    ],
                    child: Row(
                      children: [
                        Text('v$inspected',
                            style: ShokuType.stat
                                .copyWith(fontSize: 12, color: c.accent)),
                        Icon(Icons.arrow_drop_down,
                            size: 18, color: c.inkMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_ingredientsOpen)
            for (var i = 0; i < version.ingredients.length; i++)
              _ingredientLine(
                  context, version.ingredients[i], coverage.matches[i], i),
        ],
      ),
    );
  }

  Widget _ingredientLine(
      BuildContext context, String line, FridgeMatch match, int index) {
    final c = context.colors;
    final colour = switch (match.state) {
      FridgeState.inFridge => c.ready,
      FridgeState.some => c.reward,
      FridgeState.onList => c.inkMuted,
      FridgeState.missing => c.danger,
      FridgeState.notTracked => c.inkMuted,
    };
    return Container(
      key: ValueKey('ingredient-line-$index'),
      padding:
          const EdgeInsets.symmetric(horizontal: ShokuSpace.md, vertical: 9),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                Text(line, style: ShokuType.bodySmall.copyWith(color: c.ink)),
          ),
          const SizedBox(width: ShokuSpace.sm),
          Text(
            match.label,
            key: ValueKey('ingredient-fridge-$index'),
            style: ShokuType.label.copyWith(fontSize: 9, color: colour),
          ),
        ],
      ),
    );
  }

  Widget _steps(BuildContext context, Dish dish, RecipeVersion version,
      List<String> steps) {
    final c = context.colors;
    final l10n = context.l10n;
    final minutes = dish.minutes;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.card),
        border: Border.all(color: c.hairline),
      ),
      child: Column(
        children: [
          InkWell(
            key: const ValueKey('steps-toggle'),
            onTap: () => setState(() => _stepsOpen = !_stepsOpen),
            borderRadius: BorderRadius.circular(ShokuRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(ShokuSpace.md),
              child: Row(
                children: [
                  Icon(Icons.format_list_numbered, size: 15, color: c.inkMuted),
                  const SizedBox(width: ShokuSpace.sm),
                  Expanded(
                    child: Text(
                      metaLine([
                        l10n.dishStepsCount(steps.length),
                        if (minutes > 0) l10n.minutesShort(minutes),
                      ]),
                      style:
                          ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                    ),
                  ),
                  Icon(
                    _stepsOpen ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: c.inkMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_stepsOpen)
            for (var s = 0; s < steps.length; s++)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    ShokuSpace.md, 0, ShokuSpace.md, ShokuSpace.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text('${s + 1}',
                          style: ShokuType.label.copyWith(color: c.inkMuted)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(steps[s],
                              style: ShokuType.body.copyWith(color: c.ink)),
                          StepIngredientsLine(
                            ingredients: version.ingredients,
                            indices: version.stepIngredientLinks(s),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              GestureDetector(
                                key: ValueKey('step-speak-$s'),
                                onTap: () {
                                  final speech =
                                      ref.read(speechServiceProvider);
                                  if (speech.speaking.value) {
                                    speech.stop();
                                    return;
                                  }
                                  speech.speak('Step ${s + 1}. ${steps[s]}');
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Icon(Icons.volume_up,
                                    size: 14, color: c.inkMuted),
                              ),
                              const SizedBox(width: ShokuSpace.md),
                              GestureDetector(
                                key: ValueKey('step-ask-$s'),
                                onTap: () => showRecipeChat(context,
                                    dish: dish, stepIndex: s),
                                behavior: HitTestBehavior.opaque,
                                child: Text(
                                  l10n.dishAskAboutStep(s + 1),
                                  style: ShokuType.label
                                      .copyWith(fontSize: 9, color: c.accent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _history(BuildContext context, Dish dish, RecipeVersion version) {
    final c = context.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final recommended = dish.versions.last;
    final altered = recommended.changes
        .any((change) => change != 'First attempt' && change != 'No changes');
    final cooks = dish.cooks;

    return Container(
      key: const ValueKey('history-card'),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.card),
        border: Border.all(color: c.hairline),
      ),
      child: Column(
        children: [
          InkWell(
            key: const ValueKey('history-toggle'),
            onTap: () => setState(() => _historyOpen = !_historyOpen),
            borderRadius: BorderRadius.circular(ShokuRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(ShokuSpace.md),
              child: Row(
                children: [
                  Text(l10n.dishHistory,
                      style: ShokuType.label.copyWith(color: c.inkMuted)),
                  const Spacer(),
                  Text(l10n.dishCookCount(cooks.length),
                      style: ShokuType.stat
                          .copyWith(fontSize: 10, color: c.inkMuted)),
                  Icon(_historyOpen ? Icons.expand_less : Icons.expand_more,
                      size: 18, color: c.inkMuted),
                ],
              ),
            ),
          ),
          if (!_historyOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  ShokuSpace.md, 0, ShokuSpace.md, ShokuSpace.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: cooks.isEmpty
                    ? Text(l10n.dishNotCookedYet,
                        style: ShokuType.bodySmall.copyWith(color: c.inkMuted))
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final log in cooks)
                            ShokuChip(
                              l10n.dishHistoryEntry(log.versionNumber,
                                  outcomeLabel(l10n, log.outcome)),
                              color: log.outcome == CookOutcome.nailedIt
                                  ? c.ready
                                  : c.inkMuted,
                            ),
                        ],
                      ),
              ),
            )
          else ...[
            if (altered)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    ShokuSpace.md, 0, ShokuSpace.md, ShokuSpace.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dishWhatAltered,
                        style: ShokuType.label.copyWith(color: c.inkMuted)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final change in recommended.changes)
                          ShokuChip(change, color: c.reward, icon: Icons.bolt),
                      ],
                    ),
                  ],
                ),
              ),
            if (version.isImport)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    ShokuSpace.md, 0, ShokuSpace.md, ShokuSpace.sm),
                child: _ProvenanceCard(version: version),
              ),
            if (cooks.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    ShokuSpace.md, 0, ShokuSpace.md, ShokuSpace.md),
                child: Text(l10n.dishNotCookedYet,
                    style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
              )
            else
              for (final log in cooks)
                ShokuPressable(
                  onTap: () => ref
                      .read(inspectedVersionProvider(widget.dishId).notifier)
                      .state = log.versionNumber,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(
                        ShokuSpace.md, 0, ShokuSpace.md, ShokuSpace.sm),
                    padding: const EdgeInsets.all(ShokuSpace.sm),
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(ShokuRadius.card),
                      border: Border.all(color: c.hairline),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: ShokuDishImage(
                              url: log.photoUrl, title: dish.title, radius: 6),
                        ),
                        const SizedBox(width: ShokuSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('v${log.versionNumber}',
                                      style: ShokuType.stat.copyWith(
                                          fontSize: 11, color: c.accent)),
                                  const SizedBox(width: ShokuSpace.xs),
                                  Text(
                                      '· ${_date(locale, log.cookedAt)}'
                                      '${_chatEdited(dish, log.versionNumber) ? ' · ${l10n.dishFromChatEdit}' : ''}',
                                      style: ShokuType.stat.copyWith(
                                          fontSize: 11, color: c.inkMuted)),
                                  const Spacer(),
                                  ShokuChip(log.outcome.label,
                                      color: log.outcome == CookOutcome.nailedIt
                                          ? c.ready
                                          : c.inkMuted),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                log.note.isEmpty ? l10n.dishNoNote : log.note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: ShokuType.bodySmall
                                    .copyWith(color: c.inkMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

bool _chatEdited(Dish dish, int versionNumber) {
  for (final version in dish.versions) {
    if (version.number == versionNumber) return version.tags.contains('chat');
  }
  return false;
}

String _date(String locale, DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${DateFormat.MMM(locale).format(d)}';

/// Shown when the dish is missing, was deleted, or is an import with nothing
/// extracted yet. Beats a `Bad state: No element` from indexing an empty list.
class _DishUnavailable extends StatelessWidget {
  final String dishId;
  const _DishUnavailable({required this.dishId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: c.canvas,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.dishUnavailableTitle,
                  style: ShokuType.title.copyWith(color: c.ink),
                ),
                const SizedBox(height: ShokuSpace.xs),
                Text(
                  l10n.dishUnavailableBody,
                  textAlign: TextAlign.center,
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: ShokuSpace.lg),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(l10n.dishBackToJournal),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Where an imported version came from: a person, on a platform, at a link.
///
/// This is the difference between a recipe that arrived from the internet and
/// one that belongs to someone — so it names the creator and gives a way back
/// to the original.
class _ProvenanceCard extends StatelessWidget {
  final RecipeVersion version;

  const _ProvenanceCard({required this.version});

  String _platformLabel(AppLocalizations l10n) =>
      switch ((version.originPlatform ?? '').toLowerCase()) {
        'instagram' => 'Instagram',
        'youtube' => 'YouTube',
        _ => l10n.dishTheSource,
      };

  Future<void> _open(BuildContext context) async {
    final raw = version.originUrl;
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final handle = version.originHandle;
    final name = version.originCreator ?? l10n.dishImported;

    return Container(
      padding: const EdgeInsets.all(ShokuSpace.md),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(ShokuRadius.card),
        border: Border.all(color: c.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // A neutral glyph, not the platform's logo: attribution without
              // pretending to be the app we are linking to.
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: c.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.hairline),
                ),
                child:
                    Icon(Icons.videocam_outlined, size: 15, color: c.inkMuted),
              ),
              const SizedBox(width: ShokuSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          ShokuType.title.copyWith(color: c.ink, fontSize: 13),
                    ),
                    Text(
                      [
                        if (handle != null && handle.isNotEmpty) handle,
                        _platformLabel(l10n),
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (version.originUrl != null && version.originUrl!.isNotEmpty) ...[
            const SizedBox(height: ShokuSpace.xs),
            TextButton(
              onPressed: () => _open(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.dishViewReel,
                      style: ShokuType.label.copyWith(color: c.accent)),
                  const SizedBox(width: 4),
                  Icon(Icons.north_east, size: 13, color: c.accent),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
