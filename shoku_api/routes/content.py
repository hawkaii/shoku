"""Cached content: read, and the takedown path.

``content_cache`` is global, so these routes are not user-scoped. They expose
only what was extracted, never who imported it.
"""

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from ..container import AppContext
from ..schemas import ContentResponse
from .. import content as content_service
from .deps import get_context, get_session

router = APIRouter(prefix="/content", tags=["content"])


@router.get("/{shortcode}", response_model=ContentResponse)
def get_content(
    shortcode: str,
    session: Session = Depends(get_session),
) -> ContentResponse:
    return content_service.get_content(session, shortcode)


@router.delete("/{shortcode}", status_code=status.HTTP_204_NO_CONTENT)
def delete_content(
    shortcode: str,
    response: Response,
    session: Session = Depends(get_session),
    ctx: AppContext = Depends(get_context),
) -> Response:
    """Takedown: erase the payload, keep the stub."""
    content_service.takedown(session, shortcode, clock=ctx.clock)
    session.commit()
    response.status_code = status.HTTP_204_NO_CONTENT
    return response
