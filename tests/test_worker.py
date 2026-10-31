"""Worker startup: the model is warm before any job can claim the budget.

The bug this guards against is not subtle once seen: a lazy model load happens
inside the first import, the 60-second deadline kills the job mid-download, and
the next attempt starts the download from zero. Every container recreate
reproduces it, and the symptom is "timeout", which blames the wrong stage.
"""

import types
from pathlib import Path

import pytest

from shoku_api.imports import worker as worker_module

ROOT = Path(__file__).resolve().parents[1]


class Transcriber:
    def __init__(self, order: list[str], *, fail: bool = False) -> None:
        self.order = order
        self.fail = fail

    def warm(self) -> None:
        self.order.append("warm")
        if self.fail:
            raise RuntimeError("model could not be fetched")


def fake_worker(monkeypatch, ctx) -> None:
    monkeypatch.setattr(
        worker_module, "get_settings", lambda: types.SimpleNamespace(queue_backend="memory")
    )
    monkeypatch.setattr(worker_module, "build_context", lambda settings: ctx)


def test_the_worker_warms_before_it_claims_any_job(monkeypatch) -> None:
    order: list[str] = []

    class Queue:
        def dequeue(self, timeout=5):
            order.append("dequeue")
            # BaseException on purpose: the loop catches Exception and would
            # keep going, and this test is about what happened before that.
            raise SystemExit(0)

    fake_worker(monkeypatch, types.SimpleNamespace(queue=Queue(), transcriber=Transcriber(order)))

    with pytest.raises(SystemExit):
        worker_module.main()

    assert order == ["warm", "dequeue"], "no job may be claimed before the model is loaded"


def test_a_failed_warm_up_claims_nothing(monkeypatch) -> None:
    order: list[str] = []

    class Queue:
        def dequeue(self, timeout=5):
            order.append("dequeue")
            return None

    fake_worker(
        monkeypatch,
        types.SimpleNamespace(queue=Queue(), transcriber=Transcriber(order, fail=True)),
    )

    assert worker_module.main() == 1
    assert order == ["warm"], "a worker that cannot serve jobs must not take them"


def test_the_model_cache_survives_the_container() -> None:
    """A cache inside the container makes every recreate a cold start.

    Asserted against the compose file because that is where the mount lives;
    the unit tests above cannot see it.
    """
    compose = (ROOT / "deploy" / "docker-compose.worker.yml").read_text()

    assert "HF_HOME: /opt/hf-cache" in compose
    assert "hf-cache:/opt/hf-cache" in compose, "the cache must be a named volume"
    assert "hf-cache:" in compose.split("volumes:", 1)[1], "the volume must be declared"
