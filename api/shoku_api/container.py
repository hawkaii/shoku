"""Composition root.

One place decides what the real implementations are. Everything downstream
takes an interface, which is what lets the test suite run the full HTTP surface
and the full worker pipeline with no Postgres, no Redis, no bucket and no model
provider.
"""

from dataclasses import dataclass
from typing import Any

from sqlalchemy import Engine
from sqlalchemy.orm import Session, sessionmaker

from .auth import AuthVerifier, build_verifier
from .config import Settings
from .db import build_engine, build_session_factory
from .domain.breaker import CircuitBreaker
from .domain.clock import Clock, SystemClock
from .interfaces.assistant import AssistantModel, UnconfiguredAssistantModel
from .interfaces.media import (
    Extractor,
    Structurer,
    Transcriber,
    UnconfiguredExtractor,
    UnconfiguredStructurer,
    UnconfiguredTranscriber,
)
from .interfaces.queue import InMemoryQueue, Queue, RedisQueue
from .interfaces.storage import DevStorage, R2Storage, Storage
from .services.assistant import AssistantDeps
from .services.imports import ImportDeps
from .services.photos import PhotoDeps


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

    # ---- convenience views for services ---------------------------------

    @property
    def import_deps(self) -> ImportDeps:
        return ImportDeps(queue=self.queue, clock=self.clock)

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


def build_context(settings: Settings, *, engine: Engine | None = None, **overrides: Any) -> AppContext:
    """Build the production graph; ``overrides`` swaps individual interfaces."""
    engine = engine or build_engine(settings)

    storage: Storage
    if settings.storage_backend == "r2":
        storage = R2Storage(
            account_id=settings.r2_account_id,
            access_key_id=settings.r2_access_key_id,
            secret_access_key=settings.r2_secret_access_key,
            bucket=settings.storage_bucket,
            public_base_url=settings.storage_public_base_url,
        )
    else:
        storage = DevStorage(settings.storage_public_base_url)

    queue: Queue
    if settings.queue_backend == "redis":
        queue = RedisQueue(settings.redis_url, settings.import_queue_name)
    else:
        queue = InMemoryQueue()

    ctx = AppContext(
        settings=settings,
        engine=engine,
        session_factory=build_session_factory(engine),
        auth=build_verifier(settings.auth_mode),
        queue=queue,
        extractor=UnconfiguredExtractor(),
        transcriber=UnconfiguredTranscriber(),
        structurer=UnconfiguredStructurer(),
        storage=storage,
        assistant_model=UnconfiguredAssistantModel(),
        clock=SystemClock(),
        breaker=CircuitBreaker(
            window=settings.breaker_window,
            threshold=settings.breaker_threshold,
            min_samples=settings.breaker_min_samples,
        ),
    )
    for name, value in overrides.items():
        if not hasattr(ctx, name):
            raise TypeError(f"unknown AppContext field {name!r}")
        setattr(ctx, name, value)
    return ctx
