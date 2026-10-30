"""Rolling-success circuit breaker for the import pipeline.

Extraction is a chain of unreliable third parties (media fetch, ASR, LLM). When
enough recent jobs fail, continuing to try the expensive path burns money and
latency for a result that is probably wrong anyway. The breaker degrades those
jobs to caption-only: cheap, deterministic, and often good enough because
creators usually type the quantities.

Deliberately a pure function over outcomes so the policy can be tested without
a database: the caller supplies the last N terminal jobs, oldest first.
"""

from collections.abc import Sequence
from dataclasses import dataclass


@dataclass(frozen=True)
class BreakerSnapshot:
    samples: int
    successes: int
    success_rate: float | None
    open: bool

    @property
    def degraded(self) -> bool:
        return self.open


class CircuitBreaker:
    def __init__(self, *, window: int = 20, threshold: float = 0.6, min_samples: int = 5):
        if window < 1:
            raise ValueError("window must be >= 1")
        if not 0.0 <= threshold <= 1.0:
            raise ValueError("threshold must be within [0, 1]")
        if min_samples < 1:
            raise ValueError("min_samples must be >= 1")
        self.window = window
        self.threshold = threshold
        self.min_samples = min_samples

    def evaluate(self, outcomes: Sequence[bool]) -> BreakerSnapshot:
        """``outcomes`` is oldest-first; only the last ``window`` count."""
        recent = list(outcomes)[-self.window :]
        samples = len(recent)
        successes = sum(1 for ok in recent if ok)
        rate = (successes / samples) if samples else None

        # Too little history is not evidence. Stay closed.
        open_ = samples >= self.min_samples and rate is not None and rate < self.threshold
        return BreakerSnapshot(
            samples=samples, successes=successes, success_rate=rate, open=open_
        )
