"""Account deletion.

Play requires an account to be erasable from inside the app, and the erase has
to be real: every row that carries a ``user_id``, every photo object in the
bucket, and — when the deployment holds a service key — the auth identity that
owns the email. What survives is what never belonged to the user: the public
Wall entry for a reel (it belongs to the creator being cached) and the reel's
cover image.
"""

import logging

import httpx
from fastapi import APIRouter, Depends, Response, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..container import AppContext
from ..models import Photo, User
from ..users import delete_account
from .deps import current_user, get_context, get_session

log = logging.getLogger("shoku.account")

router = APIRouter(prefix="/account", tags=["account"])


def _erase_photos(ctx: AppContext, session: Session, uid: str) -> None:
    """Objects first: a row is the only record of its key."""
    keys = session.scalars(select(Photo.key).where(Photo.user_id == uid)).all()
    for key in keys:
        try:
            ctx.storage.delete(key)
        except Exception:  # pragma: no cover - storage outage is not the user's fault
            # The rows still go. An orphaned object is cheaper than a deletion
            # that fails because the bucket was having a bad minute.
            log.warning("could not delete photo object %s", key, exc_info=True)


def _erase_identity(ctx: AppContext, uid: str) -> None:
    """Delete the Supabase user, so the email is not left behind.

    Only possible when the deployment holds a service key; without one the
    product data is still gone and the token simply resolves to a fresh, empty
    account if it is ever used again.
    """
    settings = ctx.settings
    if not settings.supabase_url or not settings.supabase_service_key:
        return
    try:
        httpx.delete(
            f"{settings.supabase_url.rstrip('/')}/auth/v1/admin/users/{uid}",
            headers={
                "apikey": settings.supabase_service_key,
                "authorization": f"Bearer {settings.supabase_service_key}",
            },
            timeout=10.0,
        )
    except Exception:  # pragma: no cover - depends on the network
        log.warning("could not delete the auth user %s", uid, exc_info=True)


@router.delete("", status_code=status.HTTP_204_NO_CONTENT)
def delete_me(
    session: Session = Depends(get_session),
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> Response:
    uid = user.id
    _erase_photos(ctx, session, uid)
    delete_account(session, uid)
    _erase_identity(ctx, uid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
