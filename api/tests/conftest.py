"""Test harness: the real HTTP surface, the real services, an in-memory database
and fakes only where an external service would be.

Nothing here needs Postgres, Redis, a bucket, ffmpeg or a model provider.
"""

from __future__ import annotations

from typing import Any

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from sqlalchemy.pool import StaticPool

from shoku_api.assistant import FakeAssistantModel
from shoku_api.config import Settings
from shoku_api.container import build_context
from shoku_api.imports.fakes import (
    FakeExtractor,
    FakeStructurer,
    FakeTranscriber,
    recipe,
)
from shoku_api.main import create_app
from shoku_api.models import Base
from shoku_api.photos import FakeStorage


@pytest.fixture
def settings() -> Settings:
    return Settings(
        environment="test",
        database_url="sqlite://",
        queue_backend="memory",
        storage_backend="dev",
        auth_mode="dev",
        assistant_daily_cap=3,
        pantry_parse_daily_cap=3,
        breaker_window=20,
        breaker_min_samples=3,
        clock_skew_allowance_seconds=300,
    )


@pytest.fixture
def engine(settings: Settings):
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        future=True,
    )
    Base.metadata.create_all(engine)
    yield engine
    Base.metadata.drop_all(engine)
    engine.dispose()


@pytest.fixture
def ctx(settings: Settings, engine):
    return build_context(
        settings,
        engine=engine,
        extractor=FakeExtractor(),
        transcriber=FakeTranscriber(),
        structurer=FakeStructurer(),
        assistant_model=FakeAssistantModel(),
        storage=FakeStorage(),
    )


@pytest.fixture
def session(ctx) -> Session:
    with ctx.session_factory() as s:
        yield s


@pytest.fixture
def app(ctx):
    return create_app(ctx.settings, ctx=ctx, create_tables=False)


@pytest.fixture
def client(app) -> TestClient:
    with TestClient(app) as c:
        c.headers.update({"X-Firebase-Uid": "user-1"})
        yield c


@pytest.fixture
def anonymous(app) -> TestClient:
    with TestClient(app) as c:
        yield c


@pytest.fixture
def worker(ctx):
    from shoku_api.imports.pipeline import ImportWorker

    return ImportWorker(ctx)


@pytest.fixture
def extractor(ctx) -> FakeExtractor:
    return ctx.extractor


@pytest.fixture
def transcriber(ctx) -> FakeTranscriber:
    return ctx.transcriber


@pytest.fixture
def structurer(ctx) -> FakeStructurer:
    return ctx.structurer


@pytest.fixture
def assistant(ctx) -> FakeAssistantModel:
    return ctx.assistant_model


@pytest.fixture
def storage(ctx) -> FakeStorage:
    return ctx.storage


@pytest.fixture
def recipe_payload() -> dict[str, Any]:
    return recipe()


def _dish_payload(**overrides: Any) -> dict[str, Any]:
    payload = {
        "id": "dish-1",
        "title": "Paneer",
        "subtitle": "Weeknight",
        "cover_url": "",
        "source_handle": "@ravi",
        "status": "toCook",
        "minutes": 30,
        "baseline_kcal": 400,
        "baseline_protein": 18,
        "steps": ["Fry", "Simmer"],
        "created_at": "2026-01-01T10:00:00Z",
        "updated_at": "2026-01-01T10:00:00Z",
    }
    payload.update(overrides)
    return payload


def _version_payload(**overrides: Any) -> dict[str, Any]:
    payload = {
        "id": "v1",
        "dish_id": "dish-1",
        "number": 1,
        "changes": ["First attempt"],
        "ingredients": ["250 g paneer"],
        "steps": ["Fry"],
        "kcal": 400,
        "protein": 18,
        "origin_kind": "mine",
        "created_at": "2026-01-01T10:00:00Z",
    }
    payload.update(overrides)
    return payload


def _cook_payload(**overrides: Any) -> dict[str, Any]:
    payload = {
        "id": "c1",
        "dish_id": "dish-1",
        "version_id": "v1",
        "version_number": 1,
        "cooked_at": "2026-01-02T19:00:00Z",
        "photo_url": "",
        "photo_state": "none",
        "outcome": "good",
        "mood": "comfort",
        "note": "",
        "changes": [],
        "rating": 4,
    }
    payload.update(overrides)
    return payload


def _photo_payload(**overrides: Any) -> dict[str, Any]:
    payload = {
        "id": "p1",
        "role": "version",
        "version_id": "v1",
        "cook_id": None,
        "key": "photos/user-1/202601/abc123.jpg",
        "created_at": "2026-01-03T10:00:00Z",
    }
    payload.update(overrides)
    return payload


@pytest.fixture
def dish_payload():
    """Factory: ``dish_payload(title="x")``."""
    return _dish_payload


@pytest.fixture
def version_payload():
    return _version_payload


@pytest.fixture
def cook_payload():
    return _cook_payload


@pytest.fixture
def photo_payload():
    return _photo_payload
