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
      'g' || 'gr' || 'gram' || 'grams' => PantryUnit.g,
      'kg' || 'kilo' || 'kilos' || 'kgs' => PantryUnit.kg,
      'ml' || 'millilitre' || 'milliliter' => PantryUnit.ml,
      'l' || 'lt' || 'litre' || 'liter' || 'litres' || 'liters' => PantryUnit.l,
      'tbsp' || 'tablespoon' || 'tablespoons' => PantryUnit.tbsp,
      'tsp' || 'teaspoon' || 'teaspoons' => PantryUnit.tsp,
      'pcs' || 'pc' || 'piece' || 'pieces' || 'x' => PantryUnit.pcs,
      'bunch' || 'bunches' => PantryUnit.bunch,
      'pack' || 'packet' || 'packets' => PantryUnit.pack,
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
  });

  final String raw;
  final String name;
  final double? quantity;
  final PantryUnit? unit;

  /// False when the line could not be parsed: it is kept raw, never guessed.
  final bool confident;

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
/// Nothing here invents an amount: a line without a leading quantity keeps the
/// raw text and is marked unconfident, so the review sheet can leave it off.
class PantryParser {
  static final _leading =
      RegExp(r'^\s*(\d+(?:[.,]\d+)?)\s*([a-zA-Z]+)?\s*[x*]?\s+(.+)$');
  static final _trailingPercent = RegExp(r'\s+\d+[.,]\d{2}\s*$');

  static ParsedPantryLine parseLine(String rawLine) {
    var line = rawLine.trim().replaceAll(RegExp(r'\s+'), ' ');
    line = line.replaceAll(_trailingPercent, ''); // receipt totals on the line
    if (line.isEmpty) {
      return ParsedPantryLine(raw: rawLine, name: '', confident: false);
    }

    final match = _leading.firstMatch(line);
    if (match == null) {
      return ParsedPantryLine(raw: rawLine, name: line, confident: false);
    }

    final quantity = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    final unit = PantryUnit.parse(match.group(2));
    final name = match.group(3)!.trim();
    if (quantity == null || name.isEmpty) {
      return ParsedPantryLine(raw: rawLine, name: line, confident: false);
    }
    // A number with no unit and a word that is not a unit is ambiguous: "2
    // potatoes" is a count, but "500 AMUL" is a receipt code. Keep the count
    // case, drop the rest to the ambiguous pile.
    if (unit == null && quantity != quantity.roundToDouble()) {
      return ParsedPantryLine(raw: rawLine, name: line, confident: false);
    }
    return ParsedPantryLine(
      raw: rawLine,
      name: name,
      quantity: quantity,
      unit: unit ?? PantryUnit.pcs,
    );
  }

  /// Parses a batch; blanks drop out.
  static List<ParsedPantryLine> parse(String text) => [
        for (final line in text.split(RegExp(r'[\n;]')))
          if (line.trim().isNotEmpty) parseLine(line),
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
    if (haveUnit != neededUnit && !haveUnit.comparableTo(neededUnit)) return null;
    final inBase = needed * neededUnit.base;
    final haveBase = have * haveUnit.base;
    final leftBase = haveBase - inBase;
    return math.max(0, leftBase) / haveUnit.base;
  }
}
