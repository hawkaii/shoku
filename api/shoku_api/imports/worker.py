"""Worker entry point: `python -m shoku_api.imports.worker`.

The queue owns delivery and retries; this loop owns one job at a time. It stops
on SIGTERM/SIGINT after the job in hand, so a deploy never leaves a job in
``extracting`` with no process behind it.
"""

import logging
import signal
import time
import sys

from ..config import get_settings
from ..container import build_context
from .pipeline import ImportWorker

log = logging.getLogger(__name__)


def _warm(transcriber) -> float:
    """Get the transcriber ready, and say how long it cost.

    Separate from ``main`` so the ordering — warm, then claim — is testable
    without starting a worker.
    """
    started = time.monotonic()
    transcriber.warm()
    return time.monotonic() - started


def main() -> int:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )

    settings = get_settings()
    ctx = build_context(settings)

    # Warm before the first claim. A transcriber that loads its model lazily
    # spends the import budget on a download, the deadline kills the job, and
    # the next attempt starts again from zero — on every cold container.
    log.info("warming the transcriber before claiming any job")
    try:
        elapsed = _warm(ctx.transcriber)
    except Exception:  # noqa: BLE001 - refusing to serve is the safe failure
        log.exception("transcriber warm-up failed; not claiming jobs it cannot serve")
        return 1
    log.info("transcriber warm in %.1fs", elapsed)

    worker = ImportWorker(ctx)

    stopping = False

    def _stop(signum: int, _frame) -> None:
        nonlocal stopping
        log.info("signal %s: finishing the current job, then exiting", signum)
        stopping = True

    signal.signal(signal.SIGTERM, _stop)
    signal.signal(signal.SIGINT, _stop)

    log.info("worker ready (queue=%s)", settings.queue_backend)

    while not stopping:
        try:
            job_id = ctx.queue.dequeue(timeout=5)
        except Exception:  # noqa: BLE001 - a dead queue must not kill the worker
            log.exception("queue read failed; retrying in 2s")
            time.sleep(2)
            continue
        if job_id is None:
            continue
        try:
            result = worker.process(job_id)
        except Exception:  # noqa: BLE001 - one bad job must not kill the worker
            log.exception("job %s crashed", job_id)
            continue
        log.info(
            "job %s -> %s%s",
            result.job_id,
            result.state,
            f" ({result.reason})" if result.reason else "",
        )

    return 0


if __name__ == "__main__":  # pragma: no cover - process entry point
    sys.exit(main())
