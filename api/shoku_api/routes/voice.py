"""Hands-free voice: one relay socket per cook."""

from fastapi import APIRouter, WebSocket

from .. import voice as voice_service

router = APIRouter(prefix="/voice", tags=["voice"])


@router.websocket("/asr")
async def asr(websocket: WebSocket) -> None:
    """Auth in the first text frame, audio after it, Meta's events back.

    Not a ``/v1/*`` bearer route: a browser websocket client cannot set an
    ``Authorization`` header, which is why the token travels in the first frame
    instead.
    """
    await voice_service.serve(websocket, ctx=websocket.app.state.ctx)
