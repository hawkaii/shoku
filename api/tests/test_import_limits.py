"""The import allowance: charged for work, never for a cache hit.

The cap exists because an import is the expensive request in the app: it boots a
VM and asks the model to read a video. Everything already paid for — a reel in
the cache, an extraction another user just started, a job that never reached a
worker, a cancel before a claim — has to be free, or the limit punishes people
for the app's own retries.
"""

from __future__ import annotations

from datetime import timedelta

from fastapi.testclient import TestClient
from sqlalchemy import update

from shoku_api.domain.errors import ShokuError
from shoku_api.imports import service as import_service
from shoku_api.models import ImportJob


def reel(code: str) -> str:
    return f"https://www.instagram.com/reel/{code}/"


def post(client: TestClient, code: str, request_id: str | None = None) -> dict:
    body: dict = {"url": reel(code)}
    if request_id is not None:
        body["request_id"] = request_id
    return client.post("/v1/imports", json=body).json()


def test_three_imports_then_the_fourth_is_refused(client) -> None:
    first = post(client, "aaa111")
    assert first["state"] == "queued"
    assert first["remaining"] == 2, "the response says what is left"
    assert first["reset_at"] is not None

    post(client, "bbb222")
    third = post(client, "ccc333")
    assert third["remaining"] == 0

    refusal = client.post("/v1/imports", json={"url": reel("ddd444")})
    assert refusal.status_code == 429
    body = refusal.json()
    assert body["error"] == "daily_cap_reached"
    assert "reset_at" in body, "a 429 has to say when it lifts"


def test_a_cached_reel_costs_nothing(client, worker) -> None:
    first = post(client, "aaa111")
    assert worker.process(first["job_id"]).state == "ready"

    # Spend the rest of the day.
    post(client, "bbb222")
    post(client, "ccc333")

    # The reel is read: no worker, no model, so no unit — even at the cap.
    again = client.post("/v1/imports", json={"url": reel("aaa111")})
    assert again.status_code == 200
    assert again.json()["cached"] is True
    assert again.json()["remaining"] == 0

    assert client.post("/v1/imports", json={"url": reel("ddd444")}).status_code == 429


def test_joining_a_running_extraction_costs_nothing(client) -> None:
    first = post(client, "aaa111")
    again = post(client, "aaa111")
    assert again["job_id"] == first["job_id"], "same job, not a second one"
    assert again["remaining"] == 2, "the second tap spent nothing"

    post(client, "bbb222")
    post(client, "ccc333")
    assert client.post("/v1/imports", json={"url": reel("ddd444")}).status_code == 429


def test_a_worker_that_will_not_start_refunds(client, ctx) -> None:
    class Refusing:
        def ensure_awake(self):
            raise ShokuError(detail="no capacity")

    ctx.waker = Refusing()

    refunded = post(client, "aaa111")
    assert refunded["state"] == "failed"
    assert refunded["remaining"] == 3, "nothing ran, so nothing was spent"

    # The allowance is intact: three more can still be attempted.
    ctx.waker = import_service._offline_waker()
    assert post(client, "bbb222")["remaining"] == 2
    assert post(client, "ccc333")["remaining"] == 1


def test_a_job_nobody_claimed_refunds(client, ctx) -> None:
    first = post(client, "aaa111")
    assert first["remaining"] == 2

    # Pretend it has been sitting in the queue past the unclaimed timeout.
    with ctx.session_factory() as session:
        session.execute(
            update(ImportJob)
            .where(ImportJob.id == first["job_id"])
            .values(created_at=ctx.clock.now() - timedelta(hours=1))
        )
        session.commit()
        reaped = import_service.reap_unclaimed(session, ctx.import_deps)
    assert reaped == 1

    assert post(client, "bbb222")["remaining"] == 2, "the unit came back"
    post(client, "ccc333")
    post(client, "ddd444")
    assert client.post("/v1/imports", json={"url": reel("eee555")}).status_code == 429


def test_cancelling_before_a_claim_refunds(client) -> None:
    first = post(client, "aaa111")
    cancelled = client.post(f"/v1/imports/{first['job_id']}/cancel")
    assert cancelled.status_code == 200
    assert cancelled.json()["state"] == "failed"

    assert post(client, "bbb222")["remaining"] == 2, "a cancelled job never ran"
    post(client, "ccc333")
    post(client, "ddd444")
    assert client.post("/v1/imports", json={"url": reel("eee555")}).status_code == 429


def test_a_reel_nobody_could_read_still_counts(client) -> None:
    """The VM booted and the model was paid; the cap is about cost, not success."""
    first = post(client, "aaa111")
    # Fail it the way the pipeline does when the source has no text to read.
    with client.app.state.ctx.session_factory() as session:
        job = session.get(ImportJob, first["job_id"])
        job.state = "failed"
        job.reason = "no_text"
        job.progress_stage = "failed"
        session.commit()

    assert post(client, "bbb222")["remaining"] == 1, "a paid attempt stays paid"
