"""The worker pool: one owner of start and stop, for every tenant on the box.

The import worker used to stop the machine when its own queue went quiet, which
killed whatever else was mid-flight — another tenant's render, in practice.
A process that sees one queue cannot know the machine is idle; only something
that sees *every* tenant can. That is this module.

The protocol is in Redis, so a tenant that already has Redis talks to it
directly and nothing is deployed twice:

``wpool:lease:{pool}:{tenant}:{id}``
    ``{"job", "host", "pid", "ts"}``, TTL 60 s, refreshed every 20 s. One per
    **running job**, never per process: a container that is up but idle holds
    nothing, so the machine can still sleep.

``wpool:demand:{pool}:{tenant}``
    ``{"count", "ts"}``, TTL 900 s. Set when work is queued, by whoever queues
    it, so a job waits for a boot without a tenant holding the machine open.

``wpool:beat:{pool}``
    The broker's own heartbeat, TTL 120 s. A tenant can tell a dead broker from
    a quiet pool.

``wpool:started:{pool}``
    Boot grace, TTL 180 s, written when the broker starts an instance. A job
    takes a minute to register, and stopping inside that window kills it.

The broker is deliberately small: every 15 s it looks, starts if there is
anything to do, and stops only after the idle grace has passed **and** a second
read of the leases agrees.
"""

import json
import logging
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Callable, Protocol

log = logging.getLogger("shoku.pool")

PREFIX = "wpool"

#: Defaults. The idle grace comes from ``idle_shutdown_seconds`` so there is one
#: number to tune, and the rest are the protocol's.
LEASE_TTL = 60
DEMAND_TTL = 900
BEAT_TTL = 120
BOOT_GRACE = 180
LOOP_SECONDS = 15


def lease_key(pool: str, tenant: str, lease_id: str) -> str:
    return f"{PREFIX}:lease:{pool}:{tenant}:{lease_id}"


def lease_pattern(pool: str) -> str:
    return f"{PREFIX}:lease:{pool}:*"


def demand_key(pool: str, tenant: str) -> str:
    return f"{PREFIX}:demand:{pool}:{tenant}"


def demand_pattern(pool: str) -> str:
    return f"{PREFIX}:demand:{pool}:*"


def beat_key(pool: str) -> str:
    return f"{PREFIX}:beat:{pool}"


def started_key(pool: str) -> str:
    return f"{PREFIX}:started:{pool}"


@dataclass(frozen=True)
class Lease:
    pool: str
    tenant: str
    id: str
    job: str
    host: str
    pid: int
    ts: str


class Registry(Protocol):
    """What the broker and the tenants need. Implemented over Redis, faked in tests."""

    def leases(self, pool: str) -> list[Lease]: ...

    def demand(self, pool: str) -> int: ...

    def beat(self, pool: str) -> None: ...

    def started_recently(self, pool: str) -> bool: ...

    def mark_started(self, pool: str) -> None: ...

    def take_lease(self, pool: str, tenant: str, job: str, *, host: str, pid: int) -> str: ...

    def heartbeat(self, pool: str, tenant: str, lease_id: str) -> bool: ...

    def release(self, pool: str, tenant: str, lease_id: str) -> None: ...

    def bump_demand(self, pool: str, tenant: str, count: int = 1) -> int: ...


class RedisRegistry:
    """The real one. Keys live in the Redis the tenants already share."""

    def __init__(self, url: str, *, lease_ttl: int = LEASE_TTL, demand_ttl: int = DEMAND_TTL,
                 beat_ttl: int = BEAT_TTL, boot_grace: int = BOOT_GRACE) -> None:
        import redis  # noqa: PLC0415 - optional dependency

        self._client = redis.Redis.from_url(url, decode_responses=True)
        self.lease_ttl = lease_ttl
        self.demand_ttl = demand_ttl
        self.beat_ttl = beat_ttl
        self.boot_grace = boot_grace

    def _scan(self, pattern: str) -> list[str]:
        return list(self._client.scan_iter(match=pattern, count=200))

    def leases(self, pool: str) -> list[Lease]:
        found: list[Lease] = []
        for key in self._scan(lease_pattern(pool)):
            raw = self._client.get(key)
            if raw is None:  # expired between scan and get
                continue
            try:
                body = json.loads(raw)
            except ValueError:
                continue
            parts = key.split(":")
            found.append(
                Lease(
                    pool=pool,
                    tenant=parts[3] if len(parts) > 4 else "",
                    id=parts[-1],
                    job=str(body.get("job", "")),
                    host=str(body.get("host", "")),
                    pid=int(body.get("pid", 0) or 0),
                    ts=str(body.get("ts", "")),
                )
            )
        return found

    def demand(self, pool: str) -> int:
        total = 0
        for key in self._scan(demand_pattern(pool)):
            raw = self._client.get(key)
            if not raw:
                continue
            try:
                total += int(json.loads(raw).get("count", 0) or 0)
            except (ValueError, AttributeError):
                continue
        return total

    def beat(self, pool: str) -> None:
        self._client.set(beat_key(pool), datetime.now(timezone.utc).isoformat(), ex=self.beat_ttl)

    def started_recently(self, pool: str) -> bool:
        return bool(self._client.exists(started_key(pool)))

    def mark_started(self, pool: str) -> None:
        self._client.set(
            started_key(pool), datetime.now(timezone.utc).isoformat(), ex=self.boot_grace
        )

    def take_lease(self, pool: str, tenant: str, job: str, *, host: str, pid: int) -> str:
        lease_id = f"{pid}-{int(time.time() * 1000)}"
        self._client.set(
            lease_key(pool, tenant, lease_id),
            json.dumps({"job": job, "host": host, "pid": pid,
                        "ts": datetime.now(timezone.utc).isoformat()}),
            ex=self.lease_ttl,
        )
        return lease_id

    def heartbeat(self, pool: str, tenant: str, lease_id: str) -> bool:
        return bool(self._client.expire(lease_key(pool, tenant, lease_id), self.lease_ttl))

    def release(self, pool: str, tenant: str, lease_id: str) -> None:
        self._client.delete(lease_key(pool, tenant, lease_id))

    def bump_demand(self, pool: str, tenant: str, count: int = 1) -> int:
        key = demand_key(pool, tenant)
        try:
            total = int(self._client.incrby(key, count))
        except ValueError:
            self._client.set(key, count, ex=self.demand_ttl)
            total = count
        self._client.expire(key, self.demand_ttl)
        return total


