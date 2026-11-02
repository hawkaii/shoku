import 'pantry_item.dart';

/// What the fridge can say about one ingredient line.
enum FridgeState {
  /// Matched, and the stock covers what the recipe asks for.
  inFridge,

  /// Matched, but short, unmeasured, or in units that do not compare.
  some,

  /// A `wanted` row: on the shopping list, not on the shelf.
  onList,

  /// Looked, and this kitchen does not have it.
  missing,

  /// Not a question the fridge can answer: a spice, "to taste", no parsed
  /// name, or a fridge that has never been set up.
  notTracked,
}

/// One line, answered by the shelf.
class FridgeMatch {
  const FridgeMatch(this.state, {this.item, this.have, this.need});

  final FridgeState state;

  /// The row that answered. Never more than one: summing two half-packs into
  /// "enough" would be arithmetic about somebody's kitchen we did not do.
  final PantryItem? item;

  /// Stock and need, both in the line's unit, when they compare.
  final double? have;
  final double? need;

  bool get isMissing => state == FridgeState.missing;

  /// The exact copy a line carries.
  String get label => switch (state) {
        FridgeState.inFridge => 'In the fridge · ${_amount(item)}',
        FridgeState.some => _someLabel,
        FridgeState.onList => 'On your list',
        FridgeState.missing => 'Missing',
        FridgeState.notTracked => 'Not tracked',
      };

  String get _someLabel {
    final have = this.have;
    final need = this.need;
    final unit = item?.unit?.label ?? '';
    if (have == null || need == null) return 'Some in the fridge';
    return 'Some in the fridge · ${_number(have)} $unit of ${_number(need)} $unit';
  }

  static String _amount(PantryItem? item) {
    if (item == null || item.quantity == null) return 'some';
    return item.amountLabel;
  }

  static String _number(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}

/// Reads a recipe's lines against the shelf.
///
/// Token-based, not substring: "oil" must not answer "olives", and "rice"
/// must not answer "rice vinegar". Names, aliases and the same plural fold the
/// server matches with, so both ends of the kitchen agree on what a word is.
class FridgeMatcher {
  FridgeMatcher(List<PantryItem> pantry)
      : _pantry = [
          for (final item in pantry)
            if (!item.wanted) item,
        ],
        _wanted = [
          for (final item in pantry)
            if (item.wanted) item,
        ];

  final List<PantryItem> _pantry;
  final List<PantryItem> _wanted;

  /// No rows at all: the fridge has never been set up, and every line is
  /// "Not tracked" rather than a claim that the kitchen is empty.
  bool get isUnset => _pantry.isEmpty && _wanted.isEmpty;

  static const _generic = {
    'spice',
    'spices',
    'seasoning',
    'seasonings',
    'garnish',
    'to taste',
    'as needed',
  };

  FridgeMatch match(String line) {
    if (isUnset) return const FridgeMatch(FridgeState.notTracked);

    final parsed = PantryParser.parseLine(line);
    final name = parsed.name.trim();
    final lower = line.toLowerCase();
    if (name.isEmpty ||
        _generic.contains(name) ||
        lower.contains('to taste') ||
        lower.contains('as needed')) {
      return const FridgeMatch(FridgeState.notTracked);
    }

    final stocked = _best(name, _pantry);
    if (stocked != null) return _against(stocked, parsed);

    if (_best(name, _wanted) != null) {
      return const FridgeMatch(FridgeState.onList);
    }
    return const FridgeMatch(FridgeState.missing);
  }

  /// Exact name beats an alias beats a shared word; ties go to the shorter
  /// shelf name, so "oil" prefers oil over "olive oil".
  static PantryItem? _best(String name, List<PantryItem> items) {
    final key = PantryParser.key(name);
    final lineWords = {
      for (final word in PantryParser.words(name)) PantryParser.singular(word),
    };

    PantryItem? exact;
    PantryItem? alias;
    PantryItem? overlap;
    var bestShared = 0;

    for (final item in items) {
      if (PantryParser.key(item.name) == key) {
        exact ??= item;
        continue;
      }
      if (item.aliases.any((a) => PantryParser.key(a) == key)) {
        alias ??= item;
        continue;
      }
      final itemWords = {
        for (final word in PantryParser.words(item.name))
          PantryParser.singular(word),
      };
      final shared = itemWords.intersection(lineWords).length;
      if (shared == 0) continue;
      if (shared > bestShared ||
          (shared == bestShared &&
              (overlap == null || item.name.length < overlap.name.length))) {
        bestShared = shared;
        overlap = item;
      }
    }
    return exact ?? alias ?? overlap;
  }

  /// How the stock answers the line. A line that states no amount can never be
  /// "enough": knowing there is some butter is not knowing there is a tbsp.
  static FridgeMatch _against(PantryItem item, ParsedPantryLine parsed) {
    if (parsed.quantity == null || parsed.unit == null) {
      return FridgeMatch(FridgeState.some, item: item);
    }
    final have = item.quantity;
    final haveUnit = item.unit;
    if (have == null || haveUnit == null) {
      return FridgeMatch(FridgeState.some, item: item);
    }
    if (!haveUnit.comparableTo(parsed.unit!)) {
      return FridgeMatch(FridgeState.some, item: item);
    }

    final inLineUnit = have * haveUnit.base / parsed.unit!.base;
    if (inLineUnit >= parsed.quantity!) {
      return FridgeMatch(FridgeState.inFridge, item: item);
    }
    return FridgeMatch(
      FridgeState.some,
      item: item,
      have: inLineUnit,
      need: parsed.quantity,
    );
  }
}

/// The shelf's answer for a whole recipe, in the words the strip uses.
class FridgeCoverage {
  const FridgeCoverage({
    required this.matches,
    required this.lines,
    required this.unset,
  });

  final List<FridgeMatch> matches;
  final List<String> lines;
  final bool unset;

  int get total => matches.length;
  int get inFridge => matches.where((m) => m.state == FridgeState.inFridge || m.state == FridgeState.some).length;
  int get onList => matches.where((m) => m.state == FridgeState.onList).length;
  int get missing => matches.where((m) => m.state == FridgeState.missing).length;

  /// Missing lines deduped by name: two mentions of the same thing are one
  /// shopping-list entry, never two.
  List<String> get missingNames {
    final seen = <String>{};
    final names = <String>[];
    for (var i = 0; i < lines.length; i++) {
      if (matches[i].state != FridgeState.missing) continue;
      final parsed = PantryParser.parseLine(lines[i]);
      final name = parsed.name.trim();
      if (name.isEmpty) continue;
      if (seen.add(PantryParser.key(name))) names.add(name);
    }
    return names;
  }

  String get strip => unset
      ? 'Not tracked · Set up your fridge'
      : [
          '$inFridge of $total in your fridge',
          if (onList > 0) '$onList on your list',
          if (missing > 0) '$missing missing',
        ].join(' · ');
}
