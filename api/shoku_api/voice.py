"""Hands-free voice: the API relays the microphone to Meta's streaming ASR.

The app never holds the Meta key. It opens a socket here, authenticates in the
first text frame, and we open the upstream socket on its behalf and pump frames
both ways. Nothing is buffered, nothing is written down: the audio is forwarded
and forgotten.

Why a proxy at all: a key shipped in an app binary is a published key, and the
speech key is the expensive one. The cost of the relay is one socket per cook.

Metering is by ``audioProcessedMs`` from the upstream — what Meta actually
processed — not by bytes we forwarded, because a client that pauses or
reconnects must not be charged twice for the same second.
"""

import asyncio
import json
import logging
from dataclasses import dataclass
from datetime import date
from typing import Any, Awaitable, Callable

from sqlalchemy.orm import Session

from .domain.clock import Clock
from .domain.errors import Unauthenticated
from .domain.locale import LOCALES, tag
from .models import VoiceUsage

log = logging.getLogger("shoku.voice")

#: Close codes. 44xx because 4xxx is the application range.
CLOSE_BAD_TOKEN = 4401
CLOSE_UPSTREAM = 4402
CLOSE_HANDSHAKE_TIMEOUT = 4408
CLOSE_CAP = 4429

MAX_KEYWORDS = 50
MAX_KEYWORD_LENGTH = 60

#: 24 kHz, 16-bit, mono: what the contract says the client sends.
PCM_BYTES_PER_MS = 24000 * 2 / 1000


@dataclass(frozen=True)
class Handshake:
    authorization: str
    #: Meta's name for the language, e.g. "Hindi".
    language: str
    keywords: tuple[str, ...]
    session_id: str | None


def parse_handshake(raw: str) -> Handshake:
    """The client's first text frame. Raises ``ValueError`` on anything unusable."""
    try:
        body = json.loads(raw)
    except (TypeError, ValueError) as exc:
        raise ValueError("handshake is not JSON") from exc
    if not isinstance(body, dict):
        raise ValueError("handshake is not an object")

    authorization = str(body.get("authorization") or "").strip()
    if not authorization:
        raise ValueError("handshake carries no authorization")

    language = LOCALES.get(tag(str(body.get("language") or "")) or "", "English")

    keywords: list[str] = []
    for item in body.get("keywords") or ():
        text = str(item).strip()
        if not text:
            continue
        keywords.append(text[:MAX_KEYWORD_LENGTH])
        if len(keywords) == MAX_KEYWORDS:
            break

    session = body.get("sessionId")
    return Handshake(
        authorization=authorization,
        language=language,
        keywords=tuple(keywords),
        session_id=str(session) if session else None,
    )


def upstream_handshake(handshake: Handshake, model: str) -> dict:
    """The frame Meta expects once the socket is open.

    ``ENDPOINTING`` is what lets the client skip a VAD: the model decides where
    speech starts and stops, and ``CUMULATIVE`` makes each partial a whole
    sentence rather than a delta the client would have to stitch.
    """
    return {
        "audioEncoding": "PCM_24KHZ",
        "model": model,
        "mode": "ENDPOINTING",
        "partialMode": "CUMULATIVE",
        "languageBias": [handshake.language],
        "keywords": list(handshake.keywords),
    }


# ---- metering -------------------------------------------------------------


def used_ms(session: Session, uid: str, day: date) -> int:
    row = session.get(VoiceUsage, (uid, day))
    return row.audio_ms if row else 0


def add_ms(session: Session, uid: str, day: date, audio_ms: int) -> int:
    """Add what was processed, creating the row on first use of the day."""
    row = session.get(VoiceUsage, (uid, day))
    if row is None:
        row = VoiceUsage(user_id=uid, day=day, audio_ms=max(0, audio_ms))
        session.add(row)
    else:
        row.audio_ms = int(row.audio_ms or 0) + max(0, audio_ms)
    session.commit()
    return row.audio_ms


def _processed_ms(event: str) -> int:
    """How much audio an upstream event says was processed, if it says so."""
    try:
        body = json.loads(event)
    except (TypeError, ValueError):
        return 0
    if not isinstance(body, dict):
        return 0
    value = body.get("audioProcessedMs")
    if value is None:
        return 0
    try:
        return max(0, int(float(value)))
    except (TypeError, ValueError):
        return 0


# ---- the relay ------------------------------------------------------------

Connector = Callable[..., Awaitable[Any]]


async def _default_connect(url: str, **kwargs: Any) -> Any:
    import websockets  # noqa: PLC0415 - optional dependency

    return await websockets.connect(url, **kwargs)


@dataclass
class Session:
    """Everything one socket needs, so the pump functions stay pure-ish."""

    websocket: Any
    upstream: Any
    uid: str
    day: date
    remaining_ms: int
    processed_ms: int = 0


