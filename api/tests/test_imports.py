"""The pipeline: states, budget, caption-first, breaker, cleanup."""

from __future__ import annotations

from pathlib import Path

from fastapi.testclient import TestClient
from sqlalchemy import select

from shoku_api.imports.fakes import FakeStructurer, ScriptedExtractor
from shoku_api.imports.pipeline import ImportWorker
from shoku_api.models import ImportJob

IG = "https://www.instagram.com/reel/abc123/"


def start(client: TestClient, url: str = IG) -> dict:
    response = client.post("/v1/imports", json={"url": url})
    assert response.status_code == 202, response.text
    return response.json()


def status(client: TestClient, job_id: str) -> dict:
    response = client.get(f"/v1/imports/{job_id}")
    assert response.status_code == 200, response.text
    return response.json()


def test_job_starts_queued_and_transitions_through_extracting(
    client, ctx, worker
) -> None:
    body = start(client)
    assert body["state"] == "queued"
    assert body["cached"] is False
    assert status(client, body["job_id"])["state"] == "queued"

    observed: list[str] = []

    class ObservingStructurer(FakeStructurer):
        def structure(self, text: str, *, caption_first: bool):
            with ctx.session_factory() as session:
                job = session.scalars(select(ImportJob)).one()
                observed.append(job.state)
            return super().structure(text, caption_first=caption_first)

    ctx.structurer = ObservingStructurer()

    result = worker.process(body["job_id"])
    assert result.state == "ready"
    assert observed == ["extracting"], "the job must be extracting while it works"

    final = status(client, body["job_id"])
    assert final["state"] == "ready"
    assert final["reason"] is None
    assert final["progress_stage"] == "ready"


def test_cache_hit_does_not_enqueue(client, worker, ctx) -> None:
    first = start(client)
    worker.process(first["job_id"])
    enqueued_after_first = len(ctx.queue.enqueued)

    second = client.post("/v1/imports", json={"url": IG})
    assert second.status_code == 200
    assert second.json()["cached"] is True
    assert second.json()["job_id"] is None
    assert second.json()["shortcode"] == first["shortcode"]
    assert len(ctx.queue.enqueued) == enqueued_after_first, "no new work to do"


def test_duplicate_active_job_reuses_the_same_queue_entry(client, ctx) -> None:
    first = start(client)
    second = start(client)
    assert second["job_id"] == first["job_id"]
    assert len(ctx.queue.enqueued) == 1


def test_caption_with_quantities_skips_asr(client, worker, transcriber, structurer) -> None:
    body = start(client)
    result = worker.process(body["job_id"])

    assert result.mode == "caption_first"
    assert transcriber.calls == 0
    assert structurer.caption_first == [True]


def test_caption_without_quantities_uses_asr(client, worker, ctx, transcriber) -> None:
    ctx.extractor = ScriptedExtractor()
    body = start(client)
    result = worker.process(body["job_id"])

    assert result.mode == "transcript"
    assert transcriber.calls == 1
    assert transcriber.audio_seen[0].exists() is False, "audio is deleted, never persisted"


def test_breaker_degrades_to_caption_only(client, worker, ctx, transcriber) -> None:
    with ctx.session_factory() as session:
        for i in range(20):
            session.add(
                ImportJob(
                    id=f"old-{i}",
                    user_id="user-1",
                    shortcode=f"dead{i:03d}",
                    state="failed",
                    reason="extraction_failed",
                    progress_stage="failed",
                    created_at=ctx.clock.now(),
                    updated_at=ctx.clock.now(),
                )
            )
        session.commit()

    # A caption with no quantities would normally force a transcription.
    ctx.extractor = ScriptedExtractor()
    body = start(client)
    result = worker.process(body["job_id"])

    assert result.mode == "caption_only_degraded"
    assert transcriber.calls == 0
    assert status(client, body["job_id"])["state"] == "ready"


def test_breaker_ignores_cancellations(client, worker, ctx, transcriber) -> None:
    with ctx.session_factory() as session:
        for i in range(20):
            session.add(
                ImportJob(
                    id=f"cancel-{i}",
                    user_id="user-1",
                    shortcode=f"gone{i:03d}",
                    state="failed",
                    reason="cancelled",
                    progress_stage="cancelled",
                    created_at=ctx.clock.now(),
                    updated_at=ctx.clock.now(),
                )
            )
        session.commit()

    ctx.extractor = ScriptedExtractor()
    body = start(client)
    result = worker.process(body["job_id"])

    assert result.mode == "transcript", "a cancellation is not a pipeline failure"
    assert transcriber.calls == 1


