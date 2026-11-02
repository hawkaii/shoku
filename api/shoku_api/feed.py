"""The Wall: every imported reel, and nothing about who imported it.

Two rules decide everything here.

**The Wall is the cache, minus takedowns.** If a reel has a parse and has not
been taken down, it is listed — importing it is what puts it there. There is no
publish step and no per-user filter. ``content_cache.shared`` and its two
endpoints survive this release for compatibility but gate nothing; see the
module note in ``publish``.

**A card carries the extraction only.** ``content_cache`` holds the parse of a
reel and has never known who imported it. Dish metadata, recipe versions, cooks
and photos live in user-owned tables and this module never reads them — a card
cannot leak an edit because the query has no way to reach one. That is what
makes a global feed safe, and it is the property to defend.

Moderation is a takedown: it erases the payload and hides the row permanently.
A report counts *distinct users* and records a signal on the row; it does not
remove a card, because since the feed went global there is nothing to remove it
from. Treat a reported row as a queue for a human, not an automatic outcome.
"""

from datetime import datetime, timezone
from fractions import Fraction

from sqlalchemy import and_, or_, select
from sqlalchemy.orm import Session

from .domain.clock import Clock
from .domain.errors import NotFound, Unavailable
from .domain.feed_cursor import (
    FeedPosition,
    SuggestionPosition,
    decode_feed_cursor,
    decode_suggestion_cursor,
    encode_feed_cursor,
    encode_suggestion_cursor,
)
from .models import ContentCache, ContentReport, PantryItem
from .pantry import coverage, covers_enough, pantry_tokens
from .schemas import (
    FeedItem,
    FeedMatch,
    FeedResponse,
    RecipePayload,
    SuggestionItem,
    SuggestionResponse,
)


def _visible():
    """The only rows the Wall may show.

    Spelled once so no endpoint can forget a clause: it holds a parse, and it
    has not been taken down.

    There is deliberately **no** ``shared`` clause. The owner decided on 31 Oct
    that the Wall is a global feed of imported reels — importing one lists it —
    rather than an opt-in publish. The ``shared`` column and its endpoints are
    kept but no longer gate visibility.
    """
    return and_(
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


def suggestions(
    session: Session,
    *,
    uid: str,
    limit: int = 20,
    cursor: str | None = None,
) -> SuggestionResponse:
    """Wall cards this caller can mostly cook, against their own pantry.

    The matching is done here rather than in SQL on purpose: the ingredient list
    lives inside ``content_cache.structured_json``, and the contract rules out a
    trigram or full-text index — JSON punctuation dominates trigrams, and
    similarity over one string is not set containment. With the corpus at tens
    of rows, a parse and a token intersection per row is cheap; the contract
    names the table to build if that ever stops being true.

    Nothing user-owned is read except the caller's own pantry, and nothing
    user-owned is returned: the card is still an extraction.
    """
    try:
        position = decode_suggestion_cursor(cursor)
    except ValueError:
        position = None

    stock = session.scalars(
        select(PantryItem).where(
            PantryItem.user_id == uid,
            PantryItem.deleted_at.is_(None),
            # Wanted rows are the shopping list, not stock.
            PantryItem.wanted.is_(False),
        )
    ).all()
    have_tokens = pantry_tokens(stock)

    # coverage, absolute matches, then recency, then shortcode — in that order.
    ranked: list[tuple[Fraction, int, datetime, str, SuggestionItem]] = []
    for row in session.scalars(select(ContentCache).where(_visible())).all():
        card = _to_item(row)
        if card is None:
            continue
        recipe = RecipePayload.model_validate(row.structured_json)
        names = [ingredient.name for ingredient in recipe.ingredients]
        have, missing = coverage(names, have_tokens)
        if not covers_enough(have, len(names)):
            # Owner's floor: a card you own a fifth of is a shopping trip. With a
            # sparse pantry the shelf is honestly empty, not misleadingly full.
            continue
        ranked.append(
            (
                Fraction(have, len(names)),
                have,
                _aware(row.created_at),
                row.shortcode,
                SuggestionItem(
                    **card.model_dump(),
                    ingredients=names,
                    match=FeedMatch(have=have, total=len(names), missing=missing),
                ),
            )
        )

    ranked.sort(key=lambda entry: (entry[0], entry[1], entry[2], entry[3]), reverse=True)

    if position is not None:
        here = (
            Fraction(position.have, position.total),
            position.have,
            position.created_at,
            position.shortcode,
        )
        ranked = [
            entry for entry in ranked if (entry[0], entry[1], entry[2], entry[3]) < here
        ]

    has_more = len(ranked) > limit
    page = ranked[:limit]

    next_cursor = None
    if has_more and page:
        last = page[-1]
        next_cursor = encode_suggestion_cursor(
            SuggestionPosition(
                have=last[4].match.have,
                total=last[4].match.total,
                created_at=last[2],
                shortcode=last[3],
            )
        )

    return SuggestionResponse(
        items=[entry[4] for entry in page],
        cursor=next_cursor,
        has_more=has_more,
    )


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
    """Set ``shared`` true. Vestigial since the feed went global, kept this release."""
    row = _shareable(session, shortcode)
    if not row.shared:
        row.shared = True
        session.flush()
    return row


def unpublish(session: Session, shortcode: str) -> ContentCache:
    """Set ``shared`` false. Vestigial: it no longer hides a card.

    Deleting a reel from the Wall is a takedown (``content.takedown``), which is
    an operator action, not a user one.
    """
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
    """Count a distinct reporter and record the signal on the row.

    A repeat report from the same account changes nothing — the primary key on
    ``content_reports`` does that, so the counter is a count of people rather
    than a count of taps. At the threshold the ``shared`` flag is cleared, which
    since the feed went global is bookkeeping: it marks the row for a human and
    does not remove the card.
    """
    if threshold < 2:
        # A threshold of one would hand any single account a moderation signal
        # on every card it sees.
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
