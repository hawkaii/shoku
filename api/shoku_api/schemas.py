"""Wire schemas.

Two tiers of extraction payload, and they are not interchangeable:

* ``RecipePayload`` is the machine tier — quantities, ranges, ordinals, every
  string capped, every unknown key rejected. A client may cook from it.
* ``ProsePayload`` is the display tier — free text, hard-capped, never parsed
  for meaning and never merged into a recipe.

``extra="forbid"`` is the load-bearing part. A hostile caption that manages to
produce a ``{instructions: "ignore previous instructions"}`` key fails
validation instead of riding along inside the JSON a client later reads.
"""

from datetime import datetime, timezone
from typing import Annotated, Any, Literal

from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    StringConstraints,
    field_validator,
    model_validator,
)

# ---------------------------------------------------------------------------
# Tier 1: strict extraction payloads
# ---------------------------------------------------------------------------

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


def check_step_ingredients(
    steps: list[str], ingredient_count: int, links: list[list[int]] | None
) -> None:
    """The one place step↔ingredient links are judged true.

    Shared by the extraction payload and by an applied edit (``version_ops``):
    both produce the same field for the same client, so a link that would be
    rejected on the wire must not be produced by the assistant either.
    """
    if links is None:
        return
    if len(links) != len(steps):
        raise ValueError(
            "step_ingredients needs one entry per step: "
            f"{len(links)} for {len(steps)} steps"
        )
    for step, cited in enumerate(links):
        for index in cited:
            if not 0 <= index < ingredient_count:
                raise ValueError(
                    f"step {step} cites ingredient {index}, "
                    f"but there are {ingredient_count}"
                )


class Ingredient(StrictModel):
    name: NameText
    amount: AmountText | None = None
    grams: float | None = Field(default=None, ge=0, le=10_000, allow_inf_nan=False)


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
    #: Which ingredients each step uses, by zero-based position in
    #: ``ingredients``. One entry per step, in step order. ``None`` means the
    #: source never said — every parse written before this field existed, and
    #: every heuristic parse. A client renders nothing for it; an index that
    #: pointed at no ingredient would be a lie, so it is refused here.
    step_ingredients: list[list[int]] | None = None

    @model_validator(mode="after")
    def _citations_point_at_real_ingredients(self) -> "RecipePayload":
        check_step_ingredients(self.steps, len(self.ingredients), self.step_ingredients)
        return self


class ProsePayload(StrictModel):
    """Display only. Capped so a wall of text cannot bloat the cache or the UI."""

    summary: Annotated[str, StringConstraints(min_length=0, max_length=1200)]
    creator_note: Annotated[str, StringConstraints(min_length=0, max_length=600)] = ""


# ---------------------------------------------------------------------------
# Sync
# ---------------------------------------------------------------------------

DishStatus = Literal["toCook", "cooked", "signature"]
CookOutcome = Literal["needsWork", "good", "nailedIt"]
CookMood = Literal["quick", "project", "comfort"]
OriginKind = Literal["mine", "import"]
#: Which surface a photo hangs on. ``cover`` is not a role: the dish cover is
#: ``dishes.cover_url`` and has exactly one source of truth.
PhotoRole = Literal["version", "debrief"]
#: Unit-local: counts never convert to weight or volume, so they are named.
PantryUnit = Literal["g", "kg", "ml", "l", "tbsp", "tsp", "pcs", "bunch", "pack"]
#: Where an item first came from. Recorded, not editable.
PantrySource = Literal["photo", "voice", "typed", "manual"]

RowId = Annotated[str, StringConstraints(min_length=1, max_length=64)]
Url = Annotated[str, StringConstraints(max_length=2048)]


def as_utc(value: datetime | None) -> datetime | None:
    if value is None:
        return None
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value.astimezone(timezone.utc)


