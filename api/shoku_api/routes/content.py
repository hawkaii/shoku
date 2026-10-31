"""Cached content: read, the takedown path, and the Wall's publish switch.

``content_cache`` is global, so these routes are not user-scoped. They expose
only what was extracted, never who imported it.
"""

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from ..container import AppContext
from ..models import User
from ..schemas import ContentResponse, ReportResponse, ShareResponse
from .. import content as content_service
from .. import feed as feed_service
from .deps import current_user, get_context, get_session

router = APIRouter(prefix="/content", tags=["content"])


@router.get("/{shortcode}", response_model=ContentResponse)
def get_content(
    shortcode: str,
    session: Session = Depends(get_session),
) -> ContentResponse:
    return content_service.get_content(session, shortcode)


@router.put("/{shortcode}/share", response_model=ShareResponse)
def share_content(
    shortcode: str,
    session: Session = Depends(get_session),
    user: User = Depends(current_user),
) -> ShareResponse:
    """Put this extraction on the Wall. An explicit act, by a signed-in user."""
    row = feed_service.publish(session, shortcode)
    session.commit()
    return ShareResponse(shortcode=row.shortcode, shared=row.shared)


@router.delete("/{shortcode}/share", response_model=ShareResponse)
def unshare_content(
    shortcode: str,
    session: Session = Depends(get_session),
    user: User = Depends(current_user),
) -> ShareResponse:
    row = feed_service.unpublish(session, shortcode)
    session.commit()
    return ShareResponse(shortcode=row.shortcode, shared=row.shared)


@router.post("/{shortcode}/report", response_model=ReportResponse)
def report_content(
    shortcode: str,
    session: Session = Depends(get_session),
    ctx: AppContext = Depends(get_context),
    user: User = Depends(current_user),
) -> ReportResponse:
    """Report a card. Distinct users only; enough of them unshares it."""
    row = feed_service.report(
        session,
        shortcode=shortcode,
        user_id=user.id,
        threshold=ctx.settings.feed_report_threshold,
        clock=ctx.clock,
    )
    session.commit()
    return ReportResponse(
        shortcode=row.shortcode,
        reported_count=row.reported_count,
        shared=row.shared,
    )


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
