/// Copy rules for counts and durations.
///
/// Both exist because the journal is a record of real things, and a record that
/// says "1 dishes" or "0 min" is a record nobody trusts.
library;

/// "1 dish", "2 dishes". [plural] is only needed for words that don't take an
/// `s` — `count(1, 'entry', 'entries')`.
String count(int n, String singular, [String? plural]) {
  final word = n == 1 ? singular : (plural ?? '${singular}s');
  return '$n $word';
}

/// A duration the user can act on, or nothing at all.
///
/// Zero means the reel never said, and a dash or a "?" would be a number
/// pretending to be one, so the whole part disappears from the line.
String minutesLabel(int minutes, {String unit = 'min'}) =>
    minutes > 0 ? '$minutes $unit' : '';

/// Joins the parts of a meta line, dropping the ones that know nothing.
///
/// `metaLine(['30 min', ''])` reads as `30 min`; an empty part never leaves a
/// stranded separator behind.
String metaLine(Iterable<String> parts) =>
    parts.map((p) => p.trim()).where((p) => p.isNotEmpty).join(' · ');
