"""Covers are copied once, and never at the cost of an import.

The bug: a platform CDN link expires within hours, so every Wall card older
than that showed a grey box. The fix is a copy in our own storage, taken at
extraction; everything here is about the copy being cheap, permanent, and
strictly optional.
"""

from io import BytesIO

import httpx
import pytest
from PIL import Image

from shoku_api import backfill_thumbs
from shoku_api.models import ContentCache
from shoku_api.photos import DevStorage, FakeStorage
from shoku_api.thumbnails import card_sized, stable_cover, thumb_key

SOURCE = "https://scontent.cdninstagram.com/v/t51/cover.jpg?oe=6AEBBA08"


def jpeg(width: int = 1600, height: int = 2000, colour=(180, 90, 60)) -> bytes:
    out = BytesIO()
    Image.new("RGB", (width, height), colour).save(out, "JPEG", quality=95)
    return out.getvalue()


class Response:
    def __init__(self, body: bytes, content_type: str = "image/jpeg") -> None:
        self.content = body
        self.headers = {"content-type": content_type}

    def raise_for_status(self) -> None:
        return None


def serve(monkeypatch, body: bytes, content_type: str = "image/jpeg") -> None:
    monkeypatch.setattr("httpx.get", lambda url, **kwargs: Response(body, content_type))


def refuse(monkeypatch, exc: Exception | None = None) -> None:
    def boom(url, **kwargs):
        raise exc or httpx.ConnectError("expired")

    monkeypatch.setattr("httpx.get", boom)


# ---- the copy itself ------------------------------------------------------


def test_a_cover_is_copied_and_a_permanent_url_is_returned(monkeypatch) -> None:
    storage = FakeStorage()
    serve(monkeypatch, jpeg())

    url = stable_cover(storage, SOURCE, shortcode="DtTHUMB1234")

    assert url == "https://media.test/thumbs/DtTHUMB1234/" + url.rsplit("/", 1)[1]
    assert url.startswith("https://media.test/")
    assert list(storage.written) == [thumb_key("DtTHUMB1234", storage.written[list(storage.written)[0]])]


def test_the_copy_is_card_sized_not_the_original(monkeypatch) -> None:
    storage = FakeStorage()
    original = jpeg(width=1600, height=2000)
    serve(monkeypatch, original)

    stable_cover(storage, SOURCE, shortcode="DtTHUMB1234")

    stored = next(iter(storage.written.values()))
    with Image.open(BytesIO(stored)) as image:
        assert image.format == "JPEG"
        assert image.width == 720, "2x a 360dp card; see the module docstring"
        assert image.height == 900, "the aspect ratio is kept"
    assert len(stored) < len(original) / 2
    assert len(stored) < 200_000


def test_a_small_image_is_not_blown_up(monkeypatch) -> None:
    storage = FakeStorage()
    serve(monkeypatch, jpeg(width=320, height=240))

    stable_cover(storage, SOURCE, shortcode="DtTHUMB1234")

    with Image.open(BytesIO(next(iter(storage.written.values())))) as image:
        assert image.width == 320


def test_a_dead_link_makes_no_copy(monkeypatch) -> None:
    storage = FakeStorage()
    refuse(monkeypatch)

    assert stable_cover(storage, SOURCE, shortcode="DtTHUMB1234") is None
    assert storage.written == {}


def test_a_non_image_response_makes_no_copy(monkeypatch) -> None:
    storage = FakeStorage()
    serve(monkeypatch, b"<html>not a picture</html>", content_type="text/html")

    assert stable_cover(storage, SOURCE, shortcode="DtTHUMB1234") is None
    assert storage.written == {}


def test_an_oversized_body_makes_no_copy(monkeypatch) -> None:
    storage = FakeStorage()
    serve(monkeypatch, b"x" * (9 * 1024 * 1024))

    assert stable_cover(storage, SOURCE, shortcode="DtTHUMB1234") is None


def test_a_storage_that_cannot_publish_returns_no_url(monkeypatch) -> None:
    """Dev storage must not hand back a placeholder that would 404 forever."""
    serve(monkeypatch, jpeg())

    assert stable_cover(DevStorage("https://media.example.invalid"), SOURCE, shortcode="X") is None


def test_garbage_bytes_are_not_an_image() -> None:
    assert card_sized(b"\x00\x01\x02 not an image") is None


def test_no_source_url_is_not_an_error(monkeypatch) -> None:
    assert stable_cover(FakeStorage(), None, shortcode="DtTHUMB1234") is None


# ---- in an import ---------------------------------------------------------


