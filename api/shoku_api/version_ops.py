"""Recipe edits as data: ops in, new arrays out, no model and no database.

The assistant proposes; this module applies. It is deliberately standalone
because the suggestion engine will reuse the same shape: an index-addressed op
list against one version's arrays, producing the resulting arrays plus a diff a
card can render.

Two invariants hold here and nowhere else:

* an op names **positions, never ids**. The model never sees a row id, so it
  cannot invent one, and a replay against a different version is a validation
  error rather than a write against the wrong recipe.
* when an ingredient moves, the step links move with it. ``step_ingredients``
  is rebuilt on every apply, so an edit that inserts or removes an ingredient
  cannot leave a step pointing one line off — the failure mode that looks
  correct on screen.
"""

from dataclasses import dataclass

#: The closed set the model may emit. Anything else is rejected before it can
#: touch an array — the whitelist is the write path's only shape.
OPS = (
    "add_ingredient",
    "remove_ingredient",
    "substitute_ingredient",
    "adjust_amount",
    "edit_step",
)

#: How many ops one turn may carry. A diff card is for a change, not a rewrite.
MAX_OPS = 8


class OpError(Exception):
    """An op that cannot be applied to this recipe.

    The user gets a clarify, not a write: the intent was understood but the
    target was not, and guessing is how a recipe silently loses a line.
    """


@dataclass(frozen=True)
class Recipe:
    ingredients: list[str]
    steps: list[str]
    #: Parallel to ``steps``; None when the source never said.
    step_ingredients: list[list[int]] | None = None


@dataclass(frozen=True)
class Edit:
    """One line of the diff card. ``previous`` is what it replaced, if anything."""

    op: str  # add | change | remove
    field: str  # ingredients | steps
    index: int
    text: str | None
    previous: str | None


def _shift(links: list[list[int]] | None, *, at: int, delta: int) -> list[list[int]] | None:
    """Move every citation at or after ``at`` by ``delta``."""
    if links is None:
        return None
    moved: list[list[int]] = []
    for cited in links:
        moved.append([index + delta if index >= at else index for index in cited])
    return moved


def _require_index(index: int, limit: int, what: str) -> int:
    """``limit`` is exclusive: the caller says how many lines exist."""
    if not isinstance(index, int) or isinstance(index, bool):
        raise OpError(f"{what} needs an index")
    if index < 0 or index >= limit:
        raise OpError(f"{what} index {index} is outside 0..{limit - 1}")
    return index


def apply(recipe: Recipe, ops: list[dict]) -> tuple[Recipe, list[Edit], list[str]]:
    """Apply ``ops`` in order and return the result, its diff, and its changes.

    Raises ``OpError`` for anything that cannot be applied, leaving the caller's
    recipe untouched — nothing here mutates its input.
    """
    if not ops:
        raise OpError("no edits were proposed")
    if len(ops) > MAX_OPS:
        raise OpError(f"too many edits in one turn ({len(ops)} > {MAX_OPS})")

    ingredients = list(recipe.ingredients)
    steps = list(recipe.steps)
    links = None if recipe.step_ingredients is None else [list(c) for c in recipe.step_ingredients]
    edits: list[Edit] = []
    changes: list[str] = []

    for op in ops:
        name = op.get("op")
        if name not in OPS:
            raise OpError(f"unknown op {name!r}")

        if name == "add_ingredient":
            text = _text(op)
            at = op.get("index")
            at = len(ingredients) if at is None or at == -1 else at
            if not 0 <= at <= len(ingredients):
                raise OpError(f"cannot insert an ingredient at {at}")
            ingredients.insert(at, text)
            links = _shift(links, at=at, delta=1)
            edits.append(Edit("add", "ingredients", at, text, None))
            changes.append(f"Added {text}")

        elif name == "remove_ingredient":
            at = _require_index(op.get("index"), len(ingredients), "remove_ingredient")
            removed = ingredients.pop(at)
            if links is not None:
                # Drop citations of the removed line, then close the gap.
                links = [
                    [i - 1 if i > at else i for i in cited if i != at] for cited in links
                ]
            edits.append(Edit("remove", "ingredients", at, None, removed))
            changes.append(f"Removed {removed}")

        elif name in ("substitute_ingredient", "adjust_amount"):
            at = _require_index(op.get("index"), len(ingredients), name)
            text = _text(op)
            previous = ingredients[at]
            ingredients[at] = text
            edits.append(Edit("change", "ingredients", at, text, previous))
            changes.append(
                f"Replaced {previous} with {text}"
                if name == "substitute_ingredient"
                else f"Changed {previous} to {text}"
            )

        else:  # edit_step
            text = _text(op)
            at = op.get("index")
            if not isinstance(at, int) or isinstance(at, bool):
                raise OpError("edit_step needs an index")
            cited = op.get("ingredient_indices")
            if at == len(steps):  # append: the model's way of adding a step
                steps.append(text)
                if links is not None:
                    links.append(_check_citations(cited, len(ingredients)))
                edits.append(Edit("add", "steps", at, text, None))
                changes.append(f"Added step {at + 1}: {text}")
            elif 0 <= at < len(steps):
                previous = steps[at]
                steps[at] = text
                if links is not None and cited is not None:
                    links[at] = _check_citations(cited, len(ingredients))
                edits.append(Edit("change", "steps", at, text, previous))
                changes.append(f"Edited step {at + 1}")
            else:
                raise OpError(f"edit_step index {at} is outside 0..{len(steps)}")

    return Recipe(ingredients, steps, links), edits, changes


def _text(op: dict) -> str:
    text = (op.get("text") or "").strip()
    if not text:
        raise OpError(f"{op.get('op')} needs a line of text")
    if len(text) > 600:
        raise OpError("that line is too long to be a recipe line")
    return text


def _check_citations(cited, ingredient_count: int) -> list[int]:
    if not cited:
        return []
    return sorted({int(i) for i in cited if 0 <= int(i) < ingredient_count})
