"""A daily allowance with an idempotent reservation.

Both metered endpoints need the same three things: a counter that cannot be
double-spent by two concurrent requests, a way for a retry to cost nothing, and
a release for a call that failed. The shape is identical for each, so it lives
here and takes the two model classes as arguments.

The counter is incremented and checked in **one** ``UPDATE ... WHERE count < cap``:
a read-then-write would let two requests both see 9 and both write 10. The
per-``request_id`` row is what makes a retried POST free; it is inserted after
the counter moves, and if that insert loses a race the unit is handed back.
"""

from dataclasses import dataclass
from datetime import date, datetime, timedelta, timezone

from sqlalchemy import update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from .errors import UsageCapExceeded


def reset_at(now: datetime) -> datetime:
    """Next midnight UTC: when every daily counter rolls over."""
    tomorrow = now.astimezone(timezone.utc) + timedelta(days=1)
    return datetime(tomorrow.year, tomorrow.month, tomorrow.day, tzinfo=timezone.utc)


@dataclass(frozen=True)
class Quota:
    #: ``(user_id, day) -> count``
    usage_model: type
    #: ``(user_id, request_id) -> day``
    request_model: type
    cap: int
    #: Named in the 429 so the client knows which allowance ran out.
    label: str = "request"


def used(session: Session, quota: Quota, uid: str, day: date) -> int:
    row = session.get(quota.usage_model, (uid, day))
    return row.count if row else 0


def reserve(
    session: Session, quota: Quota, *, uid: str, request_id: str, now: datetime
) -> int:
    """Spend one unit for this request, or recognise a retry as already paid."""
    day = now.date()
    if session.get(quota.request_model, (uid, request_id)) is not None:
        return used(session, quota, uid, day)

    count = _bump(session, quota, uid=uid, day=day, now=now)
    try:
        session.add(
            quota.request_model(
                user_id=uid, request_id=request_id, day=day, created_at=now
            )
        )
        session.commit()
    except IntegrityError:
        # Another copy of this same request won the race; it has paid for both.
        session.rollback()
        _unbump(session, quota, uid=uid, day=day)
        return used(session, quota, uid, day)
    return count


def release(
    session: Session, quota: Quota, *, uid: str, request_id: str, now: datetime
) -> None:
    """A call that produced nothing costs nothing."""
    _unbump(session, quota, uid=uid, day=now.date())
    row = session.get(quota.request_model, (uid, request_id))
    if row is not None:
        session.delete(row)
    session.commit()


def _bump(session: Session, quota: Quota, *, uid: str, day: date, now: datetime) -> int:
    if quota.cap <= 0:
        raise UsageCapExceeded(detail=f"{quota.label} is disabled for this deployment")

    for _attempt in range(2):
        result = session.execute(
            update(quota.usage_model)
            .where(
                quota.usage_model.user_id == uid,
                quota.usage_model.day == day,
                quota.usage_model.count < quota.cap,
            )
            .values(count=quota.usage_model.count + 1)
        )
        if result.rowcount == 1:
            session.commit()
            return used(session, quota, uid, day)

        if session.get(quota.usage_model, (uid, day)) is not None:
            session.commit()
            _raise(quota, now)

        try:
            session.add(quota.usage_model(user_id=uid, day=day, count=1))
            session.commit()
            return 1
        except IntegrityError:
            session.rollback()

    _raise(quota, now)


def _unbump(session: Session, quota: Quota, *, uid: str, day: date) -> None:
    session.execute(
        update(quota.usage_model)
        .where(
            quota.usage_model.user_id == uid,
            quota.usage_model.day == day,
            quota.usage_model.count > 0,
        )
        .values(count=quota.usage_model.count - 1)
    )
    session.commit()


def _raise(quota: Quota, now: datetime) -> None:
    raise UsageCapExceeded(
        detail=f"daily {quota.label} limit of {quota.cap} reached",
        extra={"reset_at": reset_at(now).isoformat()},
    )
