"""The Wall: a read-only feed of extractions someone chose to share.

Authenticated, like every other ``/v1`` call. "Public" here means every user of
the app can see it, not that it is served to the open internet: an anonymous
feed would be the bulk endpoint the legal posture says voids the whole cache.
"""

from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..container import AppContext
from .. import feed as feed_service
from ..schemas import FeedResponse, SuggestionResponse
from .deps import current_user, get_context, get_session
from ..models import User

router = APIRouter(prefix="/feed", tags=["feed"])


@router.get("", response_model=FeedResponse)
def get_feed(
    limit: Annotated[int, Query(ge=1, le=50)] = 20,
    cursor: Annotated[str | None, Query(max_length=512)] = None,
    session: Session = Depends(get_session),
    user: User = Depends(current_user),
) -> FeedResponse:
    """Newest first. Cards carry the extraction and nothing about who imported it."""
    return feed_service.list_feed(session, limit=limit, cursor=cursor)


@router.get("/suggestions", response_model=SuggestionResponse)
def get_suggestions(
    limit: Annotated[int, Query(ge=1, le=50)] = 20,
    cursor: Annotated[str | None, Query(max_length=512)] = None,
    session: Session = Depends(get_session),
    user: User = Depends(current_user),
) -> SuggestionResponse:
    """Cards the caller can mostly cook, from their own pantry. Names only."""
    return feed_service.suggestions(session, uid=user.id, limit=limit, cursor=cursor)
