"""Import jobs: URL in, job out, state machine in between.

The HTTP surface owns creation and cancellation; the worker owns execution.
Both mutate ``import_jobs`` through the same guarded updates so a cancelled job
cannot be resurrected by a worker that was already holding its id.
"""

import uuid
from dataclasses import dataclass, field
from datetime import timedelta

import logging

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from ..domain.clock import Clock
from ..domain.errors import Gone, NotFound, ShokuError
from ..domain.quota import Quota, release as release_quota, reserve as reserve_quota
from ..domain.quota import reset_at as reset_at_for
from ..domain.quota import used as quota_used
from ..domain.worker_pool import (
    STARTING,
    AlwaysWakeGate,
    NoWorkerPool,
    WorkerWaker,
)
from ..domain.urls import normalise_url
from .pipeline import EXTRACTION_VERSION
from .queue import Queue
from ..models import ContentCache, ImportAsk, ImportJob, ImportUsage
from ..schemas import ImportResponse, ImportStatus

log = logging.getLogger("shoku.imports.service")

TERMINAL_STATES = ("ready", "failed")
CANCELLED_REASON = "cancelled"
QUEUE_UNAVAILABLE = "queue_unavailable"
WORKER_UNAVAILABLE = "worker_unavailable"


def _offline_waker() -> WorkerWaker:
    """The default: autostart is off, so waking is a no-op that says RUNNING."""
    return WorkerWaker(NoWorkerPool(), AlwaysWakeGate())


@dataclass(frozen=True)
class ImportDeps:
    """The slice of the app context this service needs."""

    queue: Queue
    clock: Clock
    #: The direct waker. Unused when a broker owns the machine, but the import
    #: service keeps it so a deployment without a broker behaves as it did.
    waker: WorkerWaker = field(default_factory=_offline_waker)
    #: The shared lease registry, when this deployment has one. Enqueueing
    #: publishes demand; it never touches GCE.
    registry: object | None = None
    pool: str = "render"
    tenant: str = "shoku"
    #: A queued job older than this never met a worker. See ``reap_unclaimed``.
    unclaimed_timeout_seconds: float = 180.0
    #: Imports a user may queue per UTC day. 0 disables importing entirely.
    daily_cap: int = 0


def _quota(deps: ImportDeps) -> Quota:
    return Quota(ImportUsage, ImportAsk, cap=deps.daily_cap, label="import")


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


