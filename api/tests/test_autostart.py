"""Demand-driven worker: wake on enqueue, sleep when idle, fail when stuck.

The failure this prevents is a job that sits at ``queued`` forever because the
VM is asleep and nothing in the system can start it.
"""

from datetime import timedelta

import pytest
from fastapi.testclient import TestClient

from shoku_api.domain.errors import Unavailable
from shoku_api.domain.worker_pool import STARTING, WorkerWaker
from shoku_api.imports import worker as worker_module
from shoku_api.imports.service import WORKER_UNAVAILABLE
from shoku_api.models import ImportJob


class FakePool:
    """A VM that stays TERMINATED after a start, like a real one mid-boot."""

    can_stop = True

    def __init__(self, status: str = "TERMINATED", *, fail_start: bool = False) -> None:
        self._status = status
        self.fail_start = fail_start
        self.starts = 0
        self.stops = 0

    def status(self) -> str:
        return self._status

    def start(self) -> None:
        self.starts += 1
        if self.fail_start:
            raise Unavailable(detail="compute.instances.start denied")

    def stop(self) -> None:
        self.stops += 1


class FakeGate:
    """Allows ``allow`` claims, then stays shut — a debounce window."""

    def __init__(self, allow: int = 1) -> None:
        self.allow = allow
        self.claims = 0

    def claim(self, window: int) -> bool:
        self.claims += 1
        if self.allow > 0:
            self.allow -= 1
            return True
        return False


def arm(ctx, pool: FakePool, gate: FakeGate | None = None) -> WorkerWaker:
    waker = WorkerWaker(pool, gate or FakeGate(), window=120)
    ctx.waker = waker
    return waker


def post_import(client: TestClient, shortcode: str) -> dict:
    response = client.post(
        "/v1/imports", json={"url": f"https://www.instagram.com/reel/{shortcode}/"}
    )
    assert response.status_code == 202, response.text
    return response.json()


# ---- wake on enqueue ------------------------------------------------------


def test_a_stopped_worker_is_started_once_for_several_jobs(client, ctx) -> None:
    pool = FakePool("TERMINATED")
    arm(ctx, pool)

    jobs = [post_import(client, "DctNWIDT540"), post_import(client, "DtENabc1234"), post_import(client, "DtENabc5678")]

    assert pool.starts == 1, "ten imports must pay for one boot"
    assert len({job["job_id"] for job in jobs}) == 3
    for job in jobs:
        status = client.get(f"/v1/imports/{job['job_id']}").json()
        assert status["progress_stage"] == "starting"
        assert status["state"] == "queued"


def test_a_running_worker_is_never_started(client, ctx) -> None:
    pool = FakePool("RUNNING")
    arm(ctx, pool, FakeGate(allow=99))

    job = post_import(client, "DtENdef1234")

    assert pool.starts == 0
    assert client.get(f"/v1/imports/{job['job_id']}").json()["progress_stage"] == "queued"


def test_a_debounced_wake_still_reports_starting(client, ctx) -> None:
    pool = FakePool("TERMINATED")
    arm(ctx, pool, FakeGate(allow=0))

    job = post_import(client, "DtENghi1234")

    assert pool.starts == 0
    assert client.get(f"/v1/imports/{job['job_id']}").json()["progress_stage"] == STARTING


def test_a_refused_start_fails_the_job_instead_of_queueing_forever(client, ctx) -> None:
    pool = FakePool("TERMINATED", fail_start=True)
    arm(ctx, pool)

    response = client.post(
        "/v1/imports", json={"url": "https://www.instagram.com/reel/DtENjkl1234/"}
    )

    assert response.status_code == 202
    body = response.json()
    assert body["state"] == "failed"

    status = client.get(f"/v1/imports/{body['job_id']}").json()
    assert status["state"] == "failed"
    assert status["reason"] == WORKER_UNAVAILABLE


