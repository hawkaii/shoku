"""The import API no longer starts or stops the worker VM.

Both decisions moved to the pool broker, which can see every tenant on the box.
What is left here is the one thing the API still owns: a queued row nobody ever
claimed is dead, not slow.
"""

from datetime import timedelta

from fastapi.testclient import TestClient

from shoku_api.imports.service import WORKER_UNAVAILABLE
from shoku_api.models import ImportJob


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
