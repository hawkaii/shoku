"""The voice relay: handshake, passthrough, close codes, and the daily cap.

There is no Meta in these tests. A fake upstream records everything sent to it
and emits what the test tells it to, which is the only way to assert that binary
frames go up unchanged and events come down verbatim.
"""

import asyncio
import json
from datetime import date

import pytest
from fastapi.testclient import TestClient
from starlette.websockets import WebSocketDisconnect

from shoku_api.domain.errors import Unauthenticated
from shoku_api.models import VoiceUsage
from shoku_api.voice import (
    CLOSE_BAD_TOKEN,
    CLOSE_CAP,
    CLOSE_HANDSHAKE_TIMEOUT,
    CLOSE_UPSTREAM,
    parse_handshake,
    upstream_handshake,
)

GOOD = "Bearer good-token"
CAP_MS = 120 * 60_000


class FakeAuth:
    """Stands in for the Supabase verifier: one token, one uid."""

    def verify(self, headers):
        from shoku_api.auth import Identity

        raw = headers.get("authorization") or ""
        if raw != GOOD:
            raise Unauthenticated(detail="bad token")
        return Identity(uid="user-1")


class FakeUpstream:
    """Records what the relay sends; hands back whatever the test queued."""

    def __init__(self, events=()) -> None:
        self.sent: list = []
        self.events = list(events)
        self.closed = False
        self.binary_seen = asyncio.Event()

    async def send(self, data) -> None:
        self.sent.append(data)
        if isinstance(data, bytes):
            self.binary_seen.set()

    async def recv(self):
        if self.events:
            return self.events.pop(0)
        # Do not hang up before the client's audio has arrived, so a test that
        # asserts on forwarded bytes is not racing the close.
        try:
            await asyncio.wait_for(self.binary_seen.wait(), timeout=2)
        except asyncio.TimeoutError:
            pass
        raise ConnectionError("upstream closed")

    async def close(self) -> None:
        self.closed = True

    def handshake(self) -> dict:
        return json.loads(self.sent[0])

    def binary(self) -> list[bytes]:
        return [item for item in self.sent[1:] if isinstance(item, bytes)]


@pytest.fixture
def upstream_factory(ctx):
    """Install a connector that returns a prepared fake, and record the URL."""

    # The relay needs a server-side key; tests supply a fake one.
    ctx.settings = ctx.settings.model_copy(update={"assistant_api_key": "test-key"})

    def install(*, events=(), fail=None):
        upstream = FakeUpstream(events=events)
        calls: list[dict] = []

        async def connect(url, **kwargs):
            calls.append({"url": url, **kwargs})
            if fail is not None:
                raise fail
            return upstream

        ctx.voice_connect = connect
        upstream.calls = calls
        return upstream

    return install


def handshake(**overrides) -> str:
    body = {
        "authorization": GOOD,
        "language": "hi",
        "keywords": ["jeera", "paneer"],
        "sessionId": "session-1",
    }
    body.update(overrides)
    return json.dumps(body)


# ---- parsing --------------------------------------------------------------


def test_the_handshake_maps_the_language_to_metas_name() -> None:
    parsed = parse_handshake(handshake())

    assert parsed.language == "Hindi"
    assert parsed.keywords == ("jeera", "paneer")
    assert parsed.session_id == "session-1"


def test_an_unknown_language_is_english() -> None:
    assert parse_handshake(handshake(language="de")).language == "English"
    assert parse_handshake(handshake(language=None)).language == "English"


def test_keywords_are_capped_and_trimmed() -> None:
    parsed = parse_handshake(
        handshake(keywords=["x" * 100] + [f"k{i}" for i in range(80)])
    )

    assert len(parsed.keywords) == 50
    assert all(len(word) <= 60 for word in parsed.keywords)


