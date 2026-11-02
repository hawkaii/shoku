"""Receipt parsing: the model fallback for the lines the device could not read."""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..container import AppContext
from ..models import User
from ..schemas import (
    PantryParseImageRequest,
    PantryParseRequest,
    PantryParseResponse,
)
from .. import pantry_parse as parse_service
from .deps import current_user, get_context, get_session

router = APIRouter(prefix="/pantry", tags=["pantry"])


@router.post("/parse", response_model=PantryParseResponse)
def parse_receipt(
    payload: PantryParseRequest,
    session: Session = Depends(get_session),
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> PantryParseResponse:
    """One batched call per receipt. Returns lines, never pantry rows."""
    return parse_service.parse(
        session, ctx.pantry_parse_deps, uid=user.id, request=payload
    )


@router.post("/parse-image", response_model=PantryParseResponse)
def parse_receipt_image(
    payload: PantryParseImageRequest,
    session: Session = Depends(get_session),
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> PantryParseResponse:
    """One vision call for a receipt photograph. Shares the text endpoint's cap."""
    return parse_service.parse_image(
        session, ctx.pantry_parse_deps, uid=user.id, request=payload
    )
