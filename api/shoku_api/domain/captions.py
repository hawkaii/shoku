"""Caption-first detection.

ASR is the expensive, failure-prone half of extraction. If the caption already
carries quantities, it is a better source than any transcript: the creator
typed it. So we check before spending a single second of audio.
"""

import re

# Units that make a caption a usable recipe. Ordered longest-first at match
# time so "tbsp" is not read as "t".
_UNITS = (
    "tablespoons",
    "tablespoon",
    "teaspoons",
    "teaspoon",
    "tbsp",
    "tsp",
    "grams",
    "gram",
    "kilograms",
    "kilogram",
    "ounces",
    "ounce",
    "pounds",
    "pound",
    "cups",
    "cup",
    "ml",
    "kg",
    "oz",
    "lb",
    "g",
    "l",
)

_UNIT_PATTERN = "|".join(re.escape(u) for u in _UNITS)

_QUANTITY = re.compile(
    rf"""
    (?:
        \d+\s*(?:/|of\s+)\s*\d+            # 1/2, 1 of 2
      | \d+(?:[.,]\d+)?\s*(?:{_UNIT_PATTERN})\b   # 200 g, 1.5 cups
      | \b(?:a|an|one|two|three|four|five|six|half|quarter)\s+(?:{_UNIT_PATTERN})\b
    )
    """,
    re.IGNORECASE | re.VERBOSE,
)

# "4 eggs", "2 onions" — counts of whole ingredients, which are just as good.
_COUNT = re.compile(
    r"\b\d{1,3}\s+(?:eggs?|onions?|cloves?|clove|slices?|cans?|tins?|sprigs?|"
    r"chicken|potatoes?|tomatoes?|lemons?|limes?|garlic|shallots?|carrots?)\b",
    re.IGNORECASE,
)

_MIN_CAPTION_CHARS = 40


def has_quantities(caption: str | None) -> bool:
    """True when the caption looks like a recipe rather than a vibe."""
    if not caption:
        return False
    text = caption.strip()
    if len(text) < _MIN_CAPTION_CHARS:
        return False
    return bool(_QUANTITY.search(text) or _COUNT.search(text))