def test_hard_budget_failure(client, worker, ctx) -> None:
    ctx.settings.import_budget_seconds = 0
    body = start(client)
    result = worker.process(body["job_id"])

    assert result.state == "failed"
    assert result.reason == "timeout"
    assert ctx.extractor.calls == 0
    assert status(client, body["job_id"])["reason"] == "timeout"


def test_audio_is_never_persisted(client, worker, ctx, tmp_path: Path) -> None:
    ctx.settings.media_tmp_dir = str(tmp_path)
    body = start(client)
    worker.process(body["job_id"])

    assert ctx.extractor.workdir is not None
    assert not ctx.extractor.workdir.exists()
    assert list(tmp_path.iterdir()) == [], "the temp dir must be empty after the job"


def test_extraction_failure_marks_the_job_failed(client, worker, ctx) -> None:
    ctx.extractor.fail = True
    body = start(client)
    result = worker.process(body["job_id"])

    assert result.state == "failed"
    assert result.reason == "extraction_failed"


def test_invalid_structured_output_fails_validation(client, worker, ctx) -> None:
    # Malformed but not empty: an empty recipe now means "look at the video",
    # so this keeps testing what it was written for — junk never reaches cache.
    ctx.structurer = FakeStructurer(
        {"title": "x", "ingredients": "not a list", "steps": ["stir"]}
    )
    body = start(client)
    result = worker.process(body["job_id"])

    assert result.state == "failed"
    assert result.reason == "invalid_recipe"
    assert client.get("/v1/content/abc123").status_code == 404


def test_cancel_is_terminal_and_the_worker_skips(client, worker) -> None:
    body = start(client)
    cancelled = client.post(f"/v1/imports/{body['job_id']}/cancel")
    assert cancelled.status_code == 200
    assert cancelled.json()["state"] == "failed"
    assert cancelled.json()["reason"] == "cancelled"

    assert worker.process(body["job_id"]).state == "skipped"
    # Cancelling twice is a no-op, not an error.
    assert client.post(f"/v1/imports/{body['job_id']}/cancel").status_code == 200


def test_taken_down_shortcode_cannot_be_reimported(client, worker) -> None:
    body = start(client)
    worker.process(body["job_id"])
    client.delete(f"/v1/content/{body['shortcode']}")

    response = client.post("/v1/imports", json={"url": IG})
    assert response.status_code == 410
    assert response.json()["error"] == "gone"


def test_another_user_cannot_read_a_job(client, app, worker) -> None:
    from fastapi.testclient import TestClient

    body = start(client)
    with TestClient(app) as other:
        other.headers.update({"X-Firebase-Uid": "user-2"})
        assert other.get(f"/v1/imports/{body['job_id']}").status_code == 404


def test_unsupported_url_is_rejected(client) -> None:
    response = client.post("/v1/imports", json={"url": "https://example.com/reel/x"})
    assert response.status_code == 422
    assert response.json()["error"] == "unsupported_url"


def test_worker_is_constructible_without_http(ctx) -> None:
    assert isinstance(ImportWorker(ctx), ImportWorker)


# ---- structurer fallback ---------------------------------------------------


def test_fallback_structurer_uses_the_heuristic_when_the_model_fails():
    from shoku_api.imports.adapters import FallbackStructurer, HeuristicStructurer

    class Broken:
        name = "meta"

        def structure(self, text, *, caption_first):
            raise RuntimeError("model is down")

    text = "250 g paneer\n2 tbsp butter\nHeat the pan\nAdd the paneer\nServe hot"
    result = FallbackStructurer(Broken(), HeuristicStructurer()).structure(
        text, caption_first=True
    )

    assert len(result["ingredients"]) == 2
    assert "Serve hot" in result["steps"], "short real steps must survive"
    assert "fallback" in result["tags"]


def test_heuristic_keeps_short_steps_instead_of_dropping_them():
    from shoku_api.imports.adapters import HeuristicStructurer

    text = "250 g paneer\n2 tbsp butter\nMix well\nServe hot\nGarnish"
    result = HeuristicStructurer().structure(text, caption_first=True)

    assert result["steps"] == ["Mix well", "Serve hot", "Garnish"]


