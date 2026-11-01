"""The global content cache.

Extraction is expensive and the result is identical for every user, so the
cache is global and keyed by shortcode alone. A takedown keeps the row and
erases the payload: the stub is what makes the erase permanent, because
``POST /imports`` refuses to re-extract a tombstoned shortcode.
"""

from typing import Any

from sqlalchemy.orm import Session

from .domain.clock import Clock
from .domain.errors import NotFound
from .models import ContentCache
from .schemas import ContentResponse, ProsePayload, RecipePayload


def get_content(session: Session, shortcode: str) -> ContentResponse:
    row = session.get(ContentCache, shortcode)
    if row is None or row.deleted_at is not None or row.structured_json is None:
        raise NotFound(detail=f"no cached content for {shortcode!r}")
    return to_response(row)


def to_response(row: ContentCache) -> ContentResponse:
    return ContentResponse(
        shortcode=row.shortcode,
        recipe=RecipePayload.model_validate(row.structured_json),
        prose=ProsePayload.model_validate(row.prose_json or {}),
        creator=row.creator,
        creator_handle=row.creator_handle,
        platform=row.platform,
        thumbnail_url=row.thumbnail_url,
        url=row.source_url,
        extraction_version=row.extraction_version,
    )


def store_extraction(
    session: Session,
    *,
    shortcode: str,
    recipe: RecipePayload,
    prose: ProsePayload,
    creator: str | None,
    source_url: str,
    extraction_version: int,
    creator_handle: str | None = None,
    platform: str | None = None,
    thumbnail_url: str | None = None,
    structuring_model: str | None = None,
    clock: Clock,
    overwrite: bool = False,
) -> ContentCache:
    row = session.get(ContentCache, shortcode)
    payload: dict[str, Any] = {
        "structured_json": recipe.model_dump(mode="json"),
        "prose_json": prose.model_dump(mode="json"),
        "creator": creator,
        "creator_handle": creator_handle,
        "platform": platform,
        "thumbnail_url": thumbnail_url,
        "structuring_model": structuring_model,
        "source_url": source_url,
        "extraction_version": extraction_version,
    }

    if row is None:
        row = ContentCache(shortcode=shortcode, created_at=clock.now(), **payload)
        session.add(row)
        session.flush()
        return row

    # A row written by an older extraction is a stale parse, not a competing
    # one: the caller is asking for the current version, so it wins. A takedown
    # still blocks it upstream, and an equal version is left alone because
    # re-importing the same reel must not rewrite an identical result.
    if not overwrite and row.extraction_version >= extraction_version:
        return row

    for field, value in payload.items():
        setattr(row, field, value)
    session.flush()
    return row


def takedown(session: Session, shortcode: str, *, clock: Clock) -> None:
    """Erase the payload, keep the stub. Idempotent."""
    row = session.get(ContentCache, shortcode)
    if row is None:
        raise NotFound(detail=f"no content for {shortcode!r}")
    if row.deleted_at is None:
        row.structured_json = None
        row.prose_json = None
        row.deleted_at = clock.now()
        session.flush()


def is_taken_down(session: Session, shortcode: str) -> bool:
    row = session.get(ContentCache, shortcode)
    return row is not None and row.deleted_at is not None
