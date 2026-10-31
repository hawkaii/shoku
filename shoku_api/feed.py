"""The Wall: deliberately shared extractions, and the moderation around them.

Two rules decide everything here.

**What is shared is the extraction, never the user's work.** ``content_cache``
holds the parse of a reel and has never known who imported it. Publishing sets
one boolean on that row. Dish metadata, recipe versions, cooks and photos live
in user-owned tables and this module never reads them — a card cannot leak an
edit because the query has no way to reach one.

**Publishing is an explicit act.** ``shared`` is set in exactly two functions,
``publish`` and ``unpublish``, both reached from an authenticated endpoint. It
is never touched in the import pipeline, never defaulted true and never
backfilled: a convenience that set it on insert would put every journal anyone
has ever imported on the Wall.

Moderation is two independent things. A takedown (``content.takedown``) erases
the payload and hides the row from the feed forever. A report counts *distinct
users*: the ``content_reports`` row is what makes that true, so one account
cannot unshare anything by tapping repeatedly.
"""

from datetime import datetime, timezone

from sqlalchemy import and_, or_, select
from sqlalchemy.orm import Session

from .domain.clock import Clock
from .domain.errors import NotFound, Unavailable
from .domain.feed_cursor import FeedPosition, decode_feed_cursor, encode_feed_cursor
from .models import ContentCache, ContentReport
from .schemas import FeedItem, FeedResponse, RecipePayload


def _visible():
    """The only rows the Wall may show.

    Spelled once so no endpoint can forget a clause: published, still holding a
    parse, and not taken down.
    """
    return and_(
        ContentCache.shared.is_(True),
        ContentCache.structured_json.isnot(None),
        ContentCache.deleted_at.is_(None),
    )


def list_feed(
    session: Session,
    *,
    limit: int = 20,
    cursor: str | None = None,
) -> FeedResponse:
    """Newest first, one page, keyset on ``(created_at, shortcode)``.

    The tie-break is not decoration: imports happen in bursts and share a
    timestamp to the microsecond often enough that a bare timestamp cursor drops
    cards silently.
    """
    try:
        # A cursor is opaque and disposable. A corrupt one means "start the
        # page over", never "fail the feed".
        position = decode_feed_cursor(cursor)
    except ValueError:
        position = None

    stmt = select(ContentCache).where(_visible())
    if position is not None:
        stmt = stmt.where(
            or_(
                ContentCache.created_at < position.created_at,
                and_(
                    ContentCache.created_at == position.created_at,
                    ContentCache.shortcode < position.shortcode,
                ),
            )
        )
    stmt = stmt.order_by(
        ContentCache.created_at.desc(), ContentCache.shortcode.desc()
    ).limit(limit + 1)

    rows = list(session.scalars(stmt).all())
    has_more = len(rows) > limit
    rows = rows[:limit]

    items = [item for item in (_to_item(row) for row in rows) if item is not None]

    next_cursor = None
    if has_more and rows:
        last = rows[-1]
        next_cursor = encode_feed_cursor(
            FeedPosition(
                created_at=_aware(last.created_at), shortcode=last.shortcode
            )
        )

    return FeedResponse(items=items, cursor=next_cursor, has_more=has_more)


def _aware(value: datetime) -> datetime:
    # SQLite hands back naive UTC; Postgres does not. One shape for the cursor.
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value.astimezone(timezone.utc)


def _to_item(row: ContentCache) -> FeedItem | None:
    """A row the current schema cannot parse is skipped, not fatal.

    One unreadable row must not take down the whole Wall for everyone; it is
    also not worth serving half a card.
    """
    try:
        recipe = RecipePayload.model_validate(row.structured_json)
    except Exception:  # noqa: BLE001 - a bad row is not a broken feed
        return None
    return FeedItem(
        shortcode=row.shortcode,
        title=recipe.title,
        thumbnail_url=row.thumbnail_url,
        creator=row.creator,
        creator_handle=row.creator_handle,
        platform=row.platform,
        steps=list(recipe.steps),
        tags=list(recipe.tags),
        extraction_version=row.extraction_version,
        created_at=_aware(row.created_at),
        url=row.source_url,
    )


def _shareable(session: Session, shortcode: str) -> ContentCache:
    row = session.get(ContentCache, shortcode)
    if row is None or row.deleted_at is not None or row.structured_json is None:
        raise NotFound(detail=f"no cached content for {shortcode!r}")
    return row


def publish(session: Session, shortcode: str) -> ContentCache:
    """The one place ``shared`` goes true. Idempotent."""
    row = _shareable(session, shortcode)
    if not row.shared:
        row.shared = True
        session.flush()
    return row


def unpublish(session: Session, shortcode: str) -> ContentCache:
    """The one place ``shared`` goes false, by a user. Idempotent."""
    row = session.get(ContentCache, shortcode)
    if row is None:
        raise NotFound(detail=f"no content for {shortcode!r}")
    if row.shared:
        row.shared = False
        session.flush()
    return row


def report(
    session: Session,
    *,
    shortcode: str,
    user_id: str,
    threshold: int,
    clock: Clock,
) -> ContentCache:
    """Count a distinct reporter, and unshare once enough of them agree.

    A repeat report from the same account changes nothing — the primary key on
    ``content_reports`` does that, so the counter is a count of people rather
    than a count of taps.
    """
    if threshold < 2:
        # A threshold of one would hand any single account a takedown button.
        raise Unavailable(detail="report threshold must be at least 2")

    row = session.get(ContentCache, shortcode)
    if row is None or row.deleted_at is not None or row.structured_json is None:
        raise NotFound(detail=f"no content for {shortcode!r}")

    existing = session.get(ContentReport, (shortcode, user_id))
    if existing is None:
        session.add(
            ContentReport(shortcode=shortcode, user_id=user_id, created_at=clock.now())
        )
        session.flush()
        row.reported_count = int(row.reported_count or 0) + 1
        if row.reported_count >= threshold and row.shared:
            # Unpublished, not deleted: the extraction is still good for
            # everyone who imports it themselves, it just leaves the Wall.
            row.shared = False
        session.flush()

    return row
