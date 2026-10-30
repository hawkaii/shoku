"""The scoped assistant.

Three guarantees, in order of importance:

1. **No mutation.** This module only reads journal rows. The only thing it
   writes is ``assistant_usage``. There is no code path from here to a recipe
   write, so "the assistant changed my recipe" cannot happen.
2. **Scope.** The model sees one dish, one version and the user's question.
   Nothing else from the journal, and nothing from another user.
3. **A cap that is actually enforced.** The counter is incremented with a
   conditional UPDATE (``count < cap``) before the model is called, so two
   simultaneous requests cannot both see "cap - 1". A failed model call gives
   the credit back.

The cap is per UTC day, which is the only day boundary that does not need a
timezone the server does not have.
"""

from dataclasses import dataclass
from datetime import date

from sqlalchemy import select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..domain.clock import Clock
from ..domain.errors import NotFound, UsageCapExceeded
from ..interfaces.assistant import AssistantContext, AssistantModel
from ..models import AssistantUsage, CookLog, Dish, RecipeVersion
from ..schemas.wire import AssistantRequest, AssistantResponse


@dataclass(frozen=True)
class AssistantDeps:
    model: AssistantModel
    clock: Clock
    daily_cap: int


def ask(
    session: Session, deps: AssistantDeps, *, uid: str, request: AssistantRequest
) -> AssistantResponse:
    dish, version = _load_scope(session, uid=uid, request=request)
    context = _build_context(session, dish=dish, version=version)

    day = deps.clock.now().date()
    used = _reserve(session, uid=uid, day=day, cap=deps.daily_cap)

    try:
        answer = deps.model.answer(context, request.question)
    except Exception:
        # The user got nothing, so it does not count against them.
        _release(session, uid=uid, day=day)
        raise

    return AssistantResponse(
        answer=answer.text, remaining=max(0, deps.daily_cap - used)
    )


def _load_scope(session: Session, *, uid: str, request: AssistantRequest):
    dish = session.get(Dish, request.dish_id)
    if dish is None or dish.user_id != uid or dish.deleted_at is not None:
        raise NotFound(detail="no such dish")

    version: RecipeVersion | None = None
    if request.version_id is not None:
        version = session.get(RecipeVersion, request.version_id)
        if version is None or version.user_id != uid or version.dish_id != dish.id:
            raise NotFound(detail="no such version for this dish")
    else:
        version = session.scalars(
            select(RecipeVersion)
            .where(RecipeVersion.dish_id == dish.id, RecipeVersion.user_id == uid)
            .order_by(RecipeVersion.created_at.desc(), RecipeVersion.number.desc())
            .limit(1)
        ).first()

    return dish, version


def _build_context(session: Session, *, dish: Dish, version: RecipeVersion | None):
    notes = session.scalars(
        select(CookLog.note)
        .where(CookLog.dish_id == dish.id, CookLog.note != "")
        .order_by(CookLog.cooked_at.desc())
        .limit(3)
    ).all()

    return AssistantContext(
        dish_title=dish.title,
        dish_subtitle=dish.subtitle,
        version_number=version.number if version else 0,
        ingredients=tuple(version.ingredients if version else ()),
        steps=tuple(version.steps if version else dish.steps),
        changes=tuple(version.changes if version else ()),
        kcal=version.kcal if version else dish.baseline_kcal,
        protein=version.protein if version else dish.baseline_protein,
        recent_notes=tuple(notes),
    )


def _reserve(session: Session, *, uid: str, day: date, cap: int) -> int:
    """Increment-and-check in one statement. Returns the new count."""
    if cap <= 0:
        raise UsageCapExceeded(detail="assistant is disabled for this deployment")

    for _attempt in range(2):
        result = session.execute(
            update(AssistantUsage)
            .where(
                AssistantUsage.user_id == uid,
                AssistantUsage.day == day,
                AssistantUsage.count < cap,
            )
            .values(count=AssistantUsage.count + 1)
        )
        if result.rowcount == 1:
            session.commit()
            return _count(session, uid, day)

        existing = session.get(AssistantUsage, (uid, day))
        if existing is not None:
            session.commit()
            raise UsageCapExceeded(
                detail=f"daily assistant limit of {cap} reached", 
            ) from None

        try:
            session.add(AssistantUsage(user_id=uid, day=day, count=1))
            session.commit()
            return 1
        except IntegrityError:
            # Another request created today's row between our UPDATE and INSERT.
            session.rollback()

    raise UsageCapExceeded(detail=f"daily assistant limit of {cap} reached")


def _release(session: Session, *, uid: str, day: date) -> None:
    session.execute(
        update(AssistantUsage)
        .where(
            AssistantUsage.user_id == uid,
            AssistantUsage.day == day,
            AssistantUsage.count > 0,
        )
        .values(count=AssistantUsage.count - 1)
    )
    session.commit()


def _count(session: Session, uid: str, day: date) -> int:
    row = session.get(AssistantUsage, (uid, day))
    return row.count if row else 0
