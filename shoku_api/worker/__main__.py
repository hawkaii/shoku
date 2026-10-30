"""Worker entry point: `python -m shoku_api.worker`.

This is a VPS process on purpose — the extractor needs ffmpeg and a residential
proxy, so it is not a serverless job. It dequeues forever, one job at a time
(`concurrency = 1` keeps a pathological reel from starving the API box).
"""

from __future__ import annotations

import logging
import signal
import sys

from ..config import Settings
from ..container import build_context
from ..models import Base
from .pipeline import ImportWorker

log = logging.getLogger("shoku.worker")


def main() -> int:
    logging.basicConfig(
        level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s %(message)s"
    )
    settings = Settings()
    ctx = build_context(settings)
    Base.metadata.create_all(ctx.engine)
    worker = ImportWorker(ctx)

    stopping = False

    def _stop(signum, _frame):
        nonlocal stopping
        stopping = True
        log.info("stop requested (signal %s), finishing the current job", signum)

    signal.signal(signal.SIGTERM, _stop)
    signal.signal(signal.SIGINT, _stop)

    log.info("worker up (queue=%s)", settings.queue_backend)
    while not stopping:
        job_id = ctx.queue.dequeue(timeout=5.0)
        if job_id is None:
            continue
        result = worker.process(job_id)
        log.info("job %s -> %s", result.job_id, result.state)

    log.info("worker down")
    return 0


if __name__ == "__main__":
    sys.exit(main())
