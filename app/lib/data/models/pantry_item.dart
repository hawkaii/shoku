import 'dart:math' as math;

/// The units the pantry understands. Counts never convert.
enum PantryUnit {
  g('g'),
  kg('kg'),
  ml('ml'),
  l('l'),
  tbsp('tbsp'),
  tsp('tsp'),
  pcs('pcs'),
  bunch('bunch'),
  pack('pack');

  const PantryUnit(this.label);

  final String label;

  static PantryUnit? parse(String? raw) {
    final text = raw?.trim().toLowerCase();
    if (text == null || text.isEmpty) return null;
    return switch (text) {
      'g' || 'gr' || 'gm' || 'gms' || 'gram' || 'grams' => PantryUnit.g,
      'kg' || 'kilo' || 'kilos' || 'kgs' => PantryUnit.kg,
      'ml' || 'millilitre' || 'milliliter' => PantryUnit.ml,
      'l' ||
      'lt' ||
      'ltr' ||
      'ltrs' ||
      'litre' ||
      'liter' ||
      'litres' ||
      'liters' =>
        PantryUnit.l,
      'tbsp' || 'tablespoon' || 'tablespoons' => PantryUnit.tbsp,
      'tsp' || 'teaspoon' || 'teaspoons' => PantryUnit.tsp,
      'pcs' || 'pc' || 'piece' || 'pieces' || 'x' => PantryUnit.pcs,
      'bunch' || 'bunches' => PantryUnit.bunch,
      'pack' || 'pkt' || 'pkts' || 'packet' || 'packets' => PantryUnit.pack,
      _ => null,
    };
  }

  bool get isCount => this == pcs || this == bunch || this == pack;

  bool get isWeight => this == g || this == kg;

  bool get isVolume => this == ml || this == l || this == tbsp || this == tsp;

  /// Same family means the amounts can be compared. Counts compare only to
  /// themselves — a bunch is not a weight, and guessing that it is would be a
  /// lie about somebody's kitchen.
  bool comparableTo(PantryUnit other) =>
      (isWeight && other.isWeight) ||
      (isVolume && other.isVolume) ||
      (isCount && this == other);

  /// This amount expressed in a base unit of its family (g, ml, pcs).
  double get base => switch (this) {
        PantryUnit.kg => 1000,
        PantryUnit.l => 1000,
        PantryUnit.tbsp => 15,
        PantryUnit.tsp => 5,
        _ => 1,
      };
}

/// One thing in the kitchen.
class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    this.quantity,
    this.unit,
    this.aliases = const [],
    this.wanted = false,
    this.source = 'manual',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.dirty = 1,
  });

  final String id;
  final String name;
  final double? quantity;
  final PantryUnit? unit;
  final List<String> aliases;
  final bool wanted;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int dirty;

  bool get isDeleted => deletedAt != null;

  /// `2 kg`, or nothing at all when the amount is unknown.
  String get amountLabel {
    if (quantity == null) return '';
    final value = quantity!;
    final rounded = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
    return unit == null ? rounded : '$rounded ${unit!.label}';
  }

  PantryItem copyWith({
    String? name,
    double? quantity,
    bool clearQuantity = false,
    PantryUnit? unit,
    bool clearUnit = false,
    List<String>? aliases,
    bool? wanted,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? dirty,
  }) =>
      PantryItem(
        id: id,
        name: name ?? this.name,
        quantity: clearQuantity ? null : (quantity ?? this.quantity),
        unit: clearUnit ? null : (unit ?? this.unit),
        aliases: aliases ?? this.aliases,
        wanted: wanted ?? this.wanted,
        source: source,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        dirty: dirty ?? this.dirty,
      );
}

/// What a receipt or a sentence becomes before anybody confirms it.
class ParsedPantryLine {
  const ParsedPantryLine({
    required this.raw,
    required this.name,
    this.quantity,
    this.unit,
    this.confident = true,
    this.fromAi = false,
  });

  final String raw;
  final String name;
  final double? quantity;
  final PantryUnit? unit;

  /// False when the line could not be parsed: it is kept raw, never guessed.
  final bool confident;

  /// Read by the server's fallback, not on this device. The review says so,
  /// because a model misreading a pack size should be visible before it lands.
  final bool fromAi;

