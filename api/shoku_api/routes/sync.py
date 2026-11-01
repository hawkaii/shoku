"""Sync endpoints.

Pull and push are separate calls on purpose. A client that is offline for a
week gets one cheap pull and one push, rather than a per-row negotiation.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..container import AppContext
from ..models import User
from ..schemas import PullRequest, PullResponse, PushRequest, PushResponse
from ..sync import SyncService
from .deps import current_user, get_context, get_session

router = APIRouter(prefix="/sync", tags=["sync"])


def _service(session: Session, ctx: AppContext) -> SyncService:
    settings = ctx.settings
    return SyncService(
        session,
        clock=ctx.clock,
        page_size=settings.sync_page_size,
        max_page_size=settings.sync_max_page_size,
        clock_skew_seconds=settings.clock_skew_allowance_seconds,
        # Only a deployment with a real bucket can promise a public URL. The
        # dev storage returns a placeholder, and a device that follows it would
        # show a broken image instead of its own copy.
        photo_public_base=(
            settings.storage_public_base_url if settings.storage_backend == "r2" else ""
        ),
    )


@router.post("/pull", response_model=PullResponse)
def pull(
    payload: PullRequest,
    session: Session = Depends(get_session),
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> PullResponse:
    """Rows changed after ``since``, grouped by table, tombstones included."""
    return _service(session, ctx).pull(
        user.id, since=payload.since, cursor=payload.cursor, limit=payload.limit
    )


@router.post("/push", response_model=PushResponse)
def push(
    payload: PushRequest,
    session: Session = Depends(get_session),
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> PushResponse:
    """Idempotent upsert. Append-only rows that already exist are ignored."""
    result = _service(session, ctx).push(
        user.id,
        dishes=payload.dishes,
        versions=payload.versions,
        cook_logs=payload.cook_logs,
        photos=payload.photos,
        pantry_items=payload.pantry_items,
    )
    session.commit()
    return result
