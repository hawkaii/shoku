import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../state/bot_providers.dart';
import '../../state/journal_providers.dart';
import '../assistant/recipe_chat_sheet.dart';
import 'bot_scope.dart';

/// "Which dish?" — the one place the scope can be changed by hand.
///
/// Picking a dish opens that dish's thread; picking "No dish" opens the
/// kitchen's. The route never lies about it afterwards: the next navigation
/// re-derives the scope and divides the thread it leaves behind.
Future<void> showScopeSwitcher(BuildContext context) async {
  final target = await showModalBottomSheet<BotScope>(
    context: context,
    backgroundColor: context.colors.canvas,
    builder: (_) => const _ScopeSwitcher(),
  );
  if (target == null || !context.mounted) return;

  final container = ProviderScope.containerOf(context);
  container.read(botScopeProvider.notifier).state = target;
  if (target.isKitchen) {
    // The kitchen thread lives in the sheet that is already open.
    container
        .read(botControllerProvider.notifier)
        .insertDivider(context.l10n.botNoDish);
    return;
  }
  final dish = container.read(dishProvider(target.dishId!));
  if (dish == null) return;
  Navigator.of(context).maybePop();
  await showRecipeChat(context, dish: dish);
}

class _ScopeSwitcher extends ConsumerWidget {
  const _ScopeSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l10n = context.l10n;
    final dishes = ref.watch(dishesProvider);
    final current = ref.watch(botScopeProvider);

    return SafeArea(
      child: Column(
        key: const ValueKey('bot-scope-switcher'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                ShokuSpace.lg, ShokuSpace.lg, ShokuSpace.lg, ShokuSpace.sm),
            child: Text(l10n.botTalkAbout,
                style: ShokuType.h2.copyWith(color: c.ink)),
          ),
          if (!current.isKitchen)
            ListTile(
              key: const ValueKey('bot-scope-this-dish'),
              title: Text(
                  ref.read(dishProvider(current.dishId!))?.title ??
                      l10n.botThisDish,
                  style: ShokuType.bodySmall),
              trailing: const Icon(Icons.check, size: 16),
              onTap: () => Navigator.of(context).pop(current),
            ),
          for (final dish in dishes.take(5))
            ListTile(
              key: ValueKey('bot-scope-dish-${dish.id}'),
              title: Text(dish.title, style: ShokuType.bodySmall),
              onTap: () => Navigator.of(context).pop(BotScope(dishId: dish.id)),
            ),
          ListTile(
            key: const ValueKey('bot-scope-kitchen'),
            leading: Icon(Icons.kitchen_outlined, size: 18, color: c.inkMuted),
            title: Text(l10n.botNoDishKitchen,
                style: ShokuType.bodySmall.copyWith(color: c.ink)),
            onTap: () => Navigator.of(context).pop(const BotScope.kitchen()),
          ),
          const SizedBox(height: ShokuSpace.lg),
        ],
      ),
    );
  }
}