  String? get amountLabel {
    if (quantity == null) return null;
    final value = quantity!;
    final rounded = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
    return unit == null ? rounded : '$rounded ${unit!.label}';
  }
}

/// Deterministic, offline parsing of "2 kg rice" and receipt lines.
///
/// Nothing here invents an amount: a line without a quantity keeps a null
/// amount, and a line with no readable name is unconfident so the review sheet
/// can leave it in "Couldn't read".
///
/// Brand names are not a list in this file. A receipt prints the brand *before*
/// the product ("AMUL BUTTER 500G"), so the parser keeps the words from the
/// first one the kitchen already knows and nothing before it. Any brand falls
/// off that way, including one nobody wrote down, and a kitchen that has never
/// seen butter keeps "amul butter" rather than guessing what to drop.
class PantryParser {
  static final _leading =
      RegExp(r'^\s*(\d+(?:[.,]\d+)?)\s*([a-zA-Z]+)?\s*[x*]?\s+(.+)$');
  static final _trailingAmount =
      RegExp(r'^(.*\S)\s+(\d+(?:[.,]\d+)?)\s*([a-zA-Z]{1,6})$');
  static final _trailingPercent = RegExp(r'\s+\d+[.,]\d{2}\s*$');
  static final _notAName = RegExp(r"[^a-z0-9 '\-]");
  static final _words = RegExp(r'[^a-z0-9]+');

  /// Grammar, not vocabulary: these words never name an ingredient.
  static const _stopWords = {
    'a',
    'an',
    'and',
    'the',
    'of',
    'with',
    'fresh',
    'packet',
    'pack',
  };

