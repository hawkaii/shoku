import '../../data/mock/journal_data.dart';
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
