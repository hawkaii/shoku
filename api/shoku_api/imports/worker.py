"""Worker entry point: `python -m shoku_api.imports.worker`.

The queue owns delivery and retries; this loop owns one job at a time. It stops
on SIGTERM/SIGINT after the job in hand, so a deploy never leaves a job in
``extracting`` with no process behind it.
"""

import logging
import signal
import sys

from ..config import get_settings
from ..container import build_context
from .pipeline import ImportWorker

log = logging.getLogger(__name__)


def main() -> int:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )

    settings = get_settings()
    ctx = build_context(settings)
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
        job_id = ctx.queue.dequeue(timeout=5)
        if job_id is None:
            continue
        result = worker.process(job_id)
        log.info(
            "job %s -> %s%s",
            result.job_id,
            result.state,
            f" ({result.reason})" if result.reason else "",
        )

    return 0


if __name__ == "__main__":  # pragma: no cover - process entry point
    sys.exit(main())
