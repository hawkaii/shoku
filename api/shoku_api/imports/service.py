"""Import jobs: URL in, job out, state machine in between.

The HTTP surface owns creation and cancellation; the worker owns execution.
Both mutate ``import_jobs`` through the same guarded updates so a cancelled job
cannot be resurrected by a worker that was already holding its id.
"""

import uuid
from dataclasses import dataclass, field
from datetime import timedelta

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from ..domain.clock import Clock
from ..domain.errors import Gone, NotFound, ShokuError
from ..domain.urls import normalise_url
from ..domain.worker_pool import (
    RUNNING,
    STARTING,
    AlwaysWakeGate,
    NoWorkerPool,
    WorkerWaker,
)
from .pipeline import EXTRACTION_VERSION
from .queue import Queue
from ..models import ContentCache, ImportJob
from ..schemas import ImportResponse, ImportStatus

TERMINAL_STATES = ("ready", "failed")
CANCELLED_REASON = "cancelled"
WORKER_UNAVAILABLE = "worker_unavailable"


def _offline_waker() -> WorkerWaker:
    """The default: autostart is off, so waking is a no-op that says RUNNING."""
    return WorkerWaker(NoWorkerPool(), AlwaysWakeGate())


@dataclass(frozen=True)
class ImportDeps:
    """The slice of the app context this service needs."""

    queue: Queue
    clock: Clock
    waker: WorkerWaker = field(default_factory=_offline_waker)
    #: A queued job older than this never met a worker. See ``reap_unclaimed``.
    unclaimed_timeout_seconds: float = 180.0


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
    reap_unclaimed(session, deps)

    cached = session.get(ContentCache, source.shortcode)
    if cached is not None and cached.deleted_at is not None:
        # A takedown is final for that shortcode. Re-extracting would undo it.
        raise Gone(detail=f"{source.shortcode} was taken down")
    if (
        cached is not None
        and cached.structured_json is not None
        and cached.extraction_version >= EXTRACTION_VERSION
    ):
        return ImportResponse(
            job_id=None, state="ready", cached=True, shortcode=source.shortcode
        )
    # Otherwise a stale parse: fall through and extract again. Serving it would
    # keep showing a dish the current pipeline would no longer produce.

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

    # Wake the VM only now, with the row and the queue entry already durable:
    # a boot that beats the insert would find nothing to do.
    try:
        awake = deps.waker.ensure_awake()
    except ShokuError:
        # The instance refused to start. Fail the job rather than letting the
        # client poll a queue that nothing will ever drain.
        _fail(session, job, reason=WORKER_UNAVAILABLE, now=deps.clock.now())
        return ImportResponse(
            job_id=job.id, state="failed", cached=False, shortcode=source.shortcode
        )

    if awake == STARTING:
        # Not claimed yet, and the box is booting. The worker clears this the
        # moment it claims the row (see ImportWorker._claim).
        job.progress_stage = STARTING
        job.updated_at = deps.clock.now()
        session.commit()

    return ImportResponse(job_id=job.id, state="queued", cached=False, shortcode=source.shortcode)


def _fail(session: Session, job: ImportJob, *, reason: str, now) -> None:
    job.state = "failed"
    job.reason = reason
    job.progress_stage = "failed"
    job.updated_at = now
    session.commit()


def reap_unclaimed(session: Session, deps: ImportDeps) -> int:
    """Fail jobs that no worker ever picked up.

    Runs on the paths the client already uses — create and poll — because there
    is no scheduler to run it instead. A queued row older than the timeout is
    not slow, it is stranded: the boot was refused, or the worker died before
    claiming.
    """
    if deps.unclaimed_timeout_seconds <= 0:
        return 0
    cutoff = deps.clock.now() - timedelta(seconds=deps.unclaimed_timeout_seconds)
    result = session.execute(
        update(ImportJob)
        .where(ImportJob.state == "queued", ImportJob.created_at < cutoff)
        .values(
            state="failed",
            reason=WORKER_UNAVAILABLE,
            progress_stage="failed",
            updated_at=deps.clock.now(),
        )
    )
    session.commit()
    return result.rowcount


def get_import(session: Session, deps: ImportDeps, *, uid: str, job_id: str) -> ImportStatus:
    reap_unclaimed(session, deps)
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
    "WORKER_UNAVAILABLE",
    "cancel_import",
    "get_import",
    "reap_unclaimed",
    "start_import",
]
