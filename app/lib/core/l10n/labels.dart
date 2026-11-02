import 'package:intl/intl.dart';

import '../../data/mock/journal_data.dart';
import '../../data/models/pantry_item.dart';
import '../../l10n/app_localizations.dart';

/// The words for a cook outcome. The enum owns the state, never the copy: the
/// same "needs work" has to be readable in ten languages.
String outcomeLabel(AppLocalizations l10n, CookOutcome outcome) =>
    switch (outcome) {
      CookOutcome.nailedIt => l10n.outcomeNailedIt,
      CookOutcome.good => l10n.outcomeGood,
      CookOutcome.needsWork => l10n.outcomeNeedsWork,
    };

/// The outcome for a dish that has never been cooked, or null when it has.
String dishOutcomeLabel(AppLocalizations l10n, Dish dish) {
  final outcome = dish.lastCook?.outcome;
  return outcome == null ? l10n.cookbookNeverCooked : outcomeLabel(l10n, outcome);
}

String moodLabel(AppLocalizations l10n, CookMood mood) => switch (mood) {
      CookMood.quick => l10n.moodQuick,
      CookMood.project => l10n.moodProject,
      CookMood.comfort => l10n.moodComfort,
    };

/// A unit as the reader says it. `g` and `kg` stay as they are; a bunch and a
/// pack are words.
String unitLabel(AppLocalizations l10n, PantryUnit unit) => switch (unit) {
      PantryUnit.g => l10n.unitG,
      PantryUnit.kg => l10n.unitKg,
      PantryUnit.ml => l10n.unitMl,
      PantryUnit.l => l10n.unitL,
      PantryUnit.tbsp => l10n.unitTbsp,
      PantryUnit.tsp => l10n.unitTsp,
      PantryUnit.pcs => l10n.unitPcs,
      PantryUnit.bunch => l10n.unitBunch,
      PantryUnit.pack => l10n.unitPack,
    };

/// "2" or "2 kg", with the number in the reader's digits and separators.
String pantryAmount(
  AppLocalizations l10n,
  String locale,
  double? quantity,
  PantryUnit? unit,
) {
  if (quantity == null) return '';
  final number = NumberFormat.decimalPattern(locale).format(quantity);
  return unit == null ? number : '$number ${unitLabel(l10n, unit)}';
}
