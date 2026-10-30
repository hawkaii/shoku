"""Wire schemas for imports, content, assistant and photos."""

from datetime import datetime
from typing import Annotated, Literal

from pydantic import BaseModel, ConfigDict, Field, StringConstraints

from .recipe import ProsePayload, RecipePayload

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
    # Optional client hint; the server always prefixes it with the user's own
    # id so one user cannot write into another's namespace.
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


class UsageCapExceeded(BaseModel):
    detail: str
    cap: int
    used: int


__all__ = [
    "AssistantRequest",
    "AssistantResponse",
    "ContentResponse",
    "HealthResponse",
    "ImportRequest",
    "ImportResponse",
    "ImportState",
    "ImportStatus",
    "PresignRequest",
    "PresignResponse",
    "UsageCapExceeded",
    "Field",
]