def test_a_cache_hit_never_wakes_anything(client, ctx, session) -> None:
    from shoku_api.content import store_extraction
    from shoku_api.schemas import ProsePayload, RecipePayload

    store_extraction(
        session,
        shortcode="DtENmno1234",
        recipe=RecipePayload(
            title="Cached",
            servings=2,
            minutes=5,
            kcal=0,
            protein=0,
            ingredients=[{"name": "paneer"}],
            steps=["Mix"],
            tags=[],
        ),
        prose=ProsePayload(summary=""),
        creator=None,
        source_url="https://www.instagram.com/reel/DtENmno1234/",
        extraction_version=4,
        clock=ctx.clock,
    )

    pool = FakePool("TERMINATED")
    arm(ctx, pool)

    response = client.post(
        "/v1/imports", json={"url": "https://www.instagram.com/reel/DtENmno1234/"}
    )

    assert response.status_code == 200
    assert response.json()["cached"] is True
    assert pool.starts == 0, "a cache hit does no work, so it boots nothing"


# ---- stuck jobs -----------------------------------------------------------


def test_a_job_nobody_claimed_is_failed_on_the_next_poll(client, ctx, session) -> None:
    old = ctx.clock.now() - timedelta(seconds=600)
    session.add(
        ImportJob(
            id="stuck-1",
            user_id="user-1",
            shortcode="DtENpqr1234",
            source_url="https://www.instagram.com/reel/DtENpqr1234/",
            state="queued",
            progress_stage="starting",
            created_at=old,
            updated_at=old,
        )
    )
    session.commit()

    status = client.get("/v1/imports/stuck-1").json()

    assert status["state"] == "failed"
    assert status["reason"] == WORKER_UNAVAILABLE


def test_a_fresh_queued_job_is_left_alone(client, ctx, session) -> None:
    session.add(
        ImportJob(
            id="fresh-1",
            user_id="user-1",
            shortcode="DtENstu1234",
            source_url="https://www.instagram.com/reel/DtENstu1234/",
            state="queued",
            progress_stage="starting",
            created_at=ctx.clock.now(),
            updated_at=ctx.clock.now(),
        )
    )
    session.commit()

    status = client.get("/v1/imports/fresh-1").json()

    assert status["state"] == "queued"


# ---- self-stop ------------------------------------------------------------


class FakeQueue:
    def __init__(self, depth: int) -> None:
        self._depth = depth

    def depth(self) -> int:
        return self._depth


def ctx_with(pool, depth: int):
    import types

    return types.SimpleNamespace(queue=FakeQueue(depth), worker_pool=pool)


def test_the_idle_check_refuses_to_stop_with_a_queued_job() -> None:
    ctx = ctx_with(FakePool("RUNNING"), depth=1)
    assert worker_module._should_stop(ctx, idle_for=999, limit=300) is False


def test_the_idle_check_stops_only_when_the_queue_is_empty() -> None:
    ctx = ctx_with(FakePool("RUNNING"), depth=0)
    assert worker_module._should_stop(ctx, idle_for=999, limit=300) is True


def test_the_idle_check_waits_for_the_window() -> None:
    ctx = ctx_with(FakePool("RUNNING"), depth=0)
    assert worker_module._should_stop(ctx, idle_for=10, limit=300) is False


def test_the_idle_check_never_stops_a_pool_that_cannot() -> None:
    """A pool without ``can_stop`` is a dev worker on a laptop, not a VM."""
    from shoku_api.domain.worker_pool import NoWorkerPool

    ctx = ctx_with(NoWorkerPool(), depth=0)
    assert worker_module._should_stop(ctx, idle_for=999, limit=300) is False


@pytest.mark.parametrize("limit", [0, -1])
def test_the_idle_check_is_off_when_the_window_is_disabled(limit) -> None:
    ctx = ctx_with(FakePool("RUNNING"), depth=0)
    assert worker_module._should_stop(ctx, idle_for=10_000, limit=limit) is False
