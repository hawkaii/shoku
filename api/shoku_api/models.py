"""Postgres/SQLite schema.

Field names mirror the drift tables in the Flutter client
(``lib/data/db/app_database.dart``) exactly, in snake_case. Three kinds of
column are server-only and therefore absent from the client schema:

  * ``user_id`` — the owner (a Firebase uid), on every synced table
  * ``server_received_at`` — append-only change tracking, so pull can page on a
    server clock instead of a device clock
  * ``dirty`` is *not* stored here. It means "the server hasn't seen this yet"
    and stops being true the moment a row arrives.
"""

from datetime import date, datetime, timezone
from typing import Any

from sqlalchemy import (
    JSON,
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    String,
    TypeDecorator,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class UTCDateTime(TypeDecorator[datetime]):
    """Timezone-aware on the way out, naive-UTC on the way in.

    Postgres could hold ``timestamptz``, but SQLite cannot, so we normalise in
    the type itself and keep one behaviour everywhere: values are always UTC.
    """

    impl = DateTime
    cache_ok = True

    def process_bind_param(self, value: datetime | None, dialect) -> datetime | None:
        if value is None:
            return None
        if value.tzinfo is None:
            value = value.replace(tzinfo=timezone.utc)
        return value.astimezone(timezone.utc).replace(tzinfo=None)

    def process_result_value(self, value: datetime | None, dialect) -> datetime | None:
        if value is None:
            return None
        if value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value.astimezone(timezone.utc)


class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "users"

    # A Firebase uid, never an email.
    id: Mapped[str] = mapped_column(String(128), primary_key=True)
    created_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, nullable=False)


class Dish(Base):
    """Mutable. Last-write-wins on ``updated_at``; ``deleted_at`` is a tombstone."""

    __tablename__ = "dishes"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    user_id: Mapped[str] = mapped_column(
        String(128), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    subtitle: Mapped[str] = mapped_column(String(400), default="", nullable=False)
    cover_url: Mapped[str] = mapped_column(String(2048), default="", nullable=False)
    source_handle: Mapped[str] = mapped_column(String(200), default="", nullable=False)
    status: Mapped[str] = mapped_column(String(32), default="toCook", nullable=False)
    minutes: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    baseline_kcal: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    baseline_protein: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    steps: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)

    created_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, nullable=False)
    deleted_at: Mapped[datetime | None] = mapped_column(UTCDateTime, nullable=True)
    # Server clock, stamped on every accepted write. Pull pages on this, not on
    # the client's updated_at: a device with a slow clock must still see its own
    # rows, and a device with a fast one must not hide everyone else's.
    server_received_at: Mapped[datetime] = mapped_column(
        UTCDateTime, default=utcnow, nullable=False
    )

    __table_args__ = (
        Index("ix_dishes_user_updated", "user_id", "updated_at"),
        Index("ix_dishes_user_received", "user_id", "server_received_at"),
        Index("ix_dishes_user_deleted", "user_id", "deleted_at"),
    )


class RecipeVersion(Base):
    """Append-only. Never updated, never deleted.

    ``number`` is an ordinal within the user's own lineage; imports carry
    ``number = 0`` and are identified by ``origin_creator``.
    """

    __tablename__ = "recipe_versions"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    user_id: Mapped[str] = mapped_column(
        String(128), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    dish_id: Mapped[str] = mapped_column(
        String(64), ForeignKey("dishes.id", ondelete="CASCADE"), nullable=False
    )
    number: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    changes: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    ingredients: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    steps: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    #: The extraction's own labels, carried onto the version so the app can say
    #: a recipe was *seen* ("from video") rather than *stated*. Empty for a
    #: version the user wrote themselves, and for anything synced before this
    #: field existed — which is why it must stay nullable in the wire sense.
    tags: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    kcal: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    protein: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    origin_kind: Mapped[str] = mapped_column(String(16), default="mine", nullable=False)
    origin_creator: Mapped[str | None] = mapped_column(String(200), nullable=True)
    origin_handle: Mapped[str | None] = mapped_column(String(200), nullable=True)
    origin_platform: Mapped[str | None] = mapped_column(String(32), nullable=True)
    origin_url: Mapped[str | None] = mapped_column(String(2048), nullable=True)
    origin_shortcode: Mapped[str | None] = mapped_column(String(64), nullable=True)
    parent_version_id: Mapped[str | None] = mapped_column(String(64), nullable=True)
    extraction_version: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    created_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, nullable=False)
    server_received_at: Mapped[datetime] = mapped_column(
        UTCDateTime, default=utcnow, nullable=False
    )

    __table_args__ = (
        Index("ix_versions_user_received", "user_id", "server_received_at"),
        Index("ix_versions_dish", "dish_id"),
    )


