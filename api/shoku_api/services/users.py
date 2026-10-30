"""Users, and the only place rows are ever hard-deleted."""

from sqlalchemy import delete
from sqlalchemy.orm import Session

from ..models import AssistantUsage, CookLog, Dish, ImportJob, RecipeVersion, User, utcnow


def ensure_user(session: Session, uid: str) -> User:
    user = session.get(User, uid)
    if user is None:
        user = User(id=uid, created_at=utcnow())
        session.add(user)
        session.flush()
    return user


def delete_account(session: Session, uid: str) -> None:
    """Hard delete, and the only hard delete in the system.

    Journal rows are append-only and tombstones are permanent; the single
    exception is a user asking to be erased. Global content-cache entries
    belong to the creator being cached, not to this user, so they stay.
    """
    for model in (AssistantUsage, CookLog, RecipeVersion, Dish, ImportJob):
        session.execute(delete(model).where(model.user_id == uid))
    session.execute(delete(User).where(User.id == uid))
    session.commit()
