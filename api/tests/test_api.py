"""End-to-end: the HTTP surface a client actually walks."""

from fastapi.testclient import TestClient


def test_import_to_content_to_takedown(client: TestClient, worker, extractor) -> None:
    started = client.post(
        "/v1/imports", json={"url": "https://www.instagram.com/reel/reel42/"}
    )
    assert started.status_code == 202
    job = started.json()
    assert job["cached"] is False

    assert client.get(f"/v1/imports/{job['job_id']}").json()["state"] == "queued"
    assert worker.process(job["job_id"]).state == "ready"
    assert extractor.calls == 1

    content = client.get(f"/v1/content/{job['shortcode']}")
    assert content.status_code == 200
    body = content.json()
    assert body["recipe"]["title"] == "Paneer butter masala"
    assert body["prose"]["summary"].startswith("250 g paneer")
    assert body["creator"] == "@ravi"
    assert body["url"] == "https://www.instagram.com/reel/reel42/"
    from shoku_api.imports.pipeline import EXTRACTION_VERSION

    assert body["extraction_version"] == EXTRACTION_VERSION

    assert client.delete(f"/v1/content/{job['shortcode']}").status_code == 204
    assert client.get(f"/v1/content/{job['shortcode']}").status_code == 404

    # The tombstone stays, and the payload is genuinely gone.
    with client.app.state.ctx.session_factory() as session:
        from shoku_api.models import ContentCache

        row = session.get(ContentCache, job["shortcode"])
        assert row is not None
        assert row.deleted_at is not None
        assert row.structured_json is None
        assert row.prose_json is None


def test_youtube_urls_normalise_to_a_video_id(client: TestClient) -> None:
    for url in (
        "https://youtu.be/dQw4w9WgXcQ",
        "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "https://youtube.com/shorts/dQw4w9WgXcQ",
    ):
        body = client.post("/v1/imports", json={"url": url}).json()
        assert body["shortcode"] == "dQw4w9WgXcQ"


def test_content_miss_is_404(client: TestClient) -> None:
    assert client.get("/v1/content/nothere").status_code == 404


def test_content_exposes_step_ingredients(client: TestClient, session, ctx) -> None:
    from shoku_api.content import store_extraction
    from shoku_api.schemas import ProsePayload, RecipePayload

    recipe = RecipePayload(
        title="Cited",
        servings=2,
        minutes=10,
        kcal=0,
        protein=0,
        ingredients=[{"name": "ghee"}, {"name": "rice"}],
        steps=["Heat the ghee", "Add the rice"],
        tags=[],
        step_ingredients=[[0], [1, 0]],
    )
    store_extraction(
        session,
        shortcode="cited1",
        recipe=recipe,
        prose=ProsePayload(summary=""),
        creator=None,
        source_url="https://www.instagram.com/reel/cited1/",
        extraction_version=3,
        clock=ctx.clock,
    )

    body = client.get("/v1/content/cited1").json()
    assert body["recipe"]["step_ingredients"] == [[0], [1, 0]]


def test_a_parse_written_before_the_field_still_serves(client: TestClient, ctx) -> None:
    """Rows already in the cache have no key at all. They must not 500."""
    with ctx.session_factory() as session:
        from shoku_api.models import ContentCache

        session.add(
            ContentCache(
                shortcode="old1",
                structured_json={
                    "title": "Old parse",
                    "servings": 2,
                    "minutes": 10,
                    "kcal": 0,
                    "protein": 0,
                    "ingredients": [{"name": "paneer", "amount": None, "grams": None}],
                    "steps": ["Mix"],
                    "tags": [],
                },
                prose_json={"summary": ""},
                source_url="https://www.instagram.com/reel/old1/",
                extraction_version=3,
                created_at=ctx.clock.now(),
            )
        )
        session.commit()

    body = client.get("/v1/content/old1").json()
    assert body["recipe"]["step_ingredients"] is None


def test_unknown_route_is_404(client: TestClient) -> None:
    assert client.get("/v1/nope").status_code == 404
