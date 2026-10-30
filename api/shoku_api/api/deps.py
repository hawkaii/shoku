"""Shared FastAPI dependencies."""

from collections.abc import Iterator

from fastapi import Depends, Request
from sqlalchemy.orm import Session

from ..auth import Identity
from ..container import AppContext
from ..models import User
from ..services.users import ensure_user


def get_context(request: Request) -> AppContext:
    return request.app.state.ctx


def get_session(ctx: AppContext = Depends(get_context)) -> Iterator[Session]:
    session = ctx.session_factory()
    try:
        yield session
    finally:
        # No commit here: services own their transaction boundaries, because a
        # worker and a request must be able to interleave through the same rows.
        session.close()


def get_identity(request: Request, ctx: AppContext = Depends(get_context)) -> Identity:
    return ctx.auth.verify(request.headers)


def current_user(
    identity: Identity = Depends(get_identity),
    session: Session = Depends(get_session),
) -> User:
    user = ensure_user(session, identity.uid)
    session.commit()
    return user
