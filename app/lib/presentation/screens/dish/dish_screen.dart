import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/shoku_text.dart';
import '../../../data/models/fridge_match.dart';
import '../../../data/mock/journal_data.dart';
import '../../../data/services/speech_service.dart';
import '../../state/journal_providers.dart';
import '../../state/journal_store.dart';
import '../../state/pantry_providers.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/status_badge.dart';
import '../../widgets/kit/step_ingredients.dart';
import '../assistant/recipe_chat_sheet.dart';
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
  String? _goneNote;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dish = ref.watch(dishProvider(widget.dishId));
    if (dish == null || dish.versions.isEmpty) {
      return _DishUnavailable(dishId: widget.dishId);
    }
    final inspected =
        ref.watch(inspectedVersionProvider(widget.dishId)).clamp(1, dish.versions.length);
    final version = dish.versions[inspected - 1];
    final stepLines = version.steps.isNotEmpty ? version.steps : dish.steps;
    final pantry = ref.watch(pantryStoreProvider);
    final matcher = FridgeMatcher(pantry);
    final coverage = FridgeCoverage(
      matches: [for (final line in version.ingredients) matcher.match(line)],
      lines: version.ingredients,
      unset: matcher.isUnset,
    );

    _noteIfVersionWent(dish, version, inspected);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
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
                          ],
                        ),
                      ),
                      const SizedBox(width: ShokuSpace.sm),
                      Text(
                        count(dish.cookCount, 'cook'),
                        style: ShokuType.stat
                            .copyWith(fontSize: 11, color: c.inkMuted),
                      ),
                    ],
                  ),
                  if (version.tags.contains('from video')) ...[
                    const SizedBox(height: ShokuSpace.xs),
                    Text(
                      'read from the video — amounts may be off',
                      key: const ValueKey('from-video-note'),
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
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
                child: Text('Start cook mode',
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
  void _noteIfVersionWent(Dish dish, RecipeVersion version, int inspected) {
    if (_lastVersionId != null &&
        _lastVersionId != version.id &&
        !dish.versions.any((v) => v.id == _lastVersionId)) {
      final goneNumber = int.tryParse(
              RegExp(r'(\d+)$').firstMatch(_lastVersionId!)?.group(1) ?? '') ??
          inspected;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _goneNote = 'v$goneNumber is gone — showing v$inspected');
        }
      });
    }
    _lastVersionId = version.id;
  }

  Widget _header(BuildContext context, Dish dish, RecipeVersion version) {
    final c = context.colors;
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
          IconButton(
            key: const ValueKey('dish-speak'),
            icon: Icon(Icons.volume_up, size: 17, color: c.inkMuted),
            tooltip: 'Read this recipe',
            onPressed: () => _speakAll(dish, version),
          ),
          ShokuPressable(
            key: const ValueKey('dish-ask'),
            onTap: () => showRecipeChat(context, dish: dish),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.hairline),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: c.accent),
                  const SizedBox(width: 5),
                  Text('ASK', style: ShokuType.label.copyWith(color: c.ink)),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            key: const ValueKey('dish-overflow'),
            icon: Icon(Icons.more_horiz, size: 19, color: c.inkMuted),
            tooltip: 'More',
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
              const PopupMenuItem(
                key: ValueKey('dish-menu-cook'),
                value: 'cooked',
                child: Text('I just cooked this'),
              ),
              PopupMenuItem(
                key: const ValueKey('dish-menu-status'),
                value: 'status',
                child: Text(dish.status == DishStatus.toCook
                    ? 'Mark as cooked'
                    : 'Mark as to cook'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _speakAll(Dish dish, RecipeVersion version) async {
    final steps = version.steps.isNotEmpty ? version.steps : dish.steps;
    await ref.read(speechServiceProvider).speak([
      dish.title,
      if (version.ingredients.isNotEmpty) version.ingredients.join(', '),
      for (var i = 0; i < steps.length; i++) 'Step ${i + 1}. ${steps[i]}',
    ].join('. '));
  }

  Widget _fridgeStrip(BuildContext context, Dish dish, FridgeCoverage coverage) {
    final c = context.colors;
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
            color: coverage.missing == 0 && !coverage.unset ? c.ready : c.inkMuted,
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
              child: Text('Set up your fridge',
                  style: ShokuType.label.copyWith(fontSize: 9.5, color: c.accent)),
            )
          else if (coverage.missing > 0)
            ShokuPressable(
              key: const ValueKey('fridge-add-missing'),
              onTap: () => _addMissing(coverage),
              child: Text(
                'Add ${coverage.missingNames.length} missing to list',
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
    final store = ref.read(pantryStoreProvider.notifier);
    final ids = await store.wantMany(names);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text('${count(ids.length, 'item')} added to your list'),
        action: SnackBarAction(
          label: 'Undo',
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
                      [
                        count(version.ingredients.length, 'ingredient'),
                        if (!coverage.unset && missing > 0) '$missing missing',
                      ].join(' · '),
                      style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                    ),
                  ),
                  PopupMenuButton<int>(
                    key: const ValueKey('version-picker'),
                    tooltip: 'Pick a version',
                    color: c.surface,
                    onSelected: (number) => ref
                        .read(inspectedVersionProvider(widget.dishId).notifier)
                        .state = number,
                    itemBuilder: (context) => [
                      for (var v = 1; v <= dish.versions.length; v++)
                        PopupMenuItem(
                          value: v,
                          child: Text(
                            'v$v${v == inspected ? ' · showing' : ''}',
                            style: ShokuType.bodySmall,
                          ),
                        ),
                    ],
                    child: Row(
                      children: [
                        Text('v$inspected',
                            style: ShokuType.stat
                                .copyWith(fontSize: 12, color: c.accent)),
                        Icon(Icons.arrow_drop_down, size: 18, color: c.inkMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_ingredientsOpen)
            for (var i = 0; i < version.ingredients.length; i++)
              _ingredientLine(context, version.ingredients[i], coverage.matches[i], i),
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
      padding: const EdgeInsets.symmetric(
          horizontal: ShokuSpace.md, vertical: 9),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(line,
                style: ShokuType.bodySmall.copyWith(color: c.ink)),
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

  Widget _steps(
      BuildContext context, Dish dish, RecipeVersion version, List<String> steps) {
    final c = context.colors;
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
                      [
                        count(steps.length, 'step'),
                        if (minutes > 0) '$minutes min',
                      ].join(' · '),
                      style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
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
                          style:
                              ShokuType.label.copyWith(color: c.inkMuted)),
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
                                onTap: () => ref
                                    .read(speechServiceProvider)
                                    .speak('Step ${s + 1}. ${steps[s]}'),
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
                                  'Ask about step ${s + 1}',
                                  style: ShokuType.label.copyWith(
                                      fontSize: 9, color: c.accent),
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
                  Text('HISTORY',
                      style: ShokuType.label.copyWith(color: c.inkMuted)),
                  const Spacer(),
                  Text(count(cooks.length, 'cook'),
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
                    ? Text('Not cooked yet. The first log becomes v1.',
                        style: ShokuType.bodySmall
                            .copyWith(color: c.inkMuted))
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final log in cooks)
                            ShokuChip(
                              'v${log.versionNumber} · ${log.outcome.label}',
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
                    Text('What altered',
                        style:
                            ShokuType.label.copyWith(color: c.inkMuted)),
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
                child: Text('Not cooked yet. The first log becomes v1.',
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
                                      '· ${_date(log.cookedAt)}'
                                      '${_chatEdited(dish, log.versionNumber) ? ' · from a chat edit' : ''}',
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
                                log.note.isEmpty ? 'No note' : log.note,
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

String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]}';

/// Shown when the dish is missing, was deleted, or is an import with nothing
/// extracted yet. Beats a `Bad state: No element` from indexing an empty list.
class _DishUnavailable extends StatelessWidget {
  final String dishId;
  const _DishUnavailable({required this.dishId});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
                  'This dish is not here',
                  style: ShokuType.title.copyWith(color: c.ink),
                ),
                const SizedBox(height: ShokuSpace.xs),
                Text(
                  'It may still be loading, or it was removed.',
                  textAlign: TextAlign.center,
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: ShokuSpace.lg),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Back to the journal'),
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

  String get _platformLabel =>
      switch ((version.originPlatform ?? '').toLowerCase()) {
        'instagram' => 'Instagram',
        'youtube' => 'YouTube',
        _ => 'the source',
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
    final handle = version.originHandle;
    final name = version.originCreator ?? 'Imported';

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
                        _platformLabel,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          ShokuType.bodySmall.copyWith(color: c.inkMuted),
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
                  Text('View the reel',
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
