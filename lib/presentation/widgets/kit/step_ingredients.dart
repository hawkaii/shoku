import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';

/// The ingredients a step uses, in the recipe's own words.
///
/// Each line is the version's own ingredient entry, quoted:
///
///   * `garlic` when the ingredient states no amount
///   * `2 tbsp olive oil` when it does
///
/// Nothing is counted, inferred, re-ordered or hedged. The app never guesses an
/// amount, because a guessed quantity is the app lying about somebody else's
/// recipe. The styling is deliberately quiet — body sans, muted, inline, flowing
/// — so a number reads as a note from the recipe, not as a measurement.
///
/// [indices] is null for a parse that predates the extractor's links, and then
/// this renders nothing at all: no name matching, no fallback.
class StepIngredientsLine extends StatelessWidget {
  const StepIngredientsLine({
    super.key,
    required this.ingredients,
    required this.indices,
  });

  /// The version's ingredient lines, verbatim.
  final List<String> ingredients;

  /// Indices into [ingredients] for one step, or null when there are no links.
  final List<int>? indices;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final indices = this.indices;
    if (indices == null || indices.isEmpty) return const SizedBox.shrink();

    final lines = <String>[
      // An index the server sent but the ingredient list does not have is
      // dropped, not clamped onto a neighbour.
      for (final index in indices)
        if (index >= 0 && index < ingredients.length) ingredients[index],
    ];
    if (lines.isEmpty) return const SizedBox.shrink();

    return Text(
      lines.join(' · '),
      key: const ValueKey('step-ingredients'),
      softWrap: true,
      style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
    );
  }
}