async def serve(websocket: Any, *, ctx: Any) -> None:
    """The whole socket: handshake, cap, upstream, relay, meter."""
    settings = ctx.settings
    await websocket.accept()

    try:
        raw = await asyncio.wait_for(
            websocket.receive_text(), timeout=settings.voice_handshake_timeout
        )
    except asyncio.TimeoutError:
        await _close(websocket, CLOSE_HANDSHAKE_TIMEOUT)
        return
    except Exception:  # noqa: BLE001 - the client left before saying anything
        return

    try:
        handshake = parse_handshake(raw)
    except ValueError:
        await _close(websocket, CLOSE_BAD_TOKEN)
        return

    try:
        identity = await asyncio.to_thread(
            ctx.auth.verify, {"authorization": handshake.authorization}
        )
    except Unauthenticated:
        await _close(websocket, CLOSE_BAD_TOKEN)
        return
    except Exception:  # noqa: BLE001 - any verification failure is a bad token
        await _close(websocket, CLOSE_BAD_TOKEN)
        return

    day = ctx.clock.now().date()
    already = await asyncio.to_thread(_used_today, ctx, identity.uid, day)
    remaining = max(0, settings.voice_daily_minutes * 60_000 - already)
    if remaining <= 0:
        await _send(websocket, {"type": "error", "message": "voice_cap_reached"})
        await _close(websocket, CLOSE_CAP)
        return

    api_key = settings.assistant_api_key or settings.structurer_api_key
    if not api_key:
        await _send(websocket, {"type": "error", "message": "voice_not_configured"})
        await _close(websocket, CLOSE_UPSTREAM)
        return

    connector: Connector = ctx.voice_connect or _default_connect
    try:
        upstream = await asyncio.wait_for(
            connector(
                settings.voice_asr_url,
                additional_headers={"Authorization": f"Bearer {api_key}"},
            ),
            timeout=settings.voice_handshake_timeout,
        )
    except asyncio.TimeoutError:
        await _close(websocket, CLOSE_HANDSHAKE_TIMEOUT)
        return
    except Exception as exc:  # noqa: BLE001 - surface as one stable close code
        # Never log the key: the exception text comes from the client library.
        log.warning("voice upstream did not open: %s", type(exc).__name__)
        await _send(websocket, {"type": "error", "message": "upstream_unavailable"})
        await _close(websocket, CLOSE_UPSTREAM)
        return

    session = Session(
        websocket=websocket,
        upstream=upstream,
        uid=identity.uid,
        day=day,
        remaining_ms=remaining,
    )

    try:
        await upstream.send(
            json.dumps(upstream_handshake(handshake, settings.voice_asr_model))
        )
        await _relay(session)
    finally:
        await _shutdown(upstream)
        if session.processed_ms:
            await asyncio.to_thread(_record, ctx, session.uid, session.day, session.processed_ms)
        # Close explicitly. A handler that returns while a pump task was just
        # cancelled is not a reliable close signal, and the client must be told
        # the session is over.
        await _close(websocket, 1000)


async def _relay(session: Session) -> None:
    """Pump both directions until either side stops."""
    to_upstream = asyncio.create_task(_client_to_upstream(session))
    to_client = asyncio.create_task(_upstream_to_client(session))
    done, pending = await asyncio.wait(
        {to_upstream, to_client}, return_when=asyncio.FIRST_COMPLETED
    )
    for task in pending:
        task.cancel()
    # Bounded: a pump task stuck inside a send must not hold the socket open.
    if pending:
        await asyncio.wait(pending, timeout=1.0)
    for task in done:
        try:
            task.result()
        except (asyncio.CancelledError, Exception) as exc:  # noqa: BLE001
            log.info("voice relay ended: %s", type(exc).__name__)


async def _client_to_upstream(session: Session) -> None:
    while True:
        message = await session.websocket.receive()
        if message.get("type") == "websocket.disconnect":
            return
        payload = message.get("bytes")
        if payload is not None:
            # Forwarded and forgotten: audio is never buffered past this call.
            await session.upstream.send(payload)
            continue
        text = message.get("text")
        if text is not None:
            await session.upstream.send(text)
            if _is_end_stream(text):
                return


async def _upstream_to_client(session: Session) -> None:
    while True:
        try:
            event = await session.upstream.recv()
        except Exception:  # noqa: BLE001 - the upstream ended
            await _close(session.websocket, CLOSE_UPSTREAM)
            return

        if isinstance(event, bytes):  # pragma: no cover - Meta sends JSON
            await session.websocket.send_bytes(event)
            continue

        # `audioProcessedMs` is cumulative for the session: take the highest
        # value seen, never a sum, or a reconnect would be charged twice.
        session.processed_ms = max(session.processed_ms, _processed_ms(event))
        await session.websocket.send_text(event)

        if session.processed_ms >= session.remaining_ms:
            await _send(
                session.websocket,
                {"type": "error", "message": "voice_cap_reached"},
            )
            await _close(session.websocket, CLOSE_CAP)
            return


def _is_end_stream(text: str) -> bool:
    try:
        body = json.loads(text)
    except (TypeError, ValueError):
        return False
    return isinstance(body, dict) and body.get("type") == "endStream"


async def _close(websocket: Any, code: int) -> None:
    try:
        await websocket.close(code=code)
    except Exception:  # noqa: BLE001 - already gone
        pass


async def _send(websocket: Any, payload: dict) -> None:
    try:
        await websocket.send_text(json.dumps(payload))
    except Exception:  # noqa: BLE001 - the other end left first
        pass


async def _shutdown(upstream: Any) -> None:
    try:
        await upstream.close()
    except Exception:  # noqa: BLE001 - shutting down anyway
        pass


# ---- database helpers (run in a worker thread: the route is async) --------


def _used_today(ctx: Any, uid: str, day: date) -> int:
    with ctx.session_factory() as session:
        return used_ms(session, uid, day)


def _record(ctx: Any, uid: str, day: date, audio_ms: int) -> None:
    with ctx.session_factory() as session:
        add_ms(session, uid, day, audio_ms)
