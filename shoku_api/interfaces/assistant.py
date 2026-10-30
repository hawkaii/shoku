"""The scoped assistant.

Scope is the whole safety story: the model is handed one dish's own text and
the user's question, and it returns an answer. It has no write path — the
service that calls it cannot mutate recipes, by construction.
"""

from dataclasses import dataclass, field
from typing import Protocol

from ..domain.errors import Unavailable


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
