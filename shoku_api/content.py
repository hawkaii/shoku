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
    clock: Clock,
    overwrite: bool = False,
) -> ContentCache:
    row = session.get(ContentCache, shortcode)
    payload: dict[str, Any] = {
        "structured_json": recipe.model_dump(mode="json"),
        "prose_json": prose.model_dump(mode="json"),
        "creator": creator,
        "source_url": source_url,
        "extraction_version": extraction_version,
    }

    if row is None:
        row = ContentCache(shortcode=shortcode, created_at=clock.now(), **payload)
        session.add(row)
        session.flush()
        return row

    if not overwrite:
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
