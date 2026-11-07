import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/labels.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../data/models/pantry_item.dart';
import '../../state/pantry_providers.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';

/// One item, edited in place.
///
/// The same fields the review collected: what it is called, how much, in what
/// unit. Amount is optional — "have it, amount unknown" is a real state and
/// the UI must not turn it into a zero.
Future<void> showPantryEditSheet(BuildContext context, PantryItem item) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (_) => PantryEditSheet(item: item),
  );
}

class PantryEditSheet extends ConsumerStatefulWidget {
  const PantryEditSheet({super.key, required this.item});

  final PantryItem item;

  @override
  ConsumerState<PantryEditSheet> createState() => _PantryEditSheetState();
}

class _PantryEditSheetState extends ConsumerState<PantryEditSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.item.name);
  late final TextEditingController _amount =
      TextEditingController(text: _plainAmount(widget.item.quantity));
  late PantryUnit? _unit = widget.item.unit;
  bool _saving = false;

  static String _plainAmount(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  double? get _quantity => double.tryParse(_amount.text.replaceAll(',', '.'));

  Future<void> _save() async {
    final name = PantryParser.cleanName(_name.text);
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    final quantity = _quantity;
    await ref.read(pantryStoreProvider.notifier).save(
          widget.item.copyWith(
            name: name,
            quantity: quantity,
            clearQuantity: quantity == null,
            unit: quantity == null ? null : _unit,
            clearUnit: quantity == null,
            wanted: quantity == null ? widget.item.wanted : false,
          ),
        );
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (_saving) return;
    setState(() => _saving = true);
    await ref.read(pantryStoreProvider.notifier).remove(widget.item.id);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();

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
          Row(
            children: [
              Text(l10n.pantryEditTitle,
                  style: ShokuType.h2.copyWith(color: c.ink)),
              const Spacer(),
              ShokuPressable(
                key: const ValueKey('pantry-edit-delete'),
                onTap: _delete,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ShokuSpace.sm,
                    vertical: ShokuSpace.xs,
                  ),
                  child: Text(l10n.pantryDelete,
                      style: ShokuType.bodySmall.copyWith(color: c.danger)),
                ),
              ),
            ],
          ),
          const SizedBox(height: ShokuSpace.md),
          ShokuLabel(l10n.pantryNameLabel, color: c.inkMuted),
          const SizedBox(height: ShokuSpace.xs),
          _fieldBox(
            child: TextField(
              key: const ValueKey('pantry-edit-name'),
              controller: _name,
              textCapitalization: TextCapitalization.none,
              style: ShokuType.body.copyWith(color: c.ink),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: ShokuSpace.md),
          ShokuLabel(l10n.pantryAmountLabel, color: c.inkMuted),
          const SizedBox(height: ShokuSpace.xs),
          Row(
            children: [
              SizedBox(
                width: 96,
                child: _fieldBox(
                  child: TextField(
                    key: const ValueKey('pantry-edit-qty'),
                    controller: _amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: ShokuType.stat.copyWith(color: c.ink),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: '—',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ShokuSpace.sm),
              Expanded(
                child: Text(
                  _quantity == null
                      ? l10n.pantryAmountHelp
                      : l10n.pantrySavedAs(
                          pantryAmount(l10n, locale, _quantity, _unit)),
                  style:
                      ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: ShokuSpace.sm),
          Wrap(
            spacing: ShokuSpace.xs,
            runSpacing: ShokuSpace.xs,
            children: [
              for (final unit in PantryUnit.values)
                ShokuPressable(
                  key: ValueKey('pantry-edit-unit-${unit.label}'),
                  onTap: () => setState(() => _unit = unit),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ShokuSpace.sm,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _unit == unit ? c.accentSoft : c.surface,
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                      border: Border.all(
                        color: _unit == unit ? c.accent : c.hairline,
                      ),
                    ),
                    child: Text(
                      unitLabel(l10n, unit),
                      style: ShokuType.label.copyWith(
                        fontSize: 10,
                        color: _unit == unit ? c.accent : c.inkMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: ShokuSpace.lg),
          ShokuPressable(
            key: const ValueKey('pantry-edit-save'),
            onTap: _saving ? null : _save,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: ShokuGradients.crimsonPress,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.ink, width: ShokuStroke.brutal),
              ),
              child: Center(
                child: Text(l10n.pantrySave,
                    style: ShokuType.title
                        .copyWith(color: c.onAccent, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldBox({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ShokuSpace.md,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
          border: Border.all(color: context.colors.hairline),
        ),
        child: child,
      );
}
