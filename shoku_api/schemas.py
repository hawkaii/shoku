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
    kcal: int = Field(default=0, ge=0, le=100_000)
    protein: int = Field(default=0, ge=0, le=10_000)
    origin_kind: OriginKind = "mine"
    origin_creator: Annotated[str, StringConstraints(max_length=200)] | None = None
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


class PushRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    dishes: list[DishRowIn] = Field(default_factory=list, max_length=500)
    versions: list[VersionRowIn] = Field(default_factory=list, max_length=1000)
    cook_logs: list[CookLogRowIn] = Field(default_factory=list, max_length=1000)


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
    kcal: int
    protein: int
    origin_kind: str
    origin_creator: str | None
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


class PullResponse(BaseModel):
    dishes: list[DishRowOut]
    versions: list[VersionRowOut]
    cook_logs: list[CookLogRowOut]
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


class AssistantRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    dish_id: Annotated[str, StringConstraints(min_length=1, max_length=64)]
    version_id: Annotated[str, StringConstraints(min_length=1, max_length=64)] | None = None
    question: Annotated[str, StringConstraints(min_length=1, max_length=1000)]


class AssistantResponse(BaseModel):
    answer: str
    remaining: int


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
