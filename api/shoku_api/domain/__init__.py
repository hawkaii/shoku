"""Pure domain logic: URL shapes, captions, cursors, budgets, the breaker."""

from .breaker import BreakerSnapshot, CircuitBreaker
from .clock import Clock, Deadline, FixedClock, SystemClock, utcnow
from .errors import (
    BudgetExceeded,
    Conflict,
    ContentTakenDown,
    ExtractionFailed,
    Forbidden,
    Gone,
    NotFound,
    PipelineError,
    ShokuError,
    StructuringFailed,
    TranscriptionFailed,
    Unavailable,
    UnsupportedUrl,
    UsageCapExceeded,
)
from .urls import NormalisedSource, normalise_url

__all__ = [
    "BreakerSnapshot",
    "BudgetExceeded",
    "CircuitBreaker",
    "Clock",
    "Conflict",
    "ContentTakenDown",
    "Deadline",
    "ExtractionFailed",
    "FixedClock",
    "Forbidden",
    "Gone",
    "NormalisedSource",
    "NotFound",
    "PipelineError",
    "ShokuError",
    "StructuringFailed",
    "SystemClock",
    "TranscriptionFailed",
    "Unavailable",
    "UnsupportedUrl",
    "UsageCapExceeded",
    "normalise_url",
    "utcnow",
]
