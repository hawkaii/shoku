"""Test harness: the real HTTP surface, the real services, an in-memory database
and fakes only where an external service would be.

Nothing here needs Postgres, Redis, a bucket, ffmpeg or a model provider.
"""

from __future__ import annotations

import itertools
from pathlib import Path
from typing import Any

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.pool import StaticPool

from shoku_api.config import Settings
from shoku_api.container import build_context
from shoku_api.domain.clock import Deadline
from shoku_api.interfaces.assistant import AssistantAnswer, AssistantContext
from shoku_api.interfaces.media import Extraction, UnconfiguredStructurer
from shoku_api.main import create_app
from shoku_api.models import Base
from shoku_api.worker.pipeline import ImportWorker

_shortcodes = itertools.count(1)


def _recipe() -> dict[str, Any]:
    return {
        "title": "Paneer butter masala",
        "servings": 3,
        "minutes": 35,
        "kcal": 420,
        "protein": 18,
        "ingredients": [{"name": "paneer", "grams": 250}],
        "steps": ["Fry the paneer.", "Simmer the gravy."],
        "tags": ["weeknight"],
    }


class FakeExtractor:
    """Returns a caption with quantities, so the caption-first path is used."""

    def __init__(self) -> None:
        self.calls = 0
        self.audio_path: Path | None = None

    def extract(self, url: str, workdir: Path, deadline: Deadline) -> Extraction:
        self.calls += 1
        audio = workdir / "audio.mp3"
        audio.write_bytes(b"not really audio")
        self.audio_path = audio
        return Extraction(
            caption="250 g paneer, 2 tbsp butter, 100 ml cream — simmer 20 min",
            creator="@ravi",
            source_url=url,
            audio_path=audio,
        )


class FakeTranscriber:
    def transcribe(self, audio_path: Path, deadline: Deadline) -> str:
        return "spoken words"


class FakeStructurer:
    def __init__(self, payload: dict[str, Any] | None = None) -> None:
        self.payload = payload or _recipe()

    def structure(self, text: str, *, caption_first: bool) -> dict[str, Any]:
        return dict(self.payload)


class FakeAssistant:
    def __init__(self, text: str = "It is done when the paneer squeaks.") -> None:
        self.text = text
        self.calls = 0

    def answer(self, context: AssistantContext, question: str) -> AssistantAnswer:
        self.calls += 1
        return AssistantAnswer(text=self.text)


@pytest.fixture
def settings() -> Settings:
    return Settings(
        environment="test",
        database_url="sqlite://",
        queue_backend="memory",
        storage_backend="dev",
        auth_mode="dev",
        assistant_daily_cap=3,
        breaker_min_samples=3,
        breaker_window=3,
    )


@pytest.fixture
def ctx(settings: Settings):
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        future=True,
    )
    Base.metadata.create_all(engine)
    return build_context(
        settings,
        engine=engine,
        extractor=FakeExtractor(),
        transcriber=FakeTranscriber(),
        structurer=FakeStructurer(),
        assistant_model=FakeAssistant(),
    )


@pytest.fixture
def client(ctx) -> TestClient:
    app = create_app(ctx.settings, ctx=ctx, create_tables=False)
    with TestClient(app) as c:
        c.headers.update({"X-Firebase-Uid": "user-1"})
        yield c


@pytest.fixture
def worker(ctx) -> ImportWorker:
    return ImportWorker(ctx)


@pytest.fixture
def recipe_payload() -> dict[str, Any]:
    return _recipe()


@pytest.fixture
def structurer(ctx) -> FakeStructurer:
    return ctx.structurer


@pytest.fixture
def extractor(ctx) -> FakeExtractor:
    return ctx.extractor


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


@pytest.fixture
def dish_payload():
    """Factory: `dish_payload(title="x")`."""
    return _dish_payload


@pytest.fixture
def version_payload():
    return _version_payload


@pytest.fixture
def cook_payload():
    return _cook_payload