def test_the_upstream_handshake_is_the_contracted_shape() -> None:
    payload = upstream_handshake(parse_handshake(handshake()), "muse-voice-transcribe-1.0")

    assert payload == {
        "audioEncoding": "PCM_24KHZ",
        "model": "muse-voice-transcribe-1.0",
        "mode": "ENDPOINTING",
        "partialMode": "CUMULATIVE",
        "languageBias": ["Hindi"],
        "keywords": ["jeera", "paneer"],
    }


# ---- the socket -----------------------------------------------------------


def test_a_good_token_opens_the_upstream(app, ctx, upstream_factory) -> None:
    ctx.auth = FakeAuth()
    upstream = upstream_factory()

    with TestClient(app) as client:
        with client.websocket_connect("/v1/voice/asr") as socket:
            socket.send_text(handshake())
            socket.send_bytes(b"\x00\x01" * 480)
            with pytest.raises(WebSocketDisconnect):
                # The fake upstream hangs up once its events are drained.
                while True:
                    socket.receive_text()

    assert upstream.calls[0]["url"] == ctx.settings.voice_asr_url
    assert upstream.calls[0]["additional_headers"]["Authorization"].startswith("Bearer ")
    assert upstream.handshake()["languageBias"] == ["Hindi"]
    assert upstream.binary() == [b"\x00\x01" * 480], "PCM goes up byte-for-byte"


def test_a_bad_token_closes_4401(app, ctx, upstream_factory) -> None:
    ctx.auth = FakeAuth()
    upstream = upstream_factory()

    with TestClient(app) as client:
        with pytest.raises(WebSocketDisconnect) as closed:
            with client.websocket_connect("/v1/voice/asr") as socket:
                socket.send_text(handshake(authorization="Bearer nope"))
                socket.receive_text()

    assert closed.value.code == CLOSE_BAD_TOKEN
    assert upstream.calls == [], "no upstream socket is opened for a bad token"


def test_a_junk_handshake_closes_4401(app, ctx) -> None:
    ctx.auth = FakeAuth()

    with TestClient(app) as client:
        with pytest.raises(WebSocketDisconnect) as closed:
            with client.websocket_connect("/v1/voice/asr") as socket:
                socket.send_text("not json")
                socket.receive_text()

    assert closed.value.code == CLOSE_BAD_TOKEN


def test_events_come_back_verbatim(app, ctx, upstream_factory) -> None:
    ctx.auth = FakeAuth()
    events = [
        json.dumps({"type": "speechStart"}),
        json.dumps({"type": "transcript", "text": "jeera", "final": False}),
        json.dumps({"type": "transcript", "text": "jeera daal", "final": True}),
    ]
    upstream_factory(events=events)

    received: list[str] = []
    with TestClient(app) as client:
        with client.websocket_connect("/v1/voice/asr") as socket:
            socket.send_text(handshake())
            for _ in events:
                received.append(socket.receive_text())
            with pytest.raises(WebSocketDisconnect):
                socket.receive_text()

    assert received == events, "the relay does not rewrite Meta's events"


def test_end_stream_is_forwarded_and_ends_the_relay(app, ctx, upstream_factory) -> None:
    ctx.auth = FakeAuth()
    upstream = upstream_factory()

    with TestClient(app) as client:
        with client.websocket_connect("/v1/voice/asr") as socket:
            socket.send_text(handshake())
            socket.send_text(json.dumps({"type": "endStream"}))
            with pytest.raises(WebSocketDisconnect):
                socket.receive_text()

    assert json.loads(upstream.sent[-1]) == {"type": "endStream"}


def test_an_upstream_that_will_not_open_closes_4402(app, ctx, upstream_factory) -> None:
    ctx.auth = FakeAuth()
    upstream_factory(fail=ConnectionError("no route"))

    with TestClient(app) as client:
        with pytest.raises(WebSocketDisconnect) as closed:
            with client.websocket_connect("/v1/voice/asr") as socket:
                socket.send_text(handshake())
                # The relay says why before it closes.
                assert json.loads(socket.receive_text())["message"] == "upstream_unavailable"
                socket.receive_text()

    assert closed.value.code == CLOSE_UPSTREAM


