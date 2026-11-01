"""Time, injected.

Services take a ``Clock`` rather than calling ``datetime.now`` so tests can pin
"today" for the assistant's daily cap and LWW edges. The worker additionally
uses a monotonic ``Deadline``: wall-clock time can move backwards, and a
60-second budget must not.
"""

import time
from datetime import date, datetime, timezone
from typing import Protocol

from .errors import BudgetExceeded


class Clock(Protocol):
    def now(self) -> datetime: ...


class SystemClock:
    def now(self) -> datetime:
        return datetime.now(timezone.utc)

    def today(self) -> date:
        return datetime.now(timezone.utc).date()


class FixedClock:
    def __init__(self, instant: datetime):
        if instant.tzinfo is None:
            instant = instant.replace(tzinfo=timezone.utc)
        self._instant = instant

    def now(self) -> datetime:
        return self._instant

    def today(self) -> date:
        return self._instant.astimezone(timezone.utc).date()

    def advance(self, **kwargs) -> None:
        from datetime import timedelta

        self._instant = self._instant + timedelta(**kwargs)


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class Deadline:
    """A monotonic budget. ``check()`` is called between pipeline stages."""

    __slots__ = ("_expires_at", "total")

    def __init__(self, budget_seconds: float):
        self.total = budget_seconds
        self._expires_at = time.monotonic() + budget_seconds

    @property
    def remaining(self) -> float:
        return max(0.0, self._expires_at - time.monotonic())

    @property
    def expired(self) -> bool:
        return self.remaining <= 0.0

    def check(self, stage: str | None = None) -> None:
        if self.expired:
            suffix = f" during {stage}" if stage else ""
            raise BudgetExceeded(detail=f"import exceeded {self.total:g}s budget{suffix}")