# ---- Muse structurer -----------------------------------------------------


def test_schema_matches_recipe_payload():
    """The JSON schema and the Pydantic model must not drift apart.

    The schema is what the decoder is constrained to; RecipePayload is what the
    pipeline validates. If a field is added to one and not the other, imports
    fail at the last step instead of the first.
    """
    from shoku_api.imports.adapters import OpenAICompatStructurer
    from shoku_api.schemas import RecipePayload

    schema = OpenAICompatStructurer.SCHEMA
    assert set(schema["required"]) == set(RecipePayload.model_fields)
    assert set(schema["properties"]) == set(RecipePayload.model_fields)
    assert schema["additionalProperties"] is False


def test_muse_is_told_how_to_cite_step_ingredients():
    """The decoder can only fill the field if the prompt says what it means."""
    from shoku_api.imports.adapters import OpenAICompatStructurer

    prompt = OpenAICompatStructurer.PROMPT
    assert "step_ingredients" in prompt
    assert "zero-based" in prompt
    assert "one entry per step" in prompt


def test_step_ingredients_survive_a_constrained_call(monkeypatch):
    from shoku_api.imports import adapters

    content = (
        '{"title":"x","servings":2,"minutes":5,"kcal":0,"protein":0,'
        '"ingredients":[{"name":"ghee","amount":null,"grams":null},'
        '{"name":"rice","amount":null,"grams":null}],'
        '"steps":["Heat the ghee","Add the rice"],'
        '"tags":[],"step_ingredients":[[0],[1]]}'
    )

    class Resp:
        def raise_for_status(self): pass
        def json(self):
            return {"choices": [{"message": {"content": content}, "finish_reason": "stop"}]}

    monkeypatch.setattr("httpx.post", lambda url, **kw: Resp())
    s = adapters.OpenAICompatStructurer("https://api.meta.ai/v1", "k", "muse-spark-1.3")

    assert s.structure("text", caption_first=True)["step_ingredients"] == [[0], [1]]


def test_clipping_drops_a_citation_that_points_nowhere():
    """An invented index must not cost the whole parse."""
    from shoku_api.imports.adapters import _clip_step_ingredients

    raw = {
        "ingredients": [{"name": "ghee"}, {"name": "rice"}],
        "steps": ["Heat the ghee", "Add the rice", "Serve"],
        "step_ingredients": [[0], [1, 7], [-1]],
    }
    assert _clip_step_ingredients(raw)["step_ingredients"] == [[0], [1], []]


def test_clipping_discards_the_field_when_it_cannot_be_trusted():
    from shoku_api.imports.adapters import _clip_step_ingredients

    ingredients = [{"name": "ghee"}, {"name": "rice"}]
    steps = ["Heat the ghee", "Add the rice"]

    # Wrong number of entries: positions no longer line up with the steps.
    assert (
        _clip_step_ingredients(
            {"ingredients": ingredients, "steps": steps, "step_ingredients": [[0]]}
        )["step_ingredients"]
        is None
    )
    # Not the right shape at all.
    assert (
        _clip_step_ingredients(
            {"ingredients": ingredients, "steps": steps, "step_ingredients": "0,1"}
        )["step_ingredients"]
        is None
    )


def test_merging_duplicate_ingredients_remaps_the_citations():
    """Dropping an ingredient renumbers the rest; a stale index looks right."""
    from shoku_api.imports.adapters import _merge_duplicate_ingredients

    recipe = {
        "ingredients": [
            {"name": "ghee", "amount": "2 tbsp", "grams": None},
            {"name": "Ghee ", "amount": None, "grams": None},
            {"name": "rice", "amount": None, "grams": None},
        ],
        "steps": ["Fry in the ghee", "Add the rice"],
        "step_ingredients": [[0, 1], [2]],
    }
    merged = _merge_duplicate_ingredients(recipe)

    assert [i["name"] for i in merged["ingredients"]] == ["ghee", "rice"]
    # Both ghee citations collapse onto the surviving line; rice moves 2 -> 1.
    assert merged["step_ingredients"] == [[0, 0], [1]]


def test_the_heuristic_never_invents_citations():
    from shoku_api.imports.adapters import HeuristicStructurer

    result = HeuristicStructurer().structure(
        "250 g paneer\n2 tbsp butter\nMix well\nServe hot", caption_first=True
    )
    assert result["step_ingredients"] is None


