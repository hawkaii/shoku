"""Scoped assistant endpoint."""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..container import AppContext
from ..models import User
from ..schemas.wire import AssistantRequest, AssistantResponse
from ..services import assistant as assistant_service
from .deps import current_user, get_context, get_session

router = APIRouter(prefix="/assistant", tags=["assistant"])


@router.post("/ask", response_model=AssistantResponse)
def ask(
    payload: AssistantRequest,
    session: Session = Depends(get_session),
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> AssistantResponse:
    return assistant_service.ask(
        session, ctx.assistant_deps, uid=user.id, request=payload
    )
