"""The import pipeline.

State machine, exactly as stored and nowhere else::

    queued ──▶ extracting ──▶ ready
                     └──────▶ failed

Guarantees this module exists to provide:

* **A hard 60-second budget.** Monotonic, checked between stages, and passed
  into every interface so an implementation can abort its own I/O.
* **Caption first.** If the creator typed quantities, we structure the caption
  and never start ASR. That is both cheaper and usually more accurate.
* **A rolling breaker.** When the last N jobs succeed less than 60% of the
  time, the expensive path is skipped and jobs degrade to caption-only.
* **No persisted media.** Audio is written inside a ``TemporaryDirectory`` that
  is removed in a ``finally``, on every path including failure and timeout.

The worker is deliberately synchronous and single-job: retries, concurrency and
lease renewal belong to the queue (or a process supervisor), not here.
"""

import logging
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, Any

from pydantic import ValidationError
from sqlalchemy import or_, select, update
from sqlalchemy.orm import Session

from ..db import session_scope
from ..domain.captions import has_quantities
from ..domain.clock import Deadline
from ..domain.errors import PipelineError
from ..models import ImportJob
from ..schemas import ProsePayload, RecipePayload
from .. import content as content_service

if TYPE_CHECKING:  # pragma: no cover
    from ..container import AppContext

log = logging.getLogger(__name__)

# The hard ceiling. Configuration may shorten it, never lengthen it: a 60 second
# budget that a config flag can turn into ten minutes is not a budget.
BUDGET_SECONDS = 60.0

EXTRACTION_VERSION = 1

READY = "ready"
FAILED = "failed"
QUEUED = "queued"
EXTRACTING = "extracting"


@dataclass(frozen=True)
class ClaimedJob:
    id: str
    shortcode: str
    source_url: str


@dataclass(frozen=True)
class PipelineResult:
    job_id: str
    state: str
    reason: str | None = None
    mode: str | None = None