  /// A name as the shelf stores it: lowercase, no stray punctuation, no
  /// doubled spaces. Display capitalisation is the UI's business.
  static String cleanName(String name) {
    var text = name.toLowerCase().replaceAll('&', ' ');
    text = text.replaceAll(_notAName, ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.replaceAll(RegExp(r"^[ '\-]+|[ '\-]+$"), '').trim();
  }

  /// The words a name is made of, in order: lowercase, no numbers, no grammar.
  static List<String> words(String name) => [
        for (final word in cleanName(name).split(_words))
          if (word.isNotEmpty &&
              !_stopWords.contains(word) &&
              !RegExp(r'^\d+$').hasMatch(word))
            word,
      ];

  /// The plural fold the server uses, so both ends of a match agree.
  static String singular(String word) {
    if (word.length <= 3 || word.endsWith('ss')) return word;
    if (word.endsWith('ies') && word.length > 4) {
      return '${word.substring(0, word.length - 3)}y';
    }
    for (final suffix in const ['ches', 'shes', 'sses', 'xes', 'zes', 'oes']) {
      if (word.endsWith(suffix)) {
        return word.substring(0, word.length - 2);
      }
    }
    if (word.endsWith('s')) return word.substring(0, word.length - 1);
    return word;
  }

  /// The kitchen's own ingredient words: what is on the shelf already.
  ///
  /// Names only, never aliases — an alias is the receipt's raw text, and taking
  /// it as vocabulary would teach the parser that the brand is the product.
  static Set<String> vocabularyOf(Iterable<String> names) => {
        for (final name in names)
          for (final word in words(name)) singular(word),
      };

  /// Drops the words printed before the first one this kitchen knows.
  static String normalise(String name, Set<String> vocabulary) {
    final parts = words(name);
    if (parts.isEmpty || vocabulary.isEmpty) return cleanName(name);
    final firstKnown =
        parts.indexWhere((word) => vocabulary.contains(singular(word)));
    if (firstKnown <= 0) return parts.join(' ');
    return parts.sublist(firstKnown).join(' ');
  }

  /// A line the device cannot be trusted with, for the server's fallback.
  ///
  /// The parser named nothing, or it named something with no word this kitchen
  /// knows. "HALDIRAM BHUJIA" is a brand in front of a product nobody here has
  /// typed yet, and a receipt is full of those. A line that carries one known
  /// word needs no help: the rest of it is a description, not a mystery.
  static bool needsHelp(ParsedPantryLine line, Set<String> vocabulary) {
    if (!line.confident) return true;
    final parts = words(line.name);
    if (parts.isEmpty) return true;
    return !parts.any((word) => vocabulary.contains(singular(word)));
  }

  /// A name must name something: "500G" left over from a lifted amount is not
  /// an ingredient.
  static bool _namesSomething(String name) => RegExp(r'[a-z]').hasMatch(name);

  /// [strict] is for machine-read text (a receipt or a screenshot): there a
  /// bare word may be a shop's footer, so a line must carry an amount to be
  /// trusted. Typed and spoken lines are the cook's own words and need not.
  static ParsedPantryLine parseLine(
    String rawLine, {
    bool strict = false,
    Set<String> vocabulary = const {},
  }) {
    var line = rawLine.trim().replaceAll(RegExp(r'\s+'), ' ');
    line = line.replaceAll(_trailingPercent, ''); // receipt totals on the line
    if (line.isEmpty) {
      return ParsedPantryLine(raw: rawLine, name: '', confident: false);
    }

    double? quantity;
    PantryUnit? unit;
    var name = '';

    final leading = _leading.firstMatch(line);
    if (leading != null) {
      final qty = double.tryParse(leading.group(1)!.replaceAll(',', '.'));
      final parsedUnit = PantryUnit.parse(leading.group(2));
      // A decimal with no unit is a receipt code, not a number of things:
      // "500 AMUL" is ambiguous, "2 potatoes" is a count.
      if (qty != null && (parsedUnit != null || qty == qty.roundToDouble())) {
        quantity = qty;
        unit = parsedUnit ?? PantryUnit.pcs;
        name = leading.group(3)!.trim();
      }
    }

    if (name.isEmpty) {
      final trailing = _trailingAmount.firstMatch(line);
      if (trailing != null) {
        final parsedUnit = PantryUnit.parse(trailing.group(3));
        if (parsedUnit != null) {
          quantity = double.tryParse(trailing.group(2)!.replaceAll(',', '.'));
          unit = parsedUnit;
          name = trailing.group(1)!.trim();
        }
      }
    }

    // A line whose only amount was lifted leaves nothing to name.
    if (name.isEmpty) name = line;

    final cleaned = normalise(name, vocabulary);
    if (cleaned.isEmpty || !_namesSomething(cleaned)) {
      return ParsedPantryLine(raw: rawLine, name: '', confident: false);
    }
    // Machine-read text with no amount is the ambiguous pile; the cook's own
    // words are a name and an unknown amount, which is honest.
    final confident = !strict || quantity != null;
    return ParsedPantryLine(
      raw: rawLine,
      name: cleaned,
      quantity: quantity,
      unit: quantity == null ? null : unit,
      confident: confident,
    );
  }

  /// Parses a batch; blanks drop out.
  static List<ParsedPantryLine> parse(
    String text, {
    bool strict = false,
    Set<String> vocabulary = const {},
  }) =>
      [
        for (final line in text.split(RegExp(r'[\n;]')))
          if (line.trim().isNotEmpty)
            parseLine(line, strict: strict, vocabulary: vocabulary),
      ];

  /// The amount a recipe line states, expressed in [stockUnit], or null when
  /// the line states none or states one that cannot be compared.
  ///
  /// This is the only thing a deduction may default to: the recipe's own words.
  /// A line that merely names the ingredient never becomes "use all of it".
  static double? statedAmountIn({
    required String line,
    required PantryUnit stockUnit,
  }) {
    final parsed = parseLine(line);
    final quantity = parsed.quantity;
    final unit = parsed.unit;
    if (quantity == null || unit == null) return null;
    if (!unit.comparableTo(stockUnit)) return null;
    if (unit.isCount && unit != stockUnit) return null;
    return quantity * unit.base / stockUnit.base;
  }

  /// Case- and space-insensitive key used to spot duplicates.
  static String key(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

  /// How much of [have] a line of [needed] would use, or null when the units
  /// do not compare. Null is "not deducted", never "deducted zero".
  static double? deductAmount({
    required double have,
    required PantryUnit haveUnit,
    required double needed,
    required PantryUnit neededUnit,
  }) {
    if (haveUnit != neededUnit && !haveUnit.comparableTo(neededUnit)) {
      return null;
    }
    final inBase = needed * neededUnit.base;
    final haveBase = have * haveUnit.base;
    final leftBase = haveBase - inBase;
    return math.max(0, leftBase) / haveUnit.base;
  }
}