def fresh_session(client):
    return client.app.state.ctx.session_factory()


def test_a_failed_copy_keeps_the_platform_url_and_the_import_still_succeeds(
    client, worker, extractor, monkeypatch
) -> None:
    extractor.thumbnail = SOURCE
    refuse(monkeypatch)

    job = client.post(
        "/v1/imports", json={"url": "https://www.instagram.com/reel/DtTHUMB1234/"}
    ).json()
    assert worker.process(job["job_id"]).state == "ready"

    with fresh_session(client) as session:
        row = session.get(ContentCache, job["shortcode"])
        assert row is not None
        assert row.thumbnail_url == SOURCE, "a missing image is a monogram, not a failure"


def test_a_successful_copy_is_what_the_cache_stores(
    client, worker, extractor, monkeypatch
) -> None:
    extractor.thumbnail = SOURCE
    serve(monkeypatch, jpeg())

    job = client.post(
        "/v1/imports", json={"url": "https://www.instagram.com/reel/DtTHUMB5678/"}
    ).json()
    assert worker.process(job["job_id"]).state == "ready"

    with fresh_session(client) as session:
        row = session.get(ContentCache, job["shortcode"])
        assert row.thumbnail_url.startswith("https://media.test/thumbs/")
        assert "cdninstagram" not in row.thumbnail_url


# ---- backfill -------------------------------------------------------------


def add_cached(session, shortcode, *, thumbnail=SOURCE, deleted=False, created="2026-10-01T10:00:00Z"):
    from datetime import datetime, timezone

    row = ContentCache(
        shortcode=shortcode,
        structured_json={
            "title": "Cached",
            "servings": 2,
            "minutes": 5,
            "kcal": 0,
            "protein": 0,
            "ingredients": [{"name": "paneer", "amount": None, "grams": None}],
            "steps": ["Mix"],
            "tags": [],
        },
        prose_json={"summary": ""},
        thumbnail_url=thumbnail,
        source_url=f"https://www.instagram.com/reel/{shortcode}/",
        extraction_version=4,
        created_at=datetime.fromisoformat(created),
        deleted_at=datetime.now(timezone.utc) if deleted else None,
    )
    session.add(row)
    session.commit()
    return row


@pytest.fixture
def backfill(monkeypatch, ctx):
    monkeypatch.setattr(backfill_thumbs, "get_settings", lambda: ctx.settings)
    monkeypatch.setattr(backfill_thumbs, "build_context", lambda settings: ctx)
    return backfill_thumbs


def test_the_backfill_copies_rows_that_still_point_at_the_platform(backfill, session, ctx, monkeypatch, capsys) -> None:
    add_cached(session, "DtTHUMB1111")
    serve(monkeypatch, jpeg())

    assert backfill.main([]) == 0

    with ctx.session_factory() as s:
        row = s.get(ContentCache, "DtTHUMB1111")
        assert row.thumbnail_url.startswith("https://media.test/thumbs/")
    assert "copied 1" in capsys.readouterr().out


def test_the_backfill_is_idempotent(backfill, session, ctx, monkeypatch) -> None:
    add_cached(session, "DtTHUMB2222")
    serve(monkeypatch, jpeg())

    backfill.main([])
    with ctx.session_factory() as s:
        first = s.get(ContentCache, "DtTHUMB2222").thumbnail_url
    backfill.main([])

    with ctx.session_factory() as s:
        assert s.get(ContentCache, "DtTHUMB2222").thumbnail_url == first


def test_the_backfill_skips_a_dead_source_without_failing(backfill, session, ctx, monkeypatch) -> None:
    add_cached(session, "DtTHUMB3333")
    refuse(monkeypatch)

    assert backfill.main([]) == 0
    with ctx.session_factory() as s:
        assert s.get(ContentCache, "DtTHUMB3333").thumbnail_url == SOURCE


def test_the_backfill_leaves_a_taken_down_row_alone(backfill, session, ctx, monkeypatch) -> None:
    add_cached(session, "DtTHUMB4444", deleted=True)
    serve(monkeypatch, jpeg())

    backfill.main([])

    with ctx.session_factory() as s:
        row = s.get(ContentCache, "DtTHUMB4444")
        assert row.thumbnail_url == SOURCE, "an invisible row is not worth a copy"


def test_the_backfill_refuses_to_claim_work_it_cannot_do(backfill, ctx, monkeypatch, capsys) -> None:
    ctx.storage = DevStorage("https://media.example.invalid")

    assert backfill.main([]) == 2
    assert "storage is not configured" in capsys.readouterr().err