def test_duplicate_ingredients_are_merged():
    from shoku_api.imports.adapters import _merge_duplicate_ingredients

    recipe = {
        "ingredients": [
            {"name": "ghee", "amount": "2 tbsp", "grams": None},
            {"name": "Ghee ", "amount": "1 tbsp", "grams": None},
            {"name": "rice", "amount": None, "grams": None},
            {"name": "rice", "amount": "1.5 cups", "grams": 300},
        ]
    }
    merged = _merge_duplicate_ingredients(recipe)["ingredients"]

    assert len(merged) == 2, "the same ingredient twice is a mistake in a cookbook"
    assert merged[1] == {"name": "rice", "amount": "1.5 cups", "grams": 300}


def test_structurer_pins_low_reasoning_effort_and_large_budget(monkeypatch):
    """Reasoning tokens share the budget with the answer.

    A smaller budget is not a saving; it returns an empty response, which is
    how the first attempt failed.
    """
    from shoku_api.imports import adapters

    captured = {}

    class Resp:
        def raise_for_status(self): pass
        def json(self):
            return {
                "choices": [{"message": {"content": '{"title":"x","servings":2,"minutes":5,'
                          '"kcal":0,"protein":0,"ingredients":[],"steps":[],"tags":[]}'},
                          "finish_reason": "stop"}],
                "usage": {},
            }

    def fake_post(url, **kwargs):
        captured.update(kwargs["json"])
        return Resp()

    monkeypatch.setattr("httpx.post", fake_post)
    s = adapters.OpenAICompatStructurer("https://api.meta.ai/v1", "k", "muse-spark-1.3")
    s.structure("some text", caption_first=True)

    assert captured["reasoning_effort"] == "minimal"
    assert captured["max_tokens"] >= 4000
    assert captured["response_format"]["json_schema"]["strict"] is True


def test_fallback_reports_the_structurer_that_actually_ran():
    """Provenance must name what produced the parse, not what was tried."""
    from shoku_api.imports.adapters import FallbackStructurer, HeuristicStructurer

    class Broken:
        name = "muse"

        def structure(self, text, *, caption_first):
            raise RuntimeError("down")

    active = FallbackStructurer(Broken(), HeuristicStructurer())
    assert active.name == "muse"
    active.structure("250 g paneer\n2 tbsp butter\nMix well", caption_first=True)
    assert active.name == "heuristic"


# ---- cache staleness -------------------------------------------------------


def test_stale_cache_is_re_extracted_instead_of_served(session, ctx):
    """An old parse must not outlive the extractor that produced it.

    Serving it would keep showing a dish the current pipeline would no longer
    write — a fixed importer that appears not to have been fixed.
    """
    from shoku_api.content import store_extraction
    from shoku_api.imports.pipeline import EXTRACTION_VERSION
    from shoku_api.schemas import ProsePayload, RecipePayload

    recipe = RecipePayload(
        title="Old parse",
        servings=2,
        minutes=10,
        kcal=0,
        protein=0,
        ingredients=[{"name": "paneer"}],
        steps=["Mix"],
        tags=[],
    )
    prose = ProsePayload(summary="old")

    def write(version, title):
        return store_extraction(
            session,
            shortcode="stale1",
            recipe=recipe.model_copy(update={"title": title}),
            prose=prose,
            creator=None,
            source_url="https://www.instagram.com/reel/stale1/",
            extraction_version=version,
            clock=ctx.clock,
        )

    write(EXTRACTION_VERSION - 1, "Old parse")
    row = write(EXTRACTION_VERSION, "New parse")

    assert row.structured_json["title"] == "New parse", "a stale row is replaced"

    # An equal version is left alone: re-importing the same reel must not
    # rewrite an identical result.
    row = write(EXTRACTION_VERSION, "Rewritten")
    assert row.structured_json["title"] == "New parse"


# ---- silent reels: reading frames ------------------------------------------


SILENT = "https://www.instagram.com/reel/silent1/"


def _silent_job(client, ctx, monkeypatch, *, vision, transcriber_text=""):
    """A reel with no caption, no comment, no subtitles and no speech."""
    from shoku_api.imports import fakes, pipeline

    ctx.extractor = fakes.FakeExtractor(caption="", creator="@ravi")
    ctx.transcriber = fakes.FakeTranscriber(text=transcriber_text)
    ctx.vision = vision
    monkeypatch.setattr(
        pipeline, "sample_frames", lambda *a, **k: [Path("frame_001.jpg")]
    )
    body = start(client, SILENT)
    return body, ctx


