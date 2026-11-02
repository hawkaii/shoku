"""Pantry names, and how a recipe matches them.

Matching is **name-only set containment**. Quantities, units and amounts are not
part of it: a pantry holding "butter" covers a recipe calling for 2 tbsp butter,
because whether you have enough is a question the app asks the cook, not one a
token overlap can answer.

Four normalisations, and each exists because a real receipt or reel produced it:

* lowercase, so "Butter" and "butter" are one thing;
* drop parentheticals — "ghee (clarified butter)";
* drop everything after a comma — "onions, finely chopped";
* fold plurals — "onions" and "onion" are the same shelf.

Aliases are user-confirmed strings such as "AMUL BUTTER 500G". They are expanded
into the same token space as names, which is what lets a receipt line meet a
recipe line.
"""

import re
from fractions import Fraction

#: Below this share of a recipe's ingredients, a card is a shopping trip rather
#: than a suggestion. A product decision, not a technical one: 1 of 5 is not a
#: recipe you can cook tonight, and leading with it wastes the shelf.
MIN_COVERAGE = Fraction(2, 5)

_PARENTHETICAL = re.compile(r"\([^)]*\)")
_NOT_A_NAME = re.compile(r"[^a-z0-9\s'-]")

#: Units and bare numbers are noise in an alias ("AMUL BUTTER 500G").
_AMOUNT = re.compile(
    r"\b\d+(?:[.,]\d+)?\s*(?:g|kg|ml|l|tbsp|tsp|pcs|bunch|pack|gm|grams?|kgs?)?\b",
    re.IGNORECASE,
)


def normalise(text: str) -> str:
    """One ingredient or alias, reduced to the words that name it."""
    lowered = (text or "").lower()
    lowered = _PARENTHETICAL.sub(" ", lowered)
    lowered = lowered.split(",")[0]
    lowered = _AMOUNT.sub(" ", lowered)
    lowered = _NOT_A_NAME.sub(" ", lowered)
    return " ".join(lowered.split())


def singular(word: str) -> str:
    """A deliberately small plural fold.

    Not a stemmer: a wrong stem matches the wrong shelf, which is worse than
    missing a match the cook can fix with an alias. "tomatoes" → "tomato",
    "onions" → "onion", and anything ending in "ss" is left alone.
    """
    if len(word) <= 3:
        return word
    if word.endswith("ies") and len(word) > 4:
        return word[:-3] + "y"
    for suffix in ("ches", "shes", "sses", "xes", "zes", "oes"):
        if word.endswith(suffix):
            return word[:-2]
    if word.endswith("s") and not word.endswith("ss"):
        return word[:-1]
    return word


def tokens(text: str) -> set[str]:
    """The token set for one name or alias."""
    return {singular(word) for word in normalise(text).split()}


def pantry_tokens(items) -> set[str]:
    """Every token the caller's stock can offer, names and aliases alike.

    ``wanted`` rows are excluded by the caller: a shopping-list entry is
    something you are missing, not something you have.
    """
    every: set[str] = set()
    for item in items:
        every |= tokens(item.name)
        for alias in item.aliases or ():
            every |= tokens(str(alias))
    return every


def covers_enough(have: int, total: int) -> bool:
    """Whether a card clears the floor. Exact arithmetic, not a float compare."""
    return total > 0 and Fraction(have, total) >= MIN_COVERAGE


def coverage(ingredient_names, have: set[str]) -> tuple[int, list[str]]:
    """How many ingredients are covered, and which are not.

    An ingredient is covered when its tokens share anything with the pantry. One
    shared token is enough: "red onions" is covered by "onion", and requiring
    every token would fail on every adjective a recipe is entitled to use.
    """
    matched = 0
    missing: list[str] = []
    for name in ingredient_names:
        if tokens(name) & have:
            matched += 1
        else:
            missing.append(name)
    return matched, missing
