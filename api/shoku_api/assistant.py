"""The scoped assistant: interface, test double, and the daily cap.

Scope is the whole safety story. The model is handed one dish, one version and
the user's question. It has no write path — this module only ever reads journal
rows, and the single thing it writes is ``assistant_usage``. "The assistant
edited my recipe" is not a bug that can happen here; it is structurally absent.
"""

from dataclasses import dataclass, field
from datetime import date
from typing import Protocol

from sqlalchemy import select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from .domain.clock import Clock
from .domain.errors import NotFound, Unavailable, UsageCapExceeded
from .models import AssistantUsage, CookLog, Dish, RecipeVersion
from .schemas import AssistantRequest, AssistantResponse


@dataclass(frozen=True)
class AssistantContext:
    dish_title: str
    dish_subtitle: str = ""
    version_number: int = 0
    ingredients: tuple[str, ...] = ()
    steps: tuple[str, ...] = ()
    changes: tuple[str, ...] = ()
    kcal: int = 0
    protein: int = 0
    recent_notes: tuple[str, ...] = ()


@dataclass(frozen=True)
class AssistantAnswer:
    text: str
    metadata: dict[str, str] = field(default_factory=dict)


class AssistantModel(Protocol):
    def answer(self, context: AssistantContext, question: str) -> AssistantAnswer: ...


class UnconfiguredAssistantModel:
    """Fails loudly rather than inventing a recipe."""

    def answer(self, context: AssistantContext, question: str) -> AssistantAnswer:
        raise Unavailable(detail="assistant model is not configured")


class FakeAssistantModel:
    """Deterministic test double. Records what it was asked, mutates nothing."""

    def __init__(self, text: str = "Simmer until the sauce coats the paneer.") -> None:
        self.text = text
        self.calls = 0
        self.last_context: AssistantContext | None = None
        self.last_question: str | None = None

    def answer(self, context: AssistantContext, question: str) -> AssistantAnswer:
        self.calls += 1
        self.last_context = context
        self.last_question = question
        return AssistantAnswer(text=self.text)


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
        # The user got nothing, so it must not count against them.
        _release(session, uid=uid, day=day)
        raise

    return AssistantResponse(answer=answer.text, remaining=max(0, deps.daily_cap - used))


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
    """Increment-and-check in one statement, so two requests cannot both win."""
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
            raise UsageCapExceeded(detail=f"daily assistant limit of {cap} reached")

        try:
            session.add(AssistantUsage(user_id=uid, day=day, count=1))
            session.commit()
            return 1
        except IntegrityError:
            # Another request created today's row between UPDATE and INSERT.
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