class CookLog(Base):
    """Append-only: a night of cooking is a thing that happened."""

    __tablename__ = "cook_logs"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    user_id: Mapped[str] = mapped_column(
        String(128), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    dish_id: Mapped[str] = mapped_column(
        String(64), ForeignKey("dishes.id", ondelete="CASCADE"), nullable=False
    )
    version_id: Mapped[str | None] = mapped_column(String(64), nullable=True)
    version_number: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    cooked_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, nullable=False)
    photo_url: Mapped[str] = mapped_column(String(2048), default="", nullable=False)
    photo_state: Mapped[str] = mapped_column(String(16), default="none", nullable=False)
    outcome: Mapped[str] = mapped_column(String(32), default="good", nullable=False)
    mood: Mapped[str] = mapped_column(String(32), default="comfort", nullable=False)
    note: Mapped[str] = mapped_column(String(2000), default="", nullable=False)
    changes: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    rating: Mapped[int] = mapped_column(Integer, default=3, nullable=False)
    server_received_at: Mapped[datetime] = mapped_column(
        UTCDateTime, default=utcnow, nullable=False
    )

    __table_args__ = (
        Index("ix_cooks_user_received", "user_id", "server_received_at"),
        Index("ix_cooks_dish", "dish_id"),
    )


class Photo(Base):
    """Append-only, with one permitted mutation: its tombstone.

    A photo is a fact — it was taken, it was uploaded, it hangs off a version or
    off a night of cooking. The row is never rewritten and its ``key`` never
    changes; the only write that can land on an existing row is ``deleted_at``,
    and only once, from null.

    There is deliberately no ``cover`` role. The dish cover lives on
    ``dishes.cover_url`` and must not gain a second source of truth.

    ``role`` decides which target column is set — exactly one of ``version_id``
    or ``cook_id``, never both and never neither.
    """

    __tablename__ = "photos"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    user_id: Mapped[str] = mapped_column(
        String(128), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    version_id: Mapped[str | None] = mapped_column(
        String(64), ForeignKey("recipe_versions.id", ondelete="CASCADE"), nullable=True
    )
    cook_id: Mapped[str | None] = mapped_column(
        String(64), ForeignKey("cook_logs.id", ondelete="CASCADE"), nullable=True
    )
    role: Mapped[str] = mapped_column(String(16), default="version", nullable=False)
    #: The object key under ``photos/<uid>/``. The API never proxies bytes, so
    #: the key is the only thing it needs to know about the object; the public
    #: URL is derived from the storage base at read time, not stored.
    key: Mapped[str] = mapped_column(String(512), nullable=False)
    created_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, nullable=False)
    deleted_at: Mapped[datetime | None] = mapped_column(UTCDateTime, nullable=True)
    server_received_at: Mapped[datetime] = mapped_column(
        UTCDateTime, default=utcnow, nullable=False
    )

    __table_args__ = (
        Index("ix_photos_user_received", "user_id", "server_received_at"),
        Index("ix_photos_version", "version_id"),
        Index("ix_photos_cook", "cook_id"),
    )


