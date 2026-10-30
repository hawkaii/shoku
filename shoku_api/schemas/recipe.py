"""Structured extraction, in two tiers.

``RecipePayload`` is the machine tier: it is what a client may trust to plan,
shop and cook. Nothing reaches it without passing validation, and validation is
strict on purpose — unknown keys are rejected outright so a hostile caption
cannot smuggle instructions into fields the app later renders or follows.

``ProsePayload`` is the display tier: free text with hard caps. It is never
parsed for meaning, never executed, and never merged into a recipe.
"""

from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field, StringConstraints

# A single line of instruction. Long enough for a real step, short enough that
# a caption cannot become a novel.
StepText = Annotated[str, StringConstraints(min_length=1, max_length=600)]
TagText = Annotated[str, StringConstraints(min_length=1, max_length=40)]
NameText = Annotated[str, StringConstraints(min_length=1, max_length=120)]
AmountText = Annotated[str, StringConstraints(min_length=1, max_length=64)]


class StrictModel(BaseModel):
    model_config = ConfigDict(
        extra="forbid",
        strict=True,
        str_strip_whitespace=True,
    )


class Ingredient(StrictModel):
    name: NameText
    amount: AmountText | None = None
    grams: float | None = Field(default=None, ge=0, le=10000, allow_inf_nan=False)


class RecipePayload(StrictModel):
    """The trusted tier: quantities, ranges, ordinals — everything bounded."""

    title: Annotated[str, StringConstraints(min_length=1, max_length=120)]
    servings: int = Field(ge=1, le=50)
    minutes: int = Field(ge=0, le=1440)
    kcal: int = Field(ge=0, le=5000)
    protein: int = Field(ge=0, le=500)
    ingredients: list[Ingredient] = Field(min_length=1, max_length=60)
    steps: list[StepText] = Field(min_length=1, max_length=40)
    tags: list[TagText] = Field(default_factory=list, max_length=20)


class ProsePayload(StrictModel):
    """Display only. Capped so a wall of text cannot bloat the cache or UI."""

    summary: Annotated[str, StringConstraints(min_length=0, max_length=1200)]
    creator_note: Annotated[str, StringConstraints(min_length=0, max_length=600)] = ""