def test_a_silent_reel_is_read_from_frames(client, ctx, worker, monkeypatch) -> None:
    from shoku_api.imports.fakes import FakeVision

    vision = FakeVision()
    body, _ = _silent_job(client, ctx, monkeypatch, vision=vision)
    result = worker.process(body["job_id"])

    assert result.mode == "vision"
    assert vision.calls == 1, "the frames are what carried this import"
    assert status(client, body["job_id"])["state"] == "ready"

    content = client.get(f"/v1/content/{body['shortcode']}").json()
    assert content["recipe"]["title"] == "Read from the video"
    # The dish says it was read, not narrated: an approximation, labelled.
    assert "from video" in content["recipe"]["tags"]


def test_a_silent_reel_without_vision_fails_clearly(
    client, ctx, worker, monkeypatch
) -> None:
    from shoku_api.imports.fakes import FakeStructurer

    structurer = FakeStructurer()
    body, _ = _silent_job(client, ctx, monkeypatch, vision=None)
    ctx.structurer = structurer
    worker.process(body["job_id"])

    job = status(client, body["job_id"])
    assert job["state"] == "failed"
    assert job["reason"] == "no_text"
    assert structurer.calls == 0, "there was no text to structure"


def test_frames_are_sampled_evenly_across_the_clip(monkeypatch, tmp_path) -> None:
    """Even spacing, not the first sixteen frames of the opening shot."""
    from shoku_api.imports import adapters

    captured = {}

    def fake_run(command, **kwargs):
        captured["command"] = command

        class Done:
            returncode = 0
            stderr = ""

        (tmp_path / "frames").mkdir(exist_ok=True)
        (tmp_path / "frames" / "frame_001.jpg").write_bytes(b"jpeg")
        return Done()

    monkeypatch.setattr("subprocess.run", fake_run)

    frames = adapters.sample_frames(
        tmp_path / "media.mp4", tmp_path, count=16, duration=30.0
    )

    command = captured["command"]
    assert frames and frames[0].name == "frame_001.jpg"
    assert "fps=1/1.875" in " ".join(command), "30s / 16 frames is one every 1.9s"
    assert "scale=720" in " ".join(command)
    assert command[command.index("-frames:v") + 1] == "16"


# ---- creator handle --------------------------------------------------------


def test_handle_comes_from_the_profile_url_not_the_numeric_id() -> None:
    from shoku_api.imports.adapters import _creator_handle

    # Instagram reports uploader_id as a numeric account id, which reads as a
    # bug in the UI ("@273008788").
    assert (
        _creator_handle(
            {
                "uploader_id": "273008788",
                "uploader_url": "https://www.instagram.com/kanji_club_/",
            }
        )
        == "@kanji_club_"
    )


def test_handle_is_omitted_rather_than_showing_a_numeric_id() -> None:
    from shoku_api.imports.adapters import _creator_handle

    assert _creator_handle({"uploader_id": "273008788"}) is None
    assert _creator_handle({"uploader_id": "someuser"}) == "@someuser"


def test_a_junk_caption_falls_back_to_the_video(client, ctx, worker, monkeypatch) -> None:
    """Long text is not the same as a recipe: hashtags must not block the video.

    The real failure this covers: a caption of '#food #recipe' passed the
    length check, the model was handed nothing, and the import died as
    invalid_recipe while the video itself was perfectly readable.
    """
    from shoku_api.imports import fakes, pipeline
    from shoku_api.imports.fakes import FakeVision

    ctx.extractor = fakes.FakeExtractor(
        caption="#food #recipe #cooking #dinner #yum #homemade #instafood", creator="@ravi"
    )
    ctx.transcriber = fakes.FakeTranscriber(text="")
    vision = FakeVision()
    ctx.vision = vision
    monkeypatch.setattr(
        pipeline, "sample_frames", lambda *a, **k: [Path("frame_001.jpg")]
    )

    body = start(client, SILENT)
    result = worker.process(body["job_id"])

    assert result.mode == "vision"
    assert vision.calls == 1
    assert status(client, body["job_id"])["state"] == "ready"
