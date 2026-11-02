import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/assistant_turn_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../state/journal_providers.dart';

/// What the assistant is talking about, derived from where the cook is.
///
/// It is never chosen silently: the sheet always shows this in a chip, and the
/// chip opens the switcher. `dishId` null is the kitchen thread.
class BotScope {
  const BotScope({this.dishId, this.stepIndex, this.stepCount});

  const BotScope.kitchen() : this();

  final String? dishId;
  final int? stepIndex;
  final int? stepCount;

  bool get isKitchen => dishId == null;

  BotThread get thread =>
      dishId == null ? const BotThread.kitchen() : BotThread.dish(dishId);

  @override
  bool operator ==(Object other) =>
      other is BotScope &&
      other.dishId == dishId &&
      other.stepIndex == stepIndex &&
      other.stepCount == stepCount;

  @override
  int get hashCode => Object.hash(dishId, stepIndex, stepCount);
}

/// The scope the next turn will be sent in. Route-derived by the shell, and
/// overridable for the thread from the chip's switcher.
final botScopeProvider = StateProvider<BotScope>((ref) => const BotScope.kitchen());

/// Resolves the chip's words against the journal, so a renamed dish renames the
/// chip without the scope having to store a copy of the title.
String botScopeLabel(WidgetRef ref, BotScope scope,
    [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (scope.isKitchen) return t.botNoDish;
  final dish = ref.watch(dishProvider(scope.dishId!));
  if (scope.stepIndex != null) {
    final total = scope.stepCount ?? dish?.steps.length ?? 0;
    return t.botCookingStep(scope.stepIndex! + 1, total);
  }
  return dish?.title ?? t.botDishFallback;
}