class ImportWorker:
    def __init__(self, ctx: "AppContext") -> None:
        self.ctx = ctx

    # ---- public ----------------------------------------------------------

    def process(self, job_id: str) -> PipelineResult:
        claimed = self._claim(job_id)
        if claimed is None:
            # Not queued: already done, cancelled, or picked up by someone else.
            return PipelineResult(job_id=job_id, state="skipped")

        deadline = Deadline(min(self.ctx.settings.import_budget_seconds, BUDGET_SECONDS))

        try:
            return self._run(claimed, deadline)
        except PipelineError as exc:
            return self._fail(claimed.id, exc.reason, detail=exc.detail)
        except ValidationError as exc:
            log.warning("import %s produced an invalid recipe: %s", claimed.id, exc)
            return self._fail(claimed.id, "invalid_recipe")
        except Exception:  # noqa: BLE001 - a job must never kill the worker loop
            log.exception("import %s crashed", claimed.id)
            return self._fail(claimed.id, "internal_error")

    # ---- stages ----------------------------------------------------------

    def _run(self, job: ClaimedJob, deadline: Deadline) -> PipelineResult:
        settings = self.ctx.settings
        deadline.check("start")

        # Everything under here is transient. TemporaryDirectory removes it even
        # if the process raises, which is the whole point.
        with tempfile.TemporaryDirectory(
            prefix=f"shoku-{job.shortcode}-", dir=settings.media_tmp_dir or None
        ) as tmp:
            workdir = Path(tmp)

            extraction = self.ctx.extractor.extract(job.source_url, workdir, deadline)
            deadline.check("extract")

            with session_scope(self.ctx.session_factory) as session:
                taken_down = content_service.is_taken_down(session, job.shortcode)
            if taken_down:
                raise PipelineError(reason="taken_down", detail="content was taken down")

            caption = (extraction.caption or "").strip()
            breaker_open = self._breaker_open()

            transcript = (extraction.transcript or "").strip()

            if has_quantities(caption):
                mode = "caption_first"
                text = caption
                self._set_stage(job.id, "structuring")
            elif transcript:
                # YouTube almost always publishes captions. Using them skips
                # the download, the model and the 60s budget entirely.
                mode = "subtitles"
                text = transcript
                self._set_stage(job.id, "structuring")
            elif breaker_open:
                # Degraded: no ASR. It is caption or nothing.
                if not caption:
                    raise PipelineError(
                        reason="caption_only_degraded",
                        detail="breaker open and the caption is empty",
                    )
                mode = "caption_only_degraded"
                text = caption
                self._set_stage(job.id, "caption_only")
            else:
                if extraction.audio_path is None:
                    raise PipelineError(
                        reason="no_audio", detail="extractor returned no audio"
                    )
                self._set_stage(job.id, "transcribing")
                text = self.ctx.transcriber.transcribe(extraction.audio_path, deadline)
                deadline.check("transcribe")
                mode = "transcript"
                self._set_stage(job.id, "structuring")

            deadline.check("structure")
            raw: dict[str, Any] = self.ctx.structurer.structure(
                text, caption_first=(mode != "transcript")
            )
            recipe = RecipePayload.model_validate(raw)
            prose = _build_prose(recipe, caption, extraction.creator)

            self._persist(
                job,
                recipe=recipe,
                prose=prose,
                creator=extraction.creator,
                source_url=extraction.source_url or job.source_url,
            )
            return PipelineResult(job_id=job.id, state=READY, mode=mode)

    def _persist(
        self,
        job: ClaimedJob,
        *,
        recipe: RecipePayload,
        prose: ProsePayload,
        creator: str | None,
        source_url: str,
    ) -> None:
        with session_scope(self.ctx.session_factory) as session:
            row = session.get(ImportJob, job.id)
            if row is None:
                return
            if row.state != EXTRACTING:
                # Cancelled while we were working. A cancel wins over a result.
                return
            if content_service.is_taken_down(session, job.shortcode):
                raise PipelineError(reason="taken_down", detail="content was taken down")

            content_service.store_extraction(
                session,
                shortcode=job.shortcode,
                recipe=recipe,
                prose=prose,
                creator=creator,
                source_url=source_url,
                extraction_version=EXTRACTION_VERSION,
                clock=self.ctx.clock,
                overwrite=False,
            )
            row.state = READY
            row.reason = None
            row.progress_stage = "ready"
            row.updated_at = self.ctx.clock.now()

    # ---- plumbing --------------------------------------------------------

    def _claim(self, job_id: str) -> ClaimedJob | None:
        now = self.ctx.clock.now()
        with session_scope(self.ctx.session_factory) as session:
            result = session.execute(
                update(ImportJob)
                .where(ImportJob.id == job_id, ImportJob.state == QUEUED)
                .values(
                    state=EXTRACTING,
                    reason=None,
                    progress_stage="extracting",
                    updated_at=now,
                )
            )
            if result.rowcount == 0:
                return None
            job = session.get(ImportJob, job_id)
            if job is None:  # pragma: no cover - row vanished between statements
                return None
            return ClaimedJob(
                id=job.id, shortcode=job.shortcode, source_url=job.source_url
            )

    def _set_stage(self, job_id: str, stage: str) -> None:
        with session_scope(self.ctx.session_factory) as session:
            session.execute(
                update(ImportJob)
                .where(ImportJob.id == job_id, ImportJob.state == EXTRACTING)
                .values(progress_stage=stage, updated_at=self.ctx.clock.now())
            )

    def _fail(self, job_id: str, reason: str, detail: str | None = None) -> PipelineResult:
        if detail:
            log.warning("import %s failed: %s (%s)", job_id, reason, detail)
        with session_scope(self.ctx.session_factory) as session:
            result = session.execute(
                update(ImportJob)
                .where(ImportJob.id == job_id, ImportJob.state == EXTRACTING)
                .values(
                    state=FAILED,
                    reason=reason,
                    progress_stage="failed",
                    updated_at=self.ctx.clock.now(),
                )
            )
            if result.rowcount == 0:
                row = session.get(ImportJob, job_id)
                return PipelineResult(
                    job_id=job_id, state=row.state if row else "missing", reason=reason
                )
        return PipelineResult(job_id=job_id, state=FAILED, reason=reason)

    def _breaker_open(self) -> bool:
        breaker = self.ctx.breaker
        with session_scope(self.ctx.session_factory) as session:
            states = session.scalars(
                select(ImportJob.state)
                .where(
                    ImportJob.state.in_((READY, FAILED)),
                    # A cancellation is not a failure of the pipeline.
                    or_(ImportJob.reason.is_(None), ImportJob.reason != "cancelled"),
                )
                .order_by(ImportJob.updated_at.desc())
                .limit(breaker.window)
            ).all()
        # Query is newest-first; the breaker wants oldest-first.
        return breaker.evaluate([s == READY for s in reversed(states)]).open


def _build_prose(recipe: RecipePayload, caption: str, creator: str | None) -> ProsePayload:
    """Display-only text. Never parsed, never merged into the recipe."""
    if caption:
        summary = caption[:1200]
    else:
        summary = (
            f"{recipe.title}: {recipe.servings} servings, about {recipe.minutes} minutes."
        )
    note = ""
    if creator:
        note = (
            f"Imported from {creator}. The structured recipe is an extraction, "
            "not the creator's exact words."
        )
    return ProsePayload(summary=summary, creator_note=note[:600])
