import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/shoku_text.dart';
import '../../../data/models/pantry_item.dart';
import '../../state/pantry_providers.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/plate_mark.dart';
import '../wall/feed_detail_sheet.dart';
import 'pantry_edit_sheet.dart';

/// The kitchen's own shelf: what is here, not what a recipe says.
///
/// The pantry is a confirmed layer beside the recipe — no recipe line is ever
/// rewritten from it, and nothing enters stock without passing the review.
/// The fridge is a destination in the tab bar, not a page pushed over it.
class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final _search = TextEditingController();
  String _query = '';
  bool _selecting = false;
  final _selected = <String>{};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggleSelecting() => setState(() {
        _selecting = !_selecting;
        if (!_selecting) _selected.clear();
      });

  void _toggle(PantryItem item) => setState(() {
        if (!_selecting) _selecting = true;
        if (!_selected.remove(item.id)) _selected.add(item.id);
      });

  Future<void> _deleteSelected() async {
    final ids = _selected.toList();
    if (ids.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _selected.clear();
      _selecting = false;
    });
    await ref.read(pantryStoreProvider.notifier).removeMany(ids);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${count(ids.length, 'item')} deleted')),
    );
  }

  /// The amount a step changes. Weight and volume move in the unit a cook
  /// would say out loud; counts move by one.
  static double stepFor(PantryUnit? unit) => switch (unit) {
        PantryUnit.g || PantryUnit.ml => 50,
        PantryUnit.kg || PantryUnit.l => 0.5,
        _ => 1,
      };

  Future<void> _nudge(PantryItem item, int direction) async {
    if (item.quantity == null) return;
    final step = stepFor(item.unit);
    final next =
        (item.quantity! + step * direction).clamp(0.0, double.infinity);
    await ref.read(pantryStoreProvider.notifier).save(item.copyWith(
          quantity: next,
          wanted: false,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = ref.watch(pantryStoreProvider);
    final visible = _query.isEmpty
        ? items
        : items
            .where((i) => i.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();
    final toBuy = visible.where((i) => i.wanted).toList();
    final inStock = visible.where((i) => !i.wanted).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                ShokuSpace.lg,
                ShokuSpace.sm,
                ShokuSpace.lg,
                ShokuSpace.tabBarClearance(context),
              ),
              children: [
                Row(
                  children: [
                    Text('Fridge', style: ShokuType.h1.copyWith(color: c.ink)),
                    const SizedBox(width: ShokuSpace.sm),
                    Text(count(items.length, 'item'),
                        style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                    const Spacer(),
                    if (_selecting)
                      Text('${_selected.length} selected',
                          key: const ValueKey('pantry-selected-count'),
                          style: ShokuType.bodySmall.copyWith(color: c.ink))
                    else
                      ShokuPressable(
                        key: const ValueKey('pantry-edit-toggle'),
                        onTap: items.isEmpty ? null : _toggleSelecting,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ShokuSpace.sm,
                            vertical: ShokuSpace.xs,
                          ),
                          child: Text('Edit',
                              style: ShokuType.bodySmall
                                  .copyWith(color: c.inkMuted)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: ShokuSpace.md),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: ShokuSpace.md),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(ShokuRadius.chip),
                    border: Border.all(color: c.hairline),
                  ),
                  child: TextField(
                    controller: _search,
                    onChanged: (value) => setState(() => _query = value),
                    style: ShokuType.bodySmall.copyWith(color: c.ink),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search ${count(items.length, 'item')}',
                      hintStyle:
                          ShokuType.bodySmall.copyWith(color: c.inkMuted),
                    ),
                  ),
                ),
                const SizedBox(height: ShokuSpace.md),
                const ShokuLabel('cook from your fridge'),
                const SizedBox(height: ShokuSpace.sm),
                _Shelf(items: items),
                if (toBuy.isNotEmpty) ...[
                  const SizedBox(height: ShokuSpace.lg),
                  const ShokuLabel('to buy'),
                  const SizedBox(height: ShokuSpace.sm),
                  for (final item in toBuy)
                    _Row(
                      item: item,
                      selecting: _selecting,
                      selected: _selected.contains(item.id),
                      onTap: () => _selecting
                          ? _toggle(item)
                          : item.wanted
                              ? _checkedOff(item)
                              : showPantryEditSheet(context, item),
                      onLongPress: () => _toggle(item),
                      onStep: (direction) => _nudge(item, direction),
                    ),
                ],
                if (inStock.isNotEmpty) ...[
                  const SizedBox(height: ShokuSpace.lg),
                  const ShokuLabel('in the fridge'),
                  const SizedBox(height: ShokuSpace.sm),
                  for (final item in inStock)
                    _Row(
                      item: item,
                      selecting: _selecting,
                      selected: _selected.contains(item.id),
                      onTap: () => _selecting
                          ? _toggle(item)
                          : showPantryEditSheet(context, item),
                      onLongPress: () => _toggle(item),
                      onStep: (direction) => _nudge(item, direction),
                    ),
                ],
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: ShokuSpace.xxl),
                    child: Column(
                      children: [
                        const PlateMark(size: 90),
                        const SizedBox(height: ShokuSpace.sm),
                        Text(
                          'Nothing in the fridge yet. Photograph a receipt, or just tell me what’s in it.',
                          key: const ValueKey('pantry-empty'),
                          textAlign: TextAlign.center,
                          style:
                              ShokuType.bodySmall.copyWith(color: c.inkMuted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_selecting)
            _SelectionBar(
              count: _selected.length,
              onDelete: _selected.isEmpty ? null : _deleteSelected,
              onCancel: _toggleSelecting,
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ShokuSpace.lg,
                ShokuSpace.sm,
                ShokuSpace.lg,
                ShokuSpace.md,
              ),
              child: ShokuPressable(
                key: const ValueKey('pantry-add'),
                onTap: () => context.push('/pantry/add'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: ShokuGradients.crimsonPress,
                    borderRadius: BorderRadius.circular(ShokuRadius.chip),
                    border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                  ),
                  child: Center(
                    child: Text('Add items',
                        style: ShokuType.title
                            .copyWith(color: c.onAccent, fontSize: 14)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _checkedOff(PantryItem item) async {
    final controller = TextEditingController();
    final amount = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How much?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '2 kg'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (amount == null) return;
    final parsed = PantryParser.parseLine('$amount ${item.name}');
    await ref.read(pantryStoreProvider.notifier).save(
          item.copyWith(
            wanted: false,
            quantity: parsed.quantity,
            unit: parsed.unit,
            clearQuantity: parsed.quantity == null,
          ),
        );
  }
}

/// One line of stock. Tap edits, long-press starts a selection, and the stepper
/// is the common case without any sheet at all.
class _Row extends ConsumerWidget {
  const _Row({
    required this.item,
    required this.selecting,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onStep,
  });

  final PantryItem item;
  final bool selecting;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Dismissible(
      key: ValueKey('pantry-dismiss-${item.id}'),
      direction:
          selecting ? DismissDirection.none : DismissDirection.endToStart,
      onDismissed: (_) =>
          ref.read(pantryStoreProvider.notifier).remove(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: ShokuSpace.md),
        color: c.danger,
        child:
            Text('Delete', style: ShokuType.label.copyWith(color: c.onAccent)),
      ),
      child: Semantics(
        selected: selected,
        child: ShokuPressable(
          key: ValueKey('pantry-row-${item.name}'),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.hairline)),
            ),
            child: Row(
              children: [
                if (selecting)
                  Padding(
                    padding: const EdgeInsets.only(right: ShokuSpace.xs),
                    child: Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      key: ValueKey('pantry-check-${item.name}'),
                      size: 18,
                      color: selected ? c.accent : c.inkMuted,
                    ),
                  )
                else
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: ShokuSpace.sm),
                    decoration: BoxDecoration(
                      color: _sourceColour(item.source, c),
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(item.name,
                      style: ShokuType.body.copyWith(color: c.ink)),
                ),
                if (!selecting)
                  _Stepper(
                    item: item,
                    onStep: onStep,
                    onEdit: onTap,
                  )
                else
                  Text(item.amountLabel,
                      style: ShokuType.stat
                          .copyWith(fontSize: 11, color: c.inkMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _sourceColour(String source, dynamic c) => switch (source) {
        'photo' => c.reward,
        'voice' => c.ready,
        _ => c.inkMuted,
      };
}

class _Stepper extends StatelessWidget {
  const _Stepper(
      {required this.item, required this.onStep, required this.onEdit});

  final PantryItem item;
  final ValueChanged<int> onStep;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (item.quantity == null) {
      return ShokuPressable(
        key: ValueKey('pantry-set-amount-${item.name}'),
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: ShokuSpace.sm, vertical: 4),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(ShokuRadius.chip),
            border: Border.all(color: c.hairline),
          ),
          child: Text('set amount',
              style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepButton(context, '−', ValueKey('pantry-minus-${item.name}'),
            () => onStep(-1)),
        SizedBox(
          width: 70,
          child: Text(
            item.amountLabel,
            key: ValueKey('pantry-amount-${item.name}'),
            textAlign: TextAlign.center,
            style: ShokuType.stat.copyWith(fontSize: 12, color: c.ink),
          ),
        ),
        _stepButton(context, '+', ValueKey('pantry-plus-${item.name}'),
            () => onStep(1)),
      ],
    );
  }

  Widget _stepButton(
      BuildContext context, String label, Key key, VoidCallback onTap) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label == '−' ? 'Less ${item.name}' : 'More ${item.name}',
      child: GestureDetector(
        key: key,
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(ShokuRadius.chip),
            border: Border.all(color: c.hairline),
          ),
          child: Text(label,
              style: ShokuType.title.copyWith(fontSize: 14, color: c.ink)),
        ),
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.count,
    required this.onDelete,
    required this.onCancel,
  });

  final int count;
  final VoidCallback? onDelete;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShokuSpace.lg,
        ShokuSpace.sm,
        ShokuSpace.lg,
        ShokuSpace.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: ShokuPressable(
              key: const ValueKey('pantry-cancel-selection'),
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(ShokuRadius.chip),
                  border: Border.all(color: c.hairline),
                ),
                child: Center(
                  child: Text('Cancel',
                      style:
                          ShokuType.title.copyWith(fontSize: 14, color: c.ink)),
                ),
              ),
            ),
          ),
          const SizedBox(width: ShokuSpace.sm),
          Expanded(
            flex: 2,
            child: ShokuPressable(
              key: const ValueKey('pantry-delete-selected'),
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: c.danger,
                  borderRadius: BorderRadius.circular(ShokuRadius.chip),
                  border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                ),
                child: Center(
                  child: Text(count == 0 ? 'Select items' : 'Delete $count',
                      style: ShokuType.title
                          .copyWith(color: c.onAccent, fontSize: 14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Cook from your pantry": Wall reels scored against this shelf, plus the
/// journal dishes that need the least. Empty is a normal state while the
/// endpoint is not deployed.
class _Shelf extends ConsumerWidget {
  const _Shelf({required this.items});

  final List<PantryItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final suggestions = ref.watch(suggestionsProvider);

    return suggestions.when(
      loading: () => const SizedBox(height: 40),
      error: (_, __) => _quiet(c),
      data: (reels) {
        if (reels.isEmpty) return _quiet(c);
        return SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: reels.length,
            separatorBuilder: (_, __) => const SizedBox(width: ShokuSpace.sm),
            itemBuilder: (context, i) {
              final reel = reels[i];
              return GestureDetector(
                key: ValueKey('suggestion-${reel.shortcode}'),
                onTap: () => showFeedDetail(context, reel.asFeedItem),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(ShokuSpace.sm),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(ShokuRadius.card),
                    border: Border.all(color: c.hairline),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: ShokuDishImage(
                            url: reel.thumbnailUrl,
                            title: reel.title,
                            radius: ShokuRadius.media),
                      ),
                      const SizedBox(width: ShokuSpace.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(reel.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: ShokuType.title
                                    .copyWith(color: c.ink, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(reel.scoreLabel,
                                key: const ValueKey('suggestion-score'),
                                style: ShokuType.label
                                    .copyWith(fontSize: 9, color: c.inkMuted)),
                            if (reel.missing.isNotEmpty)
                              GestureDetector(
                                key: ValueKey(
                                    'suggestion-buy-${reel.shortcode}'),
                                onTap: () async {
                                  for (final name in reel.missing) {
                                    await ref
                                        .read(pantryStoreProvider.notifier)
                                        .want(name);
                                  }
                                },
                                child: Text('+ ${reel.missing.length} to buy',
                                    style: ShokuType.label.copyWith(
                                        fontSize: 9, color: c.accent)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _quiet(dynamic c) => Text(
        'Nothing to suggest yet — add a few items and I will match walls and your own dishes.',
        key: const ValueKey('shelf-empty'),
        style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
      );
}