class SyncRow(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    @field_validator("*", mode="after")
    @classmethod
    def _aware(cls, value: Any) -> Any:
        return as_utc(value) if isinstance(value, datetime) else value


class DishRowIn(SyncRow):
    id: RowId
    title: Annotated[str, StringConstraints(min_length=1, max_length=200)]
    subtitle: Annotated[str, StringConstraints(max_length=400)] = ""
    cover_url: Url = ""
    source_handle: Annotated[str, StringConstraints(max_length=200)] = ""
    status: DishStatus = "toCook"
    minutes: int = Field(default=0, ge=0, le=100_000)
    baseline_kcal: int = Field(default=0, ge=0, le=100_000)
    baseline_protein: int = Field(default=0, ge=0, le=10_000)
    steps: list[Annotated[str, StringConstraints(max_length=2000)]] = Field(
        default_factory=list, max_length=200
    )
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None = None


class VersionRowIn(SyncRow):
    id: RowId
    dish_id: RowId
    number: int = Field(default=0, ge=0, le=10_000)
    changes: list[Annotated[str, StringConstraints(max_length=300)]] = Field(
        default_factory=list, max_length=100
    )
    ingredients: list[Annotated[str, StringConstraints(max_length=300)]] = Field(
        default_factory=list, max_length=200
    )
    steps: list[Annotated[str, StringConstraints(max_length=2000)]] = Field(
        default_factory=list, max_length=200
    )
    tags: list[Annotated[str, StringConstraints(max_length=40)]] = Field(
        default_factory=list, max_length=20
    )
    kcal: int = Field(default=0, ge=0, le=100_000)
    protein: int = Field(default=0, ge=0, le=10_000)
    origin_kind: OriginKind = "mine"
    origin_creator: Annotated[str, StringConstraints(max_length=200)] | None = None
    origin_handle: Annotated[str, StringConstraints(max_length=200)] | None = None
    origin_platform: Annotated[str, StringConstraints(max_length=32)] | None = None
    origin_url: Url | None = None
    origin_shortcode: Annotated[str, StringConstraints(max_length=64)] | None = None
    parent_version_id: RowId | None = None
    extraction_version: int = Field(default=0, ge=0, le=1_000_000)
    created_at: datetime


class CookLogRowIn(SyncRow):
    id: RowId
    dish_id: RowId
    version_id: RowId | None = None
    version_number: int = Field(default=0, ge=0, le=10_000)
    cooked_at: datetime
    photo_url: Url = ""
    photo_state: Literal["none", "local", "synced"] = "none"
    outcome: CookOutcome = "good"
    mood: CookMood = "comfort"
    note: Annotated[str, StringConstraints(max_length=2000)] = ""
    changes: list[Annotated[str, StringConstraints(max_length=300)]] = Field(
        default_factory=list, max_length=100
    )
    rating: int = Field(default=3, ge=1, le=5)


class PhotoRowIn(SyncRow):
    id: RowId
    role: PhotoRole
    # Exactly one target, decided by ``role``: a version photo hangs off the
    # recipe variant it documents, a debrief photo off the night it was cooked.
    version_id: RowId | None = None
    cook_id: RowId | None = None
    key: Annotated[str, StringConstraints(min_length=1, max_length=512)]
    created_at: datetime
    deleted_at: datetime | None = None


class PantryRowIn(SyncRow):
    id: RowId
    name: Annotated[str, StringConstraints(min_length=1, max_length=200)]
    #: Null means "have it, amount unknown" — never zero, never guessed.
    quantity: float | None = Field(default=None, ge=0, le=1_000_000)
    unit: PantryUnit | None = None
    aliases: list[Annotated[str, StringConstraints(max_length=120)]] = Field(
        default_factory=list, max_length=20
    )
    #: The shopping-list flag: a wanted row is not stock.
    wanted: bool = False
    source: PantrySource = "typed"
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None = None


class PushRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    dishes: list[DishRowIn] = Field(default_factory=list, max_length=500)
    versions: list[VersionRowIn] = Field(default_factory=list, max_length=1000)
    cook_logs: list[CookLogRowIn] = Field(default_factory=list, max_length=1000)
    photos: list[PhotoRowIn] = Field(default_factory=list, max_length=2000)
    pantry_items: list[PantryRowIn] = Field(default_factory=list, max_length=1000)


class PullRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    since: datetime | None = None
    cursor: str | None = None
    limit: int | None = Field(default=None, ge=1, le=1000)


class DishRowOut(SyncRow):
    model_config = ConfigDict(extra="forbid", from_attributes=True)

    id: str
    title: str
    subtitle: str
    cover_url: str
    source_handle: str
    status: str
    minutes: int
    baseline_kcal: int
    baseline_protein: int
    steps: list[str]
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None


class VersionRowOut(SyncRow):
    model_config = ConfigDict(extra="forbid", from_attributes=True)

    id: str
    dish_id: str
    number: int
    changes: list[str]
    ingredients: list[str]
    steps: list[str]
    tags: list[str] = Field(default_factory=list)
    kcal: int
    protein: int
    origin_kind: str
    origin_creator: str | None
    origin_handle: str | None
    origin_platform: str | None
    origin_url: str | None
    origin_shortcode: str | None
    parent_version_id: str | None
    extraction_version: int
    created_at: datetime


class CookLogRowOut(SyncRow):
    model_config = ConfigDict(extra="forbid", from_attributes=True)

    id: str
    dish_id: str
    version_id: str | None
    version_number: int
    cooked_at: datetime
    photo_url: str
    photo_state: str
    outcome: str
    mood: str
    note: str
    changes: list[str]
    rating: int


class PhotoRowOut(SyncRow):
    model_config = ConfigDict(extra="forbid", from_attributes=True)

    id: str
    role: str
    version_id: str | None
    cook_id: str | None
    key: str
    #: Derived from the storage base at read time, never stored. Null when the
    #: deployment has no public base configured; a client that uploaded the
    #: photo already holds the URL presign returned and falls back to it.
    url: str | None = None
    created_at: datetime
    deleted_at: datetime | None


class PantryRowOut(SyncRow):
    model_config = ConfigDict(extra="forbid", from_attributes=True)

    id: str
    name: str
    quantity: float | None
    unit: str | None
    aliases: list[str]
    wanted: bool
    source: str
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None


class PullResponse(BaseModel):
    dishes: list[DishRowOut]
    versions: list[VersionRowOut]
    cook_logs: list[CookLogRowOut]
    photos: list[PhotoRowOut] = Field(default_factory=list)
    pantry_items: list[PantryRowOut] = Field(default_factory=list)
    cursor: str | None
    has_more: bool
    server_time: datetime


class RowResult(BaseModel):
    id: str
    result: Literal["accepted", "ignored", "conflict"]
    reason: str | None = None


class PushResponse(BaseModel):
    dishes: list[RowResult]
    versions: list[RowResult]
    cook_logs: list[RowResult]
    photos: list[RowResult] = Field(default_factory=list)
    pantry_items: list[RowResult] = Field(default_factory=list)


# ---------------------------------------------------------------------------
# Imports, content, assistant, photos, health
# ---------------------------------------------------------------------------

ImportState = Literal["queued", "extracting", "ready", "failed"]


class ImportRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    url: Annotated[str, StringConstraints(min_length=8, max_length=2048)]


class ImportResponse(BaseModel):
    # Null on a cache hit: no job exists because no work was needed.
    job_id: str | None
    state: ImportState
    cached: bool
    shortcode: str


class ImportStatus(BaseModel):
    job_id: str
    state: ImportState
    shortcode: str
    reason: str | None = None
    progress_stage: str | None = None
    created_at: datetime
    updated_at: datetime


class ContentResponse(BaseModel):
    shortcode: str
    recipe: RecipePayload
    prose: ProsePayload
    creator: str | None
    #: Attributable provenance: "@handle", the platform, and the reel's cover.
    creator_handle: str | None = None
    platform: str | None = None
    thumbnail_url: str | None = None
    url: str
    extraction_version: int


class FeedItem(BaseModel):
    """One card on the Wall.

    An extraction, deliberately shared — never a user's work. There is no
    ``user_id`` here and there must never be one: ``content_cache`` does not
    know who imported a reel, which is exactly what makes the Wall safe to
    publish. Edits live in ``recipe_versions`` and are not joined.
    """

    shortcode: str
    title: str
    thumbnail_url: str | None = None
    creator: str | None = None
    creator_handle: str | None = None
    platform: str | None = None
    steps: list[str]
    tags: list[str]
    extraction_version: int
    created_at: datetime
    url: str


class FeedResponse(BaseModel):
    items: list[FeedItem]
    cursor: str | None = None
    has_more: bool = False


class FeedMatch(BaseModel):
    """Coverage of one card against the caller's pantry. Names only."""

    have: int
    total: int
    #: The names not covered, ready to become ``wanted`` pantry rows.
    missing: list[str]


class SuggestionItem(FeedItem):
    """A Wall card plus what the caller would still need to buy.

    Additive to ``FeedItem``: same fields, same guarantee — no ``user_id`` and
    no importer, because the match is computed from the caller's own pantry and
    the card is still just an extraction.
    """

    ingredients: list[str]
    match: FeedMatch


class SuggestionResponse(BaseModel):
    items: list[SuggestionItem]
    cursor: str | None = None
    has_more: bool = False


class ShareResponse(BaseModel):
    shortcode: str
    shared: bool


class ReportResponse(BaseModel):
    shortcode: str
    reported_count: int
    shared: bool


class AssistantTurn(BaseModel):
    model_config = ConfigDict(extra="forbid")

    role: Literal["user", "assistant"]
    text: Annotated[str, StringConstraints(min_length=1, max_length=1200)]


class AssistantRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    dish_id: Annotated[str, StringConstraints(min_length=1, max_length=64)]
    version_id: Annotated[str, StringConstraints(min_length=1, max_length=64)] | None = None
    question: Annotated[str, StringConstraints(min_length=1, max_length=1000)]
    #: Deduplicates the cap reservation: a retried POST is metered once.
    request_id: Annotated[str, StringConstraints(min_length=8, max_length=64)]
    #: The client's own last exchanges, so a follow-up to "clarify" has context.
    history: list[AssistantTurn] = Field(default_factory=list, max_length=4)


class AssistantEdit(BaseModel):
    """One line of the diff card. ``appliable`` is what actually gets written."""

    op: Literal["add", "change", "remove"]
    field: Literal["ingredients", "steps"]
    index: int
    text: str | None = None
    previous: str | None = None


class AssistantAppliable(BaseModel):
    ingredients: list[str]
    steps: list[str]
    #: Recomputed against the arrays above, same rules as the content payload.
    step_ingredients: list[list[int]] | None = None
    changes: list[str]
    #: The head the client must still hold before it applies this.
    base_version_id: str


class AssistantResponse(BaseModel):
    intent: Literal["answer", "clarify", "edit"]
    answer: str
    remaining: int
    #: Next midnight UTC, so the client can say when the cap comes back.
    reset_at: datetime
    edits: list[AssistantEdit] = Field(default_factory=list)
    appliable: AssistantAppliable | None = None


class PantryParseRequest(BaseModel):
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    #: Deduplicates the cap reservation: a retried POST is metered once.
    request_id: Annotated[str, StringConstraints(min_length=8, max_length=64)]
    #: Only the lines the device's own parser could not read. 1–20, no empties.
    lines: list[Annotated[str, StringConstraints(min_length=1, max_length=300)]] = Field(
        min_length=1, max_length=20
    )


class PantryParseItem(BaseModel):
    """One readable receipt line. ``line`` is echoed so the client can line it up."""

    line: str
    name: Annotated[str, StringConstraints(min_length=1, max_length=120)]
    #: Null when the line states no amount — never a guess.
    quantity: float | None = Field(default=None, ge=0, le=1_000_000)
    #: Whitelisted, or null. An unknown unit is dropped, never coerced.
    unit: PantryUnit | None = None


class PantryParseResponse(BaseModel):
    items: list[PantryParseItem]
    remaining: int
    #: Next midnight UTC, for the same sentence the assistant uses.
    reset_at: datetime


class PresignRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    content_type: Annotated[str, StringConstraints(pattern=r"^image/[a-z0-9.+-]+$")] = (
        "image/jpeg"
    )
    # A hint only; the server always builds the key under the caller's uid.
    extension: Annotated[str, StringConstraints(pattern=r"^[a-z0-9]{1,5}$")] | None = None


class PresignResponse(BaseModel):
    key: str
    upload_url: str
    method: Literal["PUT"] = "PUT"
    headers: dict[str, str]
    expires_in: int
    public_url: str | None = None


class HealthResponse(BaseModel):
    status: Literal["ok", "degraded"]
    database: bool
    queue: bool
    version: str


class ErrorResponse(BaseModel):
    detail: str
    reason: str
