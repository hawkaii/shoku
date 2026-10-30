"""The import queue.

An interface because the fake gives tests a synchronous, inspectable queue:
"did a cache hit enqueue anything?" is a question you answer by looking at a
list, not by mocking a client.
"""

from typing import Protocol

from ..domain.errors import Unavailable


class Queue(Protocol):
    def enqueue(self, job_id: str) -> None: ...

    def dequeue(self, timeout: float = 5.0) -> str | None: ...

    def depth(self) -> int: ...


class InMemoryQueue:
    """Process-local FIFO. Enough for a dev box and for tests."""

    def __init__(self) -> None:
        self._items: list[str] = []
        self.enqueued: list[str] = []

    def enqueue(self, job_id: str) -> None:
        self._items.append(job_id)
        self.enqueued.append(job_id)

    def dequeue(self, timeout: float = 5.0) -> str | None:
        if not self._items:
            return None
        return self._items.pop(0)

    def depth(self) -> int:
        return len(self._items)


class RedisQueue:
    """``LIST``-backed queue: LPUSH in, BRPOP out.

    Imported lazily so the base install (and the test suite) needs no Redis.
    """

    def __init__(self, url: str, name: str) -> None:
        try:
            import redis  # noqa: PLC0415 - optional dependency
        except ImportError as exc:  # pragma: no cover - exercised only in prod
            raise Unavailable(
                detail="redis is not installed; install shoku-api[prod]"
            ) from exc
        self._client = redis.Redis.from_url(url, decode_responses=True)
        self._name = name

    def enqueue(self, job_id: str) -> None:
        self._client.lpush(self._name, job_id)

    def dequeue(self, timeout: float = 5.0) -> str | None:
        # A blocking pop that finds nothing is a normal empty poll, but some
        # redis-py versions raise TimeoutError instead of returning None. That
        # must not kill the worker loop.
        try:
            result = self._client.brpop(self._name, timeout=int(max(1, timeout)))
        except TimeoutError:
            return None
        return None if result is None else str(result[1])

    def depth(self) -> int:
        return int(self._client.llen(self._name))
