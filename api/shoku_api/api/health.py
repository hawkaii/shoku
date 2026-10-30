"""Liveness/readiness. Reports dependencies rather than hiding them."""

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session

from .. import __version__
from ..container import AppContext
from ..schemas.wire import HealthResponse
from .deps import get_context, get_session

router = APIRouter(tags=["health"])


@router.get("/health", response_model=HealthResponse)
def health(
    session: Session = Depends(get_session),
    ctx: AppContext = Depends(get_context),
) -> HealthResponse:
    try:
        session.execute(text("SELECT 1"))
        database = True
    except Exception:  # noqa: BLE001 - health must never raise
        database = False

    try:
        ctx.queue.depth()
        queue = True
    except Exception:  # noqa: BLE001
        queue = False

    return HealthResponse(
        status="ok" if (database and queue) else "degraded",
        database=database,
        queue=queue,
        version=__version__,
    )
