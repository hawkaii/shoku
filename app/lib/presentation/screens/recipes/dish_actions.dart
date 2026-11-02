import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../state/journal_store.dart';

/// Long-pressing a Cookbook card asks what to do with it.
///
/// A sheet, like every other "what can I do with this" in the app — not a
/// dialog, and not a context menu borrowed from a library.
Future<void> showDishActions(BuildContext context, Dish dish) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.canvas,
    builder: (_) => DishActionsSheet(dish: dish),
  );
}

class DishActionsSheet extends ConsumerWidget {
  const DishActionsSheet({super.key, required this.dish});

  final Dish dish;

  /// The Cookbook splits on `toCook` and everything else, so these two are the
  /// two halves of the same switch. Both are reversible.
  DishStatus get _target =>
      dish.status == DishStatus.toCook ? DishStatus.cooked : DishStatus.toCook;

  String _targetLabel(AppLocalizations l10n) =>
      _target == DishStatus.cooked
          ? l10n.actionMarkCooked
          : l10n.actionMoveBackToCook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l10n = context.l10n;
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
          Text(
            dish.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ShokuType.h2.copyWith(color: c.ink),
          ),
          const SizedBox(height: 2),
          Text(
            dish.cookCount == 0
                ? l10n.actionNeverCooked
                : l10n.actionCookedCount(dish.cookCount),
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.lg),

          _Action(
            key: const ValueKey('dish-action-status'),
            icon: _target == DishStatus.cooked
                ? Icons.check_circle_outline
                : Icons.schedule,
            title: _targetLabel(l10n),
            subtitle: _target == DishStatus.cooked
                ? l10n.actionStatusCookedBody
                : l10n.actionStatusToCookBody,
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(journalStoreProvider.notifier).setStatus(dish.id, _target);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: ShokuSpace.sm),
          _Action(
            key: const ValueKey('dish-action-delete'),
            icon: Icons.delete_outline,
            title: l10n.pantryDelete,
            subtitle: l10n.actionDeleteBody,
            danger: true,
            onTap: () => _confirmDelete(context, ref),
          ),
          const SizedBox(height: ShokuSpace.lg),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.actionKeep,
                  style: ShokuType.label.copyWith(color: c.inkMuted)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final store = ref.read(journalStoreProvider.notifier);
    final navigator = Navigator.of(context);
    navigator.pop(); // the sheet has done its job; the question is its own step

    final confirmed = await showDialog<bool>(
      context: navigator.context,
      builder: (context) {
        final c = context.colors;
        return Dialog(
          backgroundColor: c.canvas,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShokuRadius.card),
            side: BorderSide(color: c.ink, width: ShokuStroke.brutal),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ShokuSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.actionRemoveTitle,
                    style: ShokuType.h1.copyWith(color: c.ink)),
                const SizedBox(height: ShokuSpace.xs),
                Text(
                  // The dish leaves the journal; the reel does not stop
                  // existing. Saying "gone forever" would be a lie, and saying
                  // "deleted" alone would hide where it goes.
                  l10n.actionRemoveBody(dish.title),
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: ShokuSpace.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ShokuRadius.chip),
                            side: BorderSide(color: c.hairline),
                          ),
                        ),
                        child: Text(l10n.actionKeep,
                            style: ShokuType.title
                                .copyWith(color: c.ink, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: ShokuSpace.sm),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop(true);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: c.ink,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ShokuRadius.chip),
                          ),
                        ),
                        child: Text(l10n.actionRemove,
                            style: ShokuType.title
                                .copyWith(color: c.canvas, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) await store.deleteDish(dish.id);
  }
}

class _Action extends StatelessWidget {
  const _Action({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(ShokuSpace.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(ShokuRadius.card),
          border: Border.all(color: c.hairline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: danger ? c.danger : c.ink),
            const SizedBox(width: ShokuSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: ShokuType.title.copyWith(
                        color: danger ? c.danger : c.ink,
                        fontSize: 14,
                      )),
                  Text(subtitle,
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: c.inkMuted),
          ],
        ),
      ),
    );
  }
}
