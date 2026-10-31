import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';

/// Step text with the operative words picked out: quantities, temperatures and
/// times get the monospace treatment; cooking verbs stay bold in the body face.
/// This is what makes a 2-line instruction scannable at arm's length.
class StepText extends StatelessWidget {
  final String text;
  final double fontSize;
  final List<String> ingredients;

  const StepText({
    super.key,
    required this.text,
    this.fontSize = 26,
    this.ingredients = const [],
  });

  static const _verbs = [
    'fold',
    'whisk',
    'whip',
    'chop',
    'slice',
    'cube',
    'simmer',
    'boil',
    'fry',
    'sear',
    'bake',
    'roast',
    'chill',
    'rest',
    'season',
    'deglaze',
    'toss',
    'drain',
    'separate',
    'crack',
    'divide',
    'serve',
    'cover',
    'leave',
  ];

  static final _quantity = RegExp(
    r'\d+\s?(?:minutes|minute|min|mins|hours|hour|°C|g|kg|ml|tbsp|tsp|cloves?)',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = ShokuType.h1.copyWith(color: c.ink, fontSize: fontSize, height: 1.3);
    final words = <String>{..._verbs};
    for (final ingredient in ingredients) {
      for (final word in ingredient.toLowerCase().split(RegExp(r'[^a-z]+'))) {
        if (word.length > 2) words.add(word);
      }
    }
    final token = RegExp(
      '(' + _quantity.pattern + r')|\b(' + words.join('|') + r')\b',
      caseSensitive: false,
    );

    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in token.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final isQuantity = match.group(1) != null;
      spans.add(
        TextSpan(
          text: match.group(0)!,
          style: isQuantity
              ? ShokuType.stat.copyWith(
                  fontSize: fontSize * 0.8,
                  color: c.accent,
                  height: 1.3,
                )
              : base.copyWith(fontWeight: FontWeight.w700),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return RichText(
      text: TextSpan(style: base, children: spans),
    );
  }
}
