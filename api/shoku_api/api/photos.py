"""Presigned uploads."""

from fastapi import APIRouter, Depends

from ..container import AppContext
from ..models import User
from ..schemas.wire import PresignRequest, PresignResponse
from ..services.photos import presign_upload
from .deps import current_user, get_context

router = APIRouter(prefix="/photos", tags=["photos"])


@router.post("/presign", response_model=PresignResponse)
def presign(
    payload: PresignRequest,
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> PresignResponse:
    return presign_upload(ctx.photo_deps, uid=user.id, request=payload, now=ctx.clock.now())
