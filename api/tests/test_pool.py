"""The pool broker: the only thing allowed to start or stop the machine.

The rules are exercised against a fake registry and a fake instance, because
what matters is the decision — a held lease blocks a stop, an expired one does
not, demand keeps the box warm, and the stop is re-checked immediately before it
is made.
"""

from dataclasses import dataclass, field

from shoku_api.pool import (
    BEAT_TTL,
    BOOT_GRACE,
    DEMAND_TTL,
    LEASE_TTL,
    Broker,
    Lease,
    beat_key,
    demand_key,
    lease_key,
    started_key,
)


class FakeRegistry:
    def __init__(self) -> None:
        self._leases: list[Lease] = []
        self._demand = 0
        self.started = False
        self.beats = 0
        self.marks = 0
        #: Set to make the *next* read of leases answer differently, which is
        #: how the pre-stop re-read is tested.
        self.next_lease: list[Lease] | None = None

    def leases(self, pool):
        if self.next_lease is not None:
            leases, self.next_lease = self.next_lease, None
            return leases
        return list(self._leases)

    def demand(self, pool):
        return self._demand

    def beat(self, pool):
        self.beats += 1

    def started_recently(self, pool):
        return self.started

    def mark_started(self, pool):
        self.marks += 1

    def hold(self, tenant="reelgen", job="render-1"):
        self._leases.append(
            Lease(pool="render", tenant=tenant, id="1", job=job, host="h", pid=1, ts="")
        )

    def ask(self, count=1):
        self._demand = count

    def take_lease(self, pool, tenant, job, *, host, pid):
        self.hold(tenant=tenant, job=job)
        return "lease-1"

    def heartbeat(self, pool, tenant, lease_id):
        return True

    def release(self, pool, tenant, lease_id):
        self._leases = []

    def bump_demand(self, pool, tenant, count=1):
        self._demand += count
        return self._demand


class FakeInstance:
    def __init__(self, status="RUNNING") -> None:
        self._status = status
        self.starts = 0
        self.stops = 0

    def status(self):
        return self._status

    def start(self):
        self.starts += 1
        self._status = "RUNNING"

    def stop(self):
        self.stops += 1
        self._status = "TERMINATED"


@dataclass
class Clock:
    now: float = 0.0
    step: float = 15.0

    def __call__(self) -> float:
        value = self.now
        self.now += self.step
        return value


def broker(registry=None, instance=None, clock=None, idle_grace=300):
    registry = registry or FakeRegistry()
    instance = instance or FakeInstance()
    clock = clock or Clock()
    return Broker(
        registry, instance, pool="render", idle_grace=idle_grace, boot_grace=BOOT_GRACE, clock=clock
    ), registry, instance, clock


# ---- the keys are the protocol -------------------------------------------


def test_the_keys_are_the_ones_the_tenants_write() -> None:
    assert lease_key("render", "reelgen", "abc") == "wpool:lease:render:reelgen:abc"
    assert demand_key("render", "reelgen") == "wpool:demand:render:reelgen"
    assert beat_key("render") == "wpool:beat:render"
    assert started_key("render") == "wpool:started:render"
    assert (LEASE_TTL, DEMAND_TTL, BEAT_TTL, BOOT_GRACE) == (60, 900, 120, 180)


# ---- starting -------------------------------------------------------------


def test_a_lease_on_a_stopped_machine_starts_it() -> None:
    b, _registry, instance, _clock = broker(instance=FakeInstance("TERMINATED"))
    _registry.hold()

    assert b.run_once() == "start"
    assert instance.starts == 1


def test_demand_alone_starts_it() -> None:
    b, registry, instance, _clock = broker(instance=FakeInstance("TERMINATED"))
    registry.ask(2)

    assert b.run_once() == "start"
    assert instance.starts == 1


def test_a_running_machine_is_not_started_twice() -> None:
    b, registry, instance, _clock = broker()
    registry.hold()

    assert b.run_once() == "active"
    assert instance.starts == 0


# ---- stopping -------------------------------------------------------------


def test_a_held_lease_blocks_a_stop_past_the_grace() -> None:
    b, registry, instance, clock = broker()
    registry.hold()

    for _ in range(20):
        assert b.run_once() in {"active", "idle"}
        assert instance.stops == 0


def test_an_expired_lease_lets_the_machine_stop() -> None:
    b, registry, instance, clock = broker()
    registry.hold()
    assert b.run_once() == "active"

    registry._leases = []  # the lease TTL expired
    actions = [b.run_once() for _ in range(3)]

    assert actions[-1] == "idle" or actions[-1] == "stop"
    for _ in range(30):
        b.run_once()
    assert instance.stops == 1, "the machine is stopped, once"


def test_demand_keeps_it_warm() -> None:
    b, registry, instance, _clock = broker()
    registry.ask(1)

    for _ in range(30):
        assert b.run_once() in {"active", "start"}
    assert instance.stops == 0


def test_the_stop_is_re_read_immediately_before_it_happens() -> None:
    """A lease that appears during the idle window must cancel the stop."""
    b, registry, instance, _clock = broker()
    assert b.run_once() == "idle"          # starts the idle clock
    # ... the next read shows a job that just started.
    registry.next_lease = [
        Lease(pool="render", tenant="reelgen", id="9", job="late", host="h", pid=1, ts="")
    ]

    action = b.run_once()

    assert action == "active", "the pre-stop re-read saved the job"
    assert instance.stops == 0


def test_boot_grace_blocks_a_stop_right_after_a_start() -> None:
    b, registry, instance, clock = broker()
    registry.started = True   # the broker started the machine a moment ago
    assert b.run_once() == "idle"      # the idle clock starts

    clock.now = 400                    # long past the idle grace, still in boot
    assert b.run_once() == "grace"
    assert instance.stops == 0


def test_a_fresh_broker_does_not_stop_on_its_first_idle_tick() -> None:
    """A restart mid-render must not read 'nothing yet' as 'nothing at all'."""
    b, _registry, instance, _clock = broker()

    assert b.run_once() == "idle"
    assert instance.stops == 0


def test_the_broker_beats_every_tick() -> None:
    b, registry, _instance, _clock = broker()

    b.run_once()
    b.run_once()

    assert registry.beats == 2, "tenants must be able to see a live broker"


def test_a_tenant_lease_survives_a_broker_that_never_started_anything() -> None:
    """Reel-gen holding a lease is enough; it never needs to know about GCE."""
    b, registry, instance, _clock = broker(instance=FakeInstance("TERMINATED"))
    registry.hold(tenant="reelgen", job="render-42")

    assert b.run_once() == "start"
    assert instance.starts == 1