class ContentCache(Base):
    """Global extracted content, keyed by shortcode.

    Shared across users: extraction is expensive and identical for everyone.
    A takedown erases ``structured_json``/``prose_json`` and leaves the stub,
    so the same shortcode can never be quietly re-cached into existence.
    """

    __tablename__ = "content_cache"

    shortcode: Mapped[str] = mapped_column(String(64), primary_key=True)
    structured_json: Mapped[dict[str, Any] | None] = mapped_column(JSON, nullable=True)
    prose_json: Mapped[dict[str, Any] | None] = mapped_column(JSON, nullable=True)
    creator: Mapped[str | None] = mapped_column(String(200), nullable=True)
    #: The handle ("@ralston"), not the display name. What the dish attributes.
    creator_handle: Mapped[str | None] = mapped_column(String(200), nullable=True)
    platform: Mapped[str | None] = mapped_column(String(32), nullable=True)
    #: The reel's own cover image, when the platform exposes one.
    thumbnail_url: Mapped[str | None] = mapped_column(String(2048), nullable=True)
    #: Which model produced this parse. Imports are immutable, so this is a
    #: fact about the row, not a hint about the current default.
    structuring_model: Mapped[str | None] = mapped_column(String(64), nullable=True)
    source_url: Mapped[str] = mapped_column(String(2048), default="", nullable=False)
    extraction_version: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    #: The Wall. False until a user deliberately publishes this extraction, and
    #: set by exactly one code path (``feed.publish``). Never defaulted true,
    #: never backfilled: a helper that publishes on import would put everyone's
    #: journal on the Wall at once.
    shared: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    #: Distinct users who reported this row. Reaches the threshold and the row
    #: is unpublished — one account cannot do it alone, however often it taps.
    reported_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, nullable=False)
    deleted_at: Mapped[datetime | None] = mapped_column(UTCDateTime, nullable=True)


class ContentReport(Base):
    """One report per user per extraction.

    The composite key is the whole moderation model: a counter incremented per
    request would let a single account unshare anything by tapping repeatedly.
    The row is what makes "distinct users" cheap to enforce.
    """

    __tablename__ = "content_reports"

    shortcode: Mapped[str] = mapped_column(
        String(64), ForeignKey("content_cache.shortcode", ondelete="CASCADE"), primary_key=True
    )
    user_id: Mapped[str] = mapped_column(
        String(128), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    created_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, nullable=False)

    __table_args__ = (Index("ix_content_reports_shortcode", "shortcode"),)


class ImportJob(Base):
    """Server-owned job. Its id is minted here (it is not journal data)."""
    __tablename__ = "import_jobs"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(
        String(128), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    shortcode: Mapped[str] = mapped_column(String(64), nullable=False)
    # The canonical source URL. Not in the client-side job shape because jobs
    # never reach the client's database, but the worker needs it: a shortcode
    # alone does not say whether it is an Instagram reel or a YouTube id.
    source_url: Mapped[str] = mapped_column(String(2048), default="", nullable=False)
    state: Mapped[str] = mapped_column(String(16), default="queued", nullable=False)
    reason: Mapped[str | None] = mapped_column(String(200), nullable=True)
    progress_stage: Mapped[str | None] = mapped_column(String(48), nullable=True)
    created_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, nullable=False)

    __table_args__ = (
        Index("ix_import_jobs_user_created", "user_id", "created_at"),
        Index("ix_import_jobs_shortcode_state", "shortcode", "state"),
        Index("ix_import_jobs_state_created", "state", "created_at"),
    )


class AssistantAsk(Base):
    """One metered ask, keyed by the client's ``request_id``.

    The primary key is the whole idempotency story: a POST that is retried after
    a dropped response finds its own row and does not consume the cap twice. The
    row is deleted when the model call fails, so a failed ask costs nothing.
    """

    __tablename__ = "assistant_asks"

    user_id: Mapped[str] = mapped_column(
        String(128), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    request_id: Mapped[str] = mapped_column(String(64), primary_key=True)
    day: Mapped[date] = mapped_column(Date, nullable=False)
    created_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, nullable=False)

    __table_args__ = (Index("ix_assistant_asks_user_day", "user_id", "day"),)


class AssistantUsage(Base):
    """Per-user, per-UTC-day counter for the assistant cap."""

    __tablename__ = "assistant_usage"

    user_id: Mapped[str] = mapped_column(
        String(128), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    day: Mapped[date] = mapped_column(Date, primary_key=True)
    count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
