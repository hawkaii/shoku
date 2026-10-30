"""Merge logic for /v1/sync.

Two rules, and they are different on purpose:

* **Append-only tables** (``versions``, ``cook_logs``) merge by union of id.
  An id that already exists is a duplicate, never an update. A cook is a thing
  that happened; a version is a snapshot of somebody's recipe. Neither may be
  rewritten by a later push.
* **Dishes** are last-write-wins on ``updated_at``. The server is the clock
  authority: it stores the value it accepted and echoes it back, and it refuses
  timestamps further than ``clock_skew_allowance`` ahead of server time, so a
  device with a broken clock cannot pin a row for years.
"""

from datetime import datetime, timezone

from sqlalchemy import and_, or_, select
from sqlalchemy.orm import Session

from .domain.clock import Clock
from .domain.cursor import Cursor, TableKey, decode_cursor, encode_cursor
from .models import CookLog, Dish, RecipeVersion
from .schemas import (
    CookLogRowOut,
    DishRowOut,
    PullResponse,
    PushResponse,
    RowResult,
    VersionRowOut,
)

# table name in the response -> (ORM model, change-time column)
SYNCED_TABLES = {
    "dishes": (Dish, Dish.server_received_at),
    "versions": (RecipeVersion, RecipeVersion.server_received_at),
    "cook_logs": (CookLog, CookLog.server_received_at),
}


class SyncService:
    def __init__(
        self,
        session: Session,
        *,
        clock: Clock,
        page_size: int = 500,
        max_page_size: int = 1000,
        clock_skew_seconds: int = 300,
    ) -> None:
        self.session = session
        self.clock = clock
        self.page_size = page_size
        self.max_page_size = max_page_size
        self.clock_skew_seconds = clock_skew_seconds

    # ---- pull ------------------------------------------------------------

    def pull(
        self,
        uid: str,
        *,
        since: datetime | None = None,
        cursor: str | None = None,
        limit: int | None = None,
    ) -> PullResponse:
        page = min(limit or self.page_size, self.max_page_size)
        if since is not None and since.tzinfo is None:
            since = since.replace(tzinfo=timezone.utc)
        position = self._decode(cursor)

        results: dict[str, list] = {}
        next_keys: dict[str, TableKey] = {}

        for name, (model, changed_col) in SYNCED_TABLES.items():
            rows = self._page(
                model, changed_col, uid=uid, since=since, key=position.for_table(name), page=page
            )
            has_more = len(rows) > page
            rows = rows[:page]
            results[name] = rows
            if has_more and rows:
                last = rows[-1]
                next_keys[name] = TableKey(
                    changed_at=getattr(last, changed_col.key), row_id=last.id
                )

        return PullResponse(
            dishes=[DishRowOut.model_validate(r) for r in results["dishes"]],
            versions=[VersionRowOut.model_validate(r) for r in results["versions"]],
            cook_logs=[CookLogRowOut.model_validate(r) for r in results["cook_logs"]],
            cursor=encode_cursor(Cursor(keys=next_keys)) if next_keys else None,
            has_more=bool(next_keys),
            server_time=self.clock.now(),
        )

    def _decode(self, cursor: str | None) -> Cursor:
        try:
            return decode_cursor(cursor)
        except ValueError:
            # A cursor is opaque and disposable. A corrupt one means "start the
            # page over", never "fail the sync".
            return Cursor()

    def _page(
        self,
        model,
        changed_col,
        *,
        uid: str,
        since: datetime | None,
        key: TableKey | None,
        page: int,
    ) -> list:
        stmt = select(model).where(model.user_id == uid)
        if since is not None:
            stmt = stmt.where(changed_col > since)
        if key is not None:
            stmt = stmt.where(
                or_(
                    changed_col > key.changed_at,
                    and_(changed_col == key.changed_at, model.id > key.row_id),
                )
            )
        # Fetch one extra row to learn whether another page exists without a
        # second count query.
        stmt = stmt.order_by(changed_col.asc(), model.id.asc()).limit(page + 1)
        return list(self.session.scalars(stmt).all())

    # ---- push ------------------------------------------------------------

    def push(self, uid: str, *, dishes, versions, cook_logs) -> PushResponse:
        now = self.clock.now()

        dish_results = [self._push_dish(uid, row, now) for row in dishes]

        # Dishes land first so a version pushed in the same batch finds its
        # parent; otherwise an offline client would have to order batches.
        version_results = [self._push_version(uid, row, now) for row in versions]
        cook_results = [self._push_cook(uid, row, now) for row in cook_logs]

        return PushResponse(
            dishes=dish_results, versions=version_results, cook_logs=cook_results
        )

    def _push_dish(self, uid: str, row, now: datetime) -> RowResult:
        if row.updated_at - now > self._skew():
            return RowResult(id=row.id, result="conflict", reason="clock_ahead")
        if row.deleted_at is not None and row.deleted_at - now > self._skew():
            return RowResult(id=row.id, result="conflict", reason="clock_ahead")

        stored = self.session.get(Dish, row.id)
        if stored is not None and stored.user_id != uid:
            return RowResult(id=row.id, result="conflict", reason="id_taken")

        payload = row.model_dump(exclude={"id"})

        if stored is None:
            self.session.add(
                Dish(id=row.id, user_id=uid, server_received_at=now, **payload)
            )
            self.session.flush()
            return RowResult(id=row.id, result="accepted", reason="created")

        if row.updated_at > stored.updated_at:
            for field, value in payload.items():
                setattr(stored, field, value)
            stored.server_received_at = now
            self.session.flush()
            return RowResult(id=row.id, result="accepted", reason="newer")

        if row.updated_at == stored.updated_at:
            # Re-pushing what we already hold must be a no-op, or a flaky
            # network turns every retry into a conflict.
            return RowResult(id=row.id, result="ignored", reason="already_applied")

        return RowResult(id=row.id, result="conflict", reason="stale_write")

    def _push_version(self, uid: str, row, now: datetime) -> RowResult:
        stored = self.session.get(RecipeVersion, row.id)
        if stored is not None:
            if stored.user_id != uid:
                return RowResult(id=row.id, result="conflict", reason="id_taken")
            return RowResult(id=row.id, result="ignored", reason="duplicate_append_only")

        dish = self.session.get(Dish, row.dish_id)
        if dish is None or dish.user_id != uid:
            return RowResult(id=row.id, result="conflict", reason="unknown_dish")

        payload = row.model_dump(exclude={"id"})
        self.session.add(
            RecipeVersion(
                id=row.id,
                user_id=uid,
                server_received_at=now,
                **payload,
            )
        )
        self.session.flush()
        return RowResult(id=row.id, result="accepted", reason="appended")

    def _push_cook(self, uid: str, row, now: datetime) -> RowResult:
        stored = self.session.get(CookLog, row.id)
        if stored is not None:
            if stored.user_id != uid:
                return RowResult(id=row.id, result="conflict", reason="id_taken")
            return RowResult(id=row.id, result="ignored", reason="duplicate_append_only")

        dish = self.session.get(Dish, row.dish_id)
        if dish is None or dish.user_id != uid:
            return RowResult(id=row.id, result="conflict", reason="unknown_dish")

        self.session.add(
            CookLog(
                id=row.id,
                user_id=uid,
                server_received_at=now,
                **row.model_dump(exclude={"id"}),
            )
        )
        self.session.flush()
        return RowResult(id=row.id, result="accepted", reason="appended")

    def _skew(self):
        from datetime import timedelta

        return timedelta(seconds=self.clock_skew_seconds)