def test_no_handshake_in_time_closes_4408(app, ctx) -> None:
    ctx.auth = FakeAuth()
    ctx.settings = ctx.settings.model_copy(update={"voice_handshake_timeout": 0.2})

    with TestClient(app) as client:
        with pytest.raises(WebSocketDisconnect) as closed:
            with client.websocket_connect("/v1/voice/asr") as socket:
                socket.receive_text()

    assert closed.value.code == CLOSE_HANDSHAKE_TIMEOUT


# ---- metering -------------------------------------------------------------


def test_processed_audio_is_metered(app, ctx, upstream_factory) -> None:
    ctx.auth = FakeAuth()
    upstream_factory(
        events=[
            json.dumps({"type": "speechStart", "audioProcessedMs": 500}),
            json.dumps({"type": "speechEnd", "audioProcessedMs": 1500}),
        ]
    )

    with TestClient(app) as client:
        with client.websocket_connect("/v1/voice/asr") as socket:
            socket.send_text(handshake())
            socket.receive_text()
            socket.receive_text()
            with pytest.raises(WebSocketDisconnect):
                socket.receive_text()

    # The final write happens after the socket closes, so give it a moment
    # rather than racing the assertion against the relay's shutdown.
    import time as _time

    row = None
    for _ in range(40):
        with ctx.session_factory() as db:
            row = db.get(VoiceUsage, ("user-1", date.today()))
        if row is not None:
            break
        _time.sleep(0.05)

    assert row is not None
    assert row.audio_ms == 1500, "the later event is cumulative, not additive"


def test_a_session_over_the_cap_closes_4429(app, ctx, upstream_factory) -> None:
    ctx.auth = FakeAuth()
    # One minute left on the allowance, and the upstream says it has processed
    # more than that.
    with ctx.session_factory() as db:
        from shoku_api.models import VoiceUsage as Usage

        db.add(Usage(user_id="user-1", day=date.today(), audio_ms=CAP_MS - 60_000))
        db.commit()
    upstream_factory(events=[json.dumps({"type": "speechEnd", "audioProcessedMs": 90_000})])

    codes: list[str] = []
    with TestClient(app) as client:
        with pytest.raises(WebSocketDisconnect) as closed:
            with client.websocket_connect("/v1/voice/asr") as socket:
                socket.send_text(handshake())
                assert json.loads(socket.receive_text())["type"] == "speechEnd"
                codes.append(json.loads(socket.receive_text())["message"])
                socket.receive_text()

    assert codes == ["voice_cap_reached"]
    assert closed.value.code == CLOSE_CAP


def test_a_user_at_the_cap_is_refused_before_any_upstream(app, ctx, upstream_factory) -> None:
    ctx.auth = FakeAuth()
    with ctx.session_factory() as db:
        from shoku_api.models import VoiceUsage as Usage

        db.add(Usage(user_id="user-1", day=date.today(), audio_ms=CAP_MS))
        db.commit()
    upstream = upstream_factory()

    with TestClient(app) as client:
        with pytest.raises(WebSocketDisconnect) as closed:
            with client.websocket_connect("/v1/voice/asr") as socket:
                socket.send_text(handshake())
                message = json.loads(socket.receive_text())
                assert message == {"type": "error", "message": "voice_cap_reached"}
                socket.receive_text()

    assert closed.value.code == CLOSE_CAP
    assert upstream.calls == [], "no key is spent on a user who is out of minutes"


def test_no_key_configured_closes_cleanly(app, ctx) -> None:
    ctx.auth = FakeAuth()
    ctx.settings = ctx.settings.model_copy(
        update={"assistant_api_key": "", "structurer_api_key": ""}
    )

    with TestClient(app) as client:
        with pytest.raises(WebSocketDisconnect) as closed:
            with client.websocket_connect("/v1/voice/asr") as socket:
                socket.send_text(handshake())
                assert json.loads(socket.receive_text())["message"] == "voice_not_configured"
                socket.receive_text()

    assert closed.value.code == CLOSE_UPSTREAM
