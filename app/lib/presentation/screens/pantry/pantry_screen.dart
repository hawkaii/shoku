import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/shoku_text.dart';
import '../../../data/models/pantry_item.dart';
import '../../state/pantry_providers.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/mic_field.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/plate_mark.dart';

/// The kitchen's own shelf: what is here, not what a recipe says.
///
/// The pantry is a confirmed layer beside the recipe — no recipe line is ever
/// rewritten from it, and nothing enters stock without passing the review.
class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
                    Text('Pantry', style: ShokuType.h1.copyWith(color: c.ink)),
                    const Spacer(),
                    Text(count(items.length, 'item'),
                        style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                  ],
                ),
                const SizedBox(height: ShokuSpace.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md),
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
                      hintStyle: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                    ),
                  ),
                ),
                const SizedBox(height: ShokuSpace.md),
                const ShokuLabel('cook from your pantry'),
                const SizedBox(height: ShokuSpace.sm),
                // Suggestions arrive from /v1/feed/suggestions; until the API
                // returns any, this is the quiet truth, not an error.
                Text(
                  'Nothing to suggest yet — add a few items and I will match walls and your own dishes.',
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
                if (toBuy.isNotEmpty) ...[
                  const SizedBox(height: ShokuSpace.lg),
                  const ShokuLabel('to buy'),
                  const SizedBox(height: ShokuSpace.sm),
                  for (final item in toBuy)
                    _Row(item: item, onBuy: () => _checkedOff(item)),
                ],
                if (inStock.isNotEmpty) ...[
                  const SizedBox(height: ShokuSpace.lg),
                  const ShokuLabel('in the kitchen'),
                  const SizedBox(height: ShokuSpace.sm),
                  for (final item in inStock) _Row(item: item),
                ],
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: ShokuSpace.xxl),
                    child: Column(
                      children: [
                        const PlateMark(size: 90),
                        const SizedBox(height: ShokuSpace.sm),
                        Text(
                          'Nothing in the pantry yet. Photograph a receipt, or just tell me what’s in the fridge.',
                          key: const ValueKey('pantry-empty'),
                          textAlign: TextAlign.center,
                          style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ShokuSpace.lg,
              ShokuSpace.sm,
              ShokuSpace.lg,
              ShokuSpace.md,
            ),
            child: ShokuPressable(
              key: const ValueKey('pantry-add'),
              onTap: _openCapture,
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

  Future<void> _openCapture() async {
    await showPantryCapture(context);
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
              onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
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

class _Row extends ConsumerWidget {
  const _Row({required this.item, this.onBuy});

  final PantryItem item;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(pantryStoreProvider.notifier).remove(item.id),
      background: Container(color: c.danger),
      child: ShokuPressable(
        onTap: onBuy ?? () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.hairline)),
          ),
          child: Row(
            children: [
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
              Text(item.amountLabel,
                  style: ShokuType.stat.copyWith(fontSize: 11, color: c.inkMuted)),
            ],
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

/// Three doors, one review: type, speak, or (when the picker lands) a photo.
Future<void> showPantryCapture(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (_) => const PantryCaptureSheet(),
  );
}

class PantryCaptureSheet extends ConsumerStatefulWidget {
  const PantryCaptureSheet({super.key});

  @override
  ConsumerState<PantryCaptureSheet> createState() => _PantryCaptureSheetState();
}

class _PantryCaptureSheetState extends ConsumerState<PantryCaptureSheet> {
  final _text = TextEditingController();
  List<ParsedPantryLine> _lines = const [];
  final _checked = <int>{};
  bool _reviewing = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _parse(String text) {
    final lines = PantryParser.parse(text);
    setState(() {
      _lines = lines;
      _checked
        ..clear()
        ..addAll([
          for (var i = 0; i < lines.length; i++)
            if (lines[i].confident) i,
        ]);
      _reviewing = lines.isNotEmpty;
    });
  }

  Future<void> _confirm() async {
    final selected = [
      for (var i = 0; i < _lines.length; i++)
        if (_checked.contains(i)) _lines[i],
    ];
    if (selected.isEmpty) return;
    final store = ref.read(pantryStoreProvider.notifier);
    for (final line in selected) {
      await store.add(
        name: line.name,
        quantity: line.quantity,
        unit: line.unit,
        aliases: [line.raw],
        source: 'typed',
      );
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ambiguous = [
      for (var i = 0; i < _lines.length; i++)
        if (!_lines[i].confident) i,
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        ShokuSpace.lg,
        ShokuSpace.lg,
        ShokuSpace.lg,
        MediaQuery.of(context).viewInsets.bottom + ShokuSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add to the pantry',
              style: ShokuType.h2.copyWith(color: c.ink)),
          const SizedBox(height: 2),
          Text(
            'Type or speak what is in the kitchen — “2 kg rice”, one per line.',
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.md),
          MicField(controller: _text, hint: '2 kg rice', maxLines: 3),
          const SizedBox(height: ShokuSpace.sm),
          ShokuPressable(
            key: const ValueKey('pantry-parse'),
            onTap: () => _parse(_text.text),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.hairline),
              ),
              child: Center(
                child: Text('Review',
                    style: ShokuType.title.copyWith(color: c.ink, fontSize: 13)),
              ),
            ),
          ),
          if (_reviewing) ...[
            const SizedBox(height: ShokuSpace.md),
            for (var i = 0; i < _lines.length; i++)
              if (_lines[i].confident)
                CheckboxListTile(
                  dense: true,
                  value: _checked.contains(i),
                  onChanged: (value) => setState(() {
                    if (value == true) {
                      _checked.add(i);
                    } else {
                      _checked.remove(i);
                    }
                  }),
                  title: Text(_lines[i].name,
                      style: ShokuType.bodySmall.copyWith(color: c.ink)),
                  subtitle: Text(_lines[i].amountLabel ?? 'amount unknown',
                      style:
                          ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted)),
                ),
            if (ambiguous.isNotEmpty)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('Couldn’t read (${ambiguous.length})',
                    style: ShokuType.label.copyWith(color: c.inkMuted)),
                children: [
                  for (final index in ambiguous)
                    ListTile(
                      dense: true,
                      title: Text(_lines[index].raw,
                          style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                    ),
                ],
              ),
            const SizedBox(height: ShokuSpace.sm),
            ShokuPressable(
              key: const ValueKey('pantry-confirm'),
              onTap: _checked.isEmpty ? null : _confirm,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: ShokuGradients.crimsonPress,
                  borderRadius: BorderRadius.circular(ShokuRadius.chip),
                  border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                ),
                child: Center(
                  child: Text(
                    'Add ${_checked.length} of ${_lines.length}',
                    key: const ValueKey('pantry-confirm-label'),
                    style: ShokuType.title
                        .copyWith(color: c.onAccent, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