def start_import(
    session: Session,
    deps: ImportDeps,
    *,
    uid: str,
    url: str,
    request_id: str | None = None,
) -> ImportResponse:
    source = normalise_url(url)
    reap_unclaimed(session, deps)

    now = deps.clock.now()
    quota = _quota(deps)
    # A retry carries the same id; a fresh attempt carries a new one or none.
    ticket = request_id or str(uuid.uuid4())

    def allowance() -> int:
        return max(0, deps.daily_cap - quota_used(session, quota, uid, now.date()))

    cached = session.get(ContentCache, source.shortcode)
    if cached is not None and cached.deleted_at is not None:
        # A takedown is final for that shortcode. Re-extracting would undo it.
        raise Gone(detail=f"{source.shortcode} was taken down")
    if (
        cached is not None
        and cached.structured_json is not None
        and cached.extraction_version >= EXTRACTION_VERSION
    ):
        # Already read: no worker, no model, and no unit spent.
        return ImportResponse(
            job_id=None,
            state="ready",
            cached=True,
            shortcode=source.shortcode,
            remaining=allowance(),
            reset_at=reset_at_for(now),
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
        # Somebody's extraction is already running; joining it costs nothing.
        return ImportResponse(
            job_id=active.id,
            state=active.state,
            cached=False,
            shortcode=source.shortcode,
            remaining=allowance(),
            reset_at=reset_at_for(now),
        )

    # Only now, with no cache and no live job, does this request cost anything.
    reserve_quota(session, quota, uid=uid, request_id=ticket, now=now)

    job = ImportJob(
        id=str(uuid.uuid4()),
        user_id=uid,
        shortcode=source.shortcode,
        source_url=source.canonical_url,
        state="queued",
        progress_stage="queued",
        created_at=now,
        updated_at=now,
        quota_request_id=ticket,
    )
    session.add(job)
    session.commit()

    # Commit before enqueueing: a worker that dequeues first would not find the
    # row and would drop the job.
    try:
        deps.queue.enqueue(job.id)
    except Exception:
        # A queue that refused the job never did any work; hand the unit back.
        release_quota(session, quota, uid=uid, request_id=ticket, now=now)
        _fail(session, job, reason=QUEUE_UNAVAILABLE, now=deps.clock.now())
        return ImportResponse(
            job_id=job.id,
            state="failed",
            cached=False,
            shortcode=source.shortcode,
            remaining=allowance(),
            reset_at=reset_at_for(now),
        )

    # Two ways to get a worker, and the deployment says which one it is. With a
    # broker, queueing work publishes demand and the broker decides whether that
    # means a boot — the API never talks to GCE. Without one, the API wakes the
    # VM itself, only now, with the row and the queue entry already durable: a
    # boot that beats the insert would find nothing to do.
    if deps.registry is not None:
        try:
            deps.registry.bump_demand(deps.pool, deps.tenant)
        except Exception:  # noqa: BLE001 - a job must not fail over a lease write
            log.warning("could not publish pool demand for %s", job.id)
    else:
        try:
            awake = deps.waker.ensure_awake()
        except ShokuError:
            # The instance refused to start. Fail the job rather than letting
            # the client poll a queue that nothing will ever drain — and refund
            # the unit it reserved.
            release_quota(session, quota, uid=uid, request_id=ticket, now=now)
            _fail(session, job, reason=WORKER_UNAVAILABLE, now=deps.clock.now())
            return ImportResponse(
                job_id=job.id,
                state="failed",
                cached=False,
                shortcode=source.shortcode,
                remaining=allowance(),
                reset_at=reset_at_for(now),
            )

        if awake == STARTING:
            # Not claimed yet, and the box is booting. The worker clears this
            # the moment it claims the row (see ImportWorker._claim).
            job.progress_stage = STARTING
            job.updated_at = deps.clock.now()
            session.commit()

    return ImportResponse(
        job_id=job.id,
        state="queued",
        cached=False,
        shortcode=source.shortcode,
        remaining=allowance(),
        reset_at=reset_at_for(now),
    )


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
    now = deps.clock.now()
    cutoff = now - timedelta(seconds=deps.unclaimed_timeout_seconds)
    stranded = session.scalars(
        select(ImportJob).where(
            ImportJob.state == "queued", ImportJob.created_at < cutoff
        )
    ).all()
    if not stranded:
        return 0
    result = session.execute(
        update(ImportJob)
        .where(
            ImportJob.id.in_([job.id for job in stranded]),
            ImportJob.state == "queued",
        )
        .values(
            state="failed",
            reason=WORKER_UNAVAILABLE,
            progress_stage="failed",
            updated_at=now,
        )
    )
    session.commit()
    # Nothing read the reel, so nothing should have been charged for it.
    quota = _quota(deps)
    for job in stranded:
        if job.quota_request_id:
            release_quota(
                session, quota, uid=job.user_id, request_id=job.quota_request_id, now=now
            )
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
    # A job cancelled before any worker claimed it never spent the VM, so it
    # hands the daily unit back. One already extracting has already cost.
    was_queued = job.state == "queued"
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
    if was_queued and job.quota_request_id:
        release_quota(
            session,
            _quota(deps),
            uid=uid,
            request_id=job.quota_request_id,
            now=now,
        )
    session.refresh(job)
    return _status(job)


__all__ = [
    "CANCELLED_REASON",
    "QUEUE_UNAVAILABLE",
    "ImportDeps",
    "TERMINAL_STATES",
    "WORKER_UNAVAILABLE",
    "cancel_import",
    "get_import",
    "reap_unclaimed",
    "start_import",
]
