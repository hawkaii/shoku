"""Import endpoints: cache first, queue second, state machine third."""

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from ..container import AppContext
from ..models import User
from ..schemas import ImportRequest, ImportResponse, ImportStatus
from ..imports import service as import_service
from .deps import current_user, get_context, get_session

router = APIRouter(prefix="/imports", tags=["imports"])


@router.post("", response_model=ImportResponse)
def create_import(
    payload: ImportRequest,
    response: Response,
    session: Session = Depends(get_session),
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> ImportResponse:
    result = import_service.start_import(
        session,
        ctx.import_deps,
        uid=user.id,
        url=payload.url,
        request_id=payload.request_id,
    )
    # 200 for a cache hit, 202 when work was actually queued.
    response.status_code = status.HTTP_202_ACCEPTED if not result.cached else status.HTTP_200_OK
    return result


@router.get("/{job_id}", response_model=ImportStatus)
def get_import(
    job_id: str,
    session: Session = Depends(get_session),
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> ImportStatus:
    return import_service.get_import(session, ctx.import_deps, uid=user.id, job_id=job_id)


@router.post("/{job_id}/cancel", response_model=ImportStatus)
def cancel_import(
    job_id: str,
    session: Session = Depends(get_session),
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> ImportStatus:
    """Cancel is a terminal ``failed`` with ``reason = "cancelled"``.

    The public state set is queued/extracting/ready/failed, so cancellation is
    expressed as a reason rather than a fifth state the client would have to
    learn.
    """
    return import_service.cancel_import(session, ctx.import_deps, uid=user.id, job_id=job_id)
