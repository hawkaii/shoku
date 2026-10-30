"""Wire schemas for /v1/sync.

Row payloads use the client's column names verbatim, minus ``dirty`` (a
client-only flag that means "not yet pushed").
"""

from datetime import datetime, timezone
from typing import Annotated, Literal

from pydantic import BaseModel, ConfigDict, Field, StringConstraints, field_validator

DishStatus = Literal["toCook", "cooked", "signature"]
CookOutcome = Literal["needsWork", "good", "nailedIt"]
CookMood = Literal["quick", "project", "comfort"]
OriginKind = Literal["mine", "import"]

RowId = Annotated[str, StringConstraints(min_length=1, max_length=64)]
UserId = Annotated[str, StringConstraints(min_length=1, max_length=128)]
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
    def _aware(cls, value):
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
