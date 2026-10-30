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
    kcal: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    protein: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    origin_kind: Mapped[str] = mapped_column(String(16), default="mine", nullable=False)
    origin_creator: Mapped[str | None] = mapped_column(String(200), nullable=True)
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
    source_url: Mapped[str] = mapped_column(String(2048), default="", nullable=False)
    extraction_version: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    created_at: Mapped[datetime] = mapped_column(UTCDateTime, default=utcnow, nullable=False)
    deleted_at: Mapped[datetime | None] = mapped_column(UTCDateTime, nullable=True)


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


class AssistantUsage(Base):
    """Per-user, per-UTC-day counter for the assistant cap."""

    __tablename__ = "assistant_usage"

    user_id: Mapped[str] = mapped_column(
        String(128), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    day: Mapped[date] = mapped_column(Date, primary_key=True)
    count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
