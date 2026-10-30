"""Import jobs: URL in, job out, state machine in between.

The HTTP surface owns creation and cancellation; the worker owns execution.
Both mutate ``import_jobs`` through the same guarded updates so a cancelled job
cannot be resurrected by a worker that was already holding its id.
"""

import uuid
from dataclasses import dataclass

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from ..domain.clock import Clock
from ..domain.errors import Gone, NotFound
from ..domain.urls import normalise_url
from ..interfaces.queue import Queue
from ..models import ContentCache, ImportJob
from ..schemas.wire import ImportResponse, ImportStatus

TERMINAL_STATES = ("ready", "failed")
CANCELLED_REASON = "cancelled"


@dataclass(frozen=True)
class ImportDeps:
    """The slice of the app context this service needs."""

    queue: Queue
    clock: Clock


def _status(job: ImportJob) -> ImportStatus:
    return ImportStatus(
        job_id=job.id,
        state=job.state,
        shortcode=job.shortcode,
        reason=job.reason,
        progress_stage=job.progress_stage,
        created_at=job.created_at,
        updated_at=job.updated_at,
    )


def start_import(session: Session, deps: ImportDeps, *, uid: str, url: str) -> ImportResponse:
    source = normalise_url(url)

    cached = session.get(ContentCache, source.shortcode)
    if cached is not None and cached.deleted_at is not None:
        # A takedown is final for that shortcode. Re-extracting would undo it.
        raise Gone(detail=f"{source.shortcode} was taken down")
    if cached is not None and cached.structured_json is not None:
        return ImportResponse(
            job_id=None, state="ready", cached=True, shortcode=source.shortcode
        )

    # One extraction per shortcode at a time, whoever asked for it. Duplicate
    # jobs are how a viral reel melts a worker pool.
    active = session.scalars(
        select(ImportJob)
        .where(
            ImportJob.shortcode == source.shortcode,
            ImportJob.state.in_(("queued", "extracting")),
        )
        .order_by(ImportJob.created_at.asc())
        .limit(1)
    ).first()
    if active is not None:
        return ImportResponse(
            job_id=active.id, state=active.state, cached=False, shortcode=source.shortcode
        )

    now = deps.clock.now()
    job = ImportJob(
        id=str(uuid.uuid4()),
        user_id=uid,
        shortcode=source.shortcode,
        source_url=source.canonical_url,
        state="queued",
        progress_stage="queued",
        created_at=now,
        updated_at=now,
    )
    session.add(job)
    session.commit()

    # Commit before enqueueing: a worker that dequeues first would not find the
    # row and would drop the job.
    deps.queue.enqueue(job.id)

    return ImportResponse(job_id=job.id, state="queued", cached=False, shortcode=source.shortcode)


def get_import(session: Session, *, uid: str, job_id: str) -> ImportStatus:
    job = session.get(ImportJob, job_id)
    if job is None or job.user_id != uid:
        raise NotFound(detail="no such import job")
    return _status(job)


def cancel_import(session: Session, deps: ImportDeps, *, uid: str, job_id: str) -> ImportStatus:
    job = session.get(ImportJob, job_id)
    if job is None or job.user_id != uid:
        raise NotFound(detail="no such import job")

    if job.state in TERMINAL_STATES:
        return _status(job)

    now = deps.clock.now()
    result = session.execute(
        update(ImportJob)
        .where(
            ImportJob.id == job_id,
            ImportJob.user_id == uid,
            ImportJob.state.in_(("queued", "extracting")),
        )
        .values(
            state="failed",
            reason=CANCELLED_REASON,
            progress_stage="cancelled",
            updated_at=now,
        )
    )
    session.commit()
    if result.rowcount == 0:
        session.refresh(job)
        return _status(job)
    session.refresh(job)
    return _status(job)


__all__ = [
    "CANCELLED_REASON",
    "ImportDeps",
    "TERMINAL_STATES",
    "cancel_import",
    "get_import",
    "start_import",
]