class LeaseKeeper:
    """A lease held for one job, refreshed in the background while it runs.

    A job can take minutes; the lease TTL is sixty seconds. Refreshing from a
    thread keeps this usable from the synchronous worker loop without making the
    worker asynchronous.
    """

    def __init__(self, registry: Registry, pool: str, tenant: str, job: str,
                 *, host: str, pid: int, interval: float = 20.0) -> None:
        self.registry = registry
        self.pool = pool
        self.tenant = tenant
        self.job = job
        self.host = host
        self.pid = pid
        self.interval = interval
        self.lease_id: str | None = None
        self._stop = None
        self._thread = None

    def __enter__(self) -> "LeaseKeeper":
        import threading  # noqa: PLC0415 - only needed while holding

        self.lease_id = self.registry.take_lease(
            self.pool, self.tenant, self.job, host=self.host, pid=self.pid
        )
        self._stop = threading.Event()

        def _beat() -> None:
            while not self._stop.wait(self.interval):
                try:
                    if not self.registry.heartbeat(self.pool, self.tenant, self.lease_id):
                        # The key vanished: take it again rather than run naked.
                        self.registry.take_lease(
                            self.pool, self.tenant, self.job, host=self.host, pid=self.pid
                        )
                except Exception:  # noqa: BLE001 - a missed beat is not a crash
                    log.warning("pool %s: lease heartbeat failed", self.pool)

        self._thread = threading.Thread(target=_beat, daemon=True)
        self._thread.start()
        return self

    def __exit__(self, *exc: Any) -> None:
        if self._stop is not None:
            self._stop.set()
        if self._thread is not None:
            self._thread.join(timeout=2)
        if self.lease_id:
            try:
                self.registry.release(self.pool, self.tenant, self.lease_id)
            except Exception:  # noqa: BLE001 - it will expire anyway
                log.warning("pool %s: lease release failed", self.pool)


class Broker:
    """Looks at every tenant's lease and demand, and owns the machine's power.

    ``run_once`` is the whole decision, kept synchronous and injectable so the
    rules can be tested without Redis, GCE or a clock.
    """

    def __init__(
        self,
        registry: Registry,
        instance_control: Any,
        *,
        pool: str,
        idle_grace: float = 300.0,
        boot_grace: float = BOOT_GRACE,
        clock: Callable[[], float] = time.monotonic,
    ) -> None:
        self.registry = registry
        self.instance_control = instance_control
        self.pool = pool
        self.idle_grace = float(idle_grace)
        self.boot_grace = float(boot_grace)
        self.clock = clock
        self._idle_since: float | None = None

    def run_once(self) -> str:
        """One decision. Returns what it did, which is also what the tests read."""
        self.registry.beat(self.pool)

        if self.registry.leases(self.pool) or self.registry.demand(self.pool):
            self._idle_since = None
            if self.instance_control.status() != "RUNNING":
                self.registry.mark_started(self.pool)
                self.instance_control.start()
                log.info("pool %s: started for pending work", self.pool)
                return "start"
            return "active"

        now = self.clock()
        if self._idle_since is None:
            self._idle_since = now
            return "idle"
        if now - self._idle_since < self.idle_grace:
            return "idle"
        if self.registry.started_recently(self.pool):
            # A boot is minutes long and a job takes a minute to register.
            return "grace"

        # Re-read immediately before touching GCE: the lease we saw expire one
        # second ago may already have been replaced by a job that just started.
        if self.registry.leases(self.pool) or self.registry.demand(self.pool):
            self._idle_since = None
            return "active"

        self.instance_control.stop()
        self._idle_since = None
        log.info("pool %s: idle for %.0fs, stopped", self.pool, self.idle_grace)
        return "stop"

    async def run_forever(self, *, loop_seconds: float = LOOP_SECONDS) -> None:
        import asyncio  # noqa: PLC0415 - only needed by the loop

        while True:
            try:
                self.run_once()
            except Exception:  # noqa: BLE001 - the broker must not die on a blip
                log.exception("pool broker tick failed; carrying on")
            await asyncio.sleep(loop_seconds)
