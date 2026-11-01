"""Composition root.

One place decides what the real implementations are. Everything downstream
takes an interface, which is what lets the test suite run the full HTTP surface
and the full worker pipeline with no Postgres, no Redis, no bucket and no model
provider.
"""

from dataclasses import dataclass
from typing import Any

import logging

from sqlalchemy import Engine
from sqlalchemy.orm import Session, sessionmaker

from .auth import AuthVerifier, build_verifier
from .config import Settings
from .db import build_engine, build_session_factory
from .domain.errors import Unavailable
from .assistant import AssistantDeps, AssistantModel, UnconfiguredAssistantModel
from .domain.breaker import CircuitBreaker
from .domain.clock import Clock, SystemClock
from .domain.worker_pool import (
    AlwaysWakeGate,
    GceWorkerPool,
    NoWorkerPool,
    RedisWakeGate,
    WorkerPool,
    WorkerWaker,
)
from .imports.interfaces import (
    Extractor,
    Structurer,
    Transcriber,
    UnconfiguredExtractor,
    UnconfiguredStructurer,
    UnconfiguredTranscriber,
)
from .imports.queue import InMemoryQueue, Queue, RedisQueue
from .imports.service import ImportDeps
from .photos import DevStorage, GcsStorage, PhotoDeps, R2Storage, Storage

log = logging.getLogger("shoku.container")


@dataclass
class AppContext:
    settings: Settings
    engine: Engine
    session_factory: sessionmaker[Session]
    auth: AuthVerifier
    queue: Queue
    extractor: Extractor
    transcriber: Transcriber
    structurer: Structurer
    storage: Storage
    assistant_model: AssistantModel
    clock: Clock
    breaker: CircuitBreaker
    #: Starts the worker VM when a job is queued, and stops it when idle.
    worker_pool: "WorkerPool | NoWorkerPool"
    waker: WorkerWaker
    #: Reads a silent reel from frames. None when vision is off or unconfigured,
    #: which turns "no text" into a clear failure instead of a junk dish.
    vision: "VisionStructurer | None" = None

    # ---- convenience views for services ---------------------------------

    @property
    def import_deps(self) -> ImportDeps:
        return ImportDeps(
            queue=self.queue,
            clock=self.clock,
            waker=self.waker,
            unclaimed_timeout_seconds=float(
                self.settings.worker_unclaimed_timeout_seconds
            ),
        )

    @property
    def assistant_deps(self) -> AssistantDeps:
        return AssistantDeps(
            model=self.assistant_model,
            clock=self.clock,
            daily_cap=self.settings.assistant_daily_cap,
        )

    @property
    def photo_deps(self) -> PhotoDeps:
        return PhotoDeps(
            storage=self.storage,
            expires_in=self.settings.presign_expires_seconds,
            public_base_url=self.settings.storage_public_base_url,
        )


def build_context(
    settings: Settings, *, engine: Engine | None = None, **overrides: Any
) -> AppContext:
    """Build the production graph; ``overrides`` swaps individual interfaces."""
    engine = engine or build_engine(settings)

    storage: Storage
    try:
        if settings.storage_backend == "r2":
            storage = R2Storage(
                account_id=settings.r2_account_id,
                access_key_id=settings.r2_access_key_id,
                secret_access_key=settings.r2_secret_access_key,
                bucket=settings.storage_bucket,
                public_base_url=settings.storage_public_base_url,
            )
        elif settings.storage_backend == "gcs":
            storage = GcsStorage(
                bucket=settings.storage_bucket,
                public_base_url=settings.storage_public_base_url,
                project=settings.gcp_project or None,
            )
        else:
            storage = DevStorage(settings.storage_public_base_url)
    except Unavailable as exc:
        # A bucket that cannot be reached must not take the API or the worker
        # down with it: importing a reel matters, storing its picture does not.
        # Degrade to the dev backend, which cannot store, so nothing pretends
        # an upload worked.
        log.warning(
            "storage backend %r unavailable (%s); running without storage",
            settings.storage_backend,
            exc.detail,
        )
        storage = DevStorage(settings.storage_public_base_url)

    queue: Queue
    if settings.queue_backend == "redis":
        queue = RedisQueue(settings.redis_url, settings.import_queue_name)
    else:
        queue = InMemoryQueue()

    worker_pool: WorkerPool | NoWorkerPool
    if settings.autostart_worker and settings.gcp_project:
        worker_pool = GceWorkerPool(
            project=settings.gcp_project,
            zone=settings.gcp_zone,
            instance=settings.worker_instance,
        )
        # The gate lives in Redis because it is the one store both the API and
        # the worker can see; without it every import would ask for a boot.
        gate = (
            RedisWakeGate(settings.redis_url)
            if settings.queue_backend == "redis"
            else AlwaysWakeGate()
        )
    else:
        worker_pool = NoWorkerPool()
        gate = AlwaysWakeGate()
    waker = WorkerWaker(
        worker_pool, gate, window=settings.worker_wake_debounce_seconds
    )

    ctx = AppContext(
        settings=settings,
        engine=engine,
        session_factory=build_session_factory(engine),
        auth=build_verifier(
            settings.auth_mode,
            supabase_url=settings.supabase_url,
            supabase_audience=settings.supabase_audience,
        ),
        queue=queue,
        extractor=UnconfiguredExtractor(),
        transcriber=UnconfiguredTranscriber(),
        structurer=UnconfiguredStructurer(),
        storage=storage,
        assistant_model=UnconfiguredAssistantModel(),
        clock=SystemClock(),
        worker_pool=worker_pool,
        waker=waker,
        breaker=CircuitBreaker(
            window=settings.breaker_window,
            threshold=settings.breaker_threshold,
            min_samples=settings.breaker_min_samples,
        ),
    )
    from .imports.adapters import (
        FallbackStructurer,
        FasterWhisperTranscriber,
        VisionStructurer,
        HeuristicStructurer,
        OpenAICompatStructurer,
        YtDlpExtractor,
    )

    if settings.extractor == "ytdlp":
        ctx.extractor = YtDlpExtractor(cookies_file=settings.cookies_file or None)
    if settings.transcriber == "whisper":
        ctx.transcriber = FasterWhisperTranscriber(model_size=settings.whisper_model)
    if settings.structurer == "heuristic":
        ctx.structurer = HeuristicStructurer()
    elif settings.structurer in {"muse", "meta", "openai"}:
        model = OpenAICompatStructurer(
            settings.structurer_base_url or "https://api.meta.ai/v1",
            settings.structurer_api_key,
            settings.structurer_model or "muse-spark-1.3",
            settings.structurer_timeout,
            reasoning_effort=settings.structurer_reasoning_effort,
            max_tokens=settings.structurer_max_tokens,
        )
        # The model improves the parse; it must never be able to fail an import.
        ctx.structurer = FallbackStructurer(model, HeuristicStructurer())
        if settings.vision == "auto":
            # Same model and budget; it is only the input that differs.
            ctx.vision = VisionStructurer(
                settings.structurer_base_url or "https://api.meta.ai/v1",
                settings.structurer_api_key,
                settings.structurer_model or "muse-spark-1.3",
                settings.structurer_timeout,
                reasoning_effort=settings.structurer_reasoning_effort,
                max_tokens=settings.structurer_max_tokens,
                max_frames=settings.vision_frames,
            )

    for name, value in overrides.items():
        if not hasattr(ctx, name):
            raise TypeError(f"unknown AppContext field {name!r}")
        setattr(ctx, name, value)
    return ctx
