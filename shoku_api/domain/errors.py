"""Domain errors shared by services and the worker.

Each carries a stable ``reason`` code because these end up in API responses and
in ``import_jobs.reason``; a stack trace is not a reason.
"""


class ShokuError(Exception):
    """Base for errors that map to a client-visible outcome."""

    reason = "error"
    http_status = 400

    def __init__(self, reason: str | None = None, detail: str | None = None) -> None:
        if reason is not None:
            self.reason = reason
        self.detail = detail or self.reason
        super().__init__(self.detail)


class UnsupportedUrl(ShokuError):
    reason = "unsupported_url"
    http_status = 422


class NotFound(ShokuError):
    reason = "not_found"
    http_status = 404


class Gone(ShokuError):
    """Content existed and was deliberately removed. Do not retry."""

    reason = "gone"
    http_status = 410


class Unauthenticated(ShokuError):
    """No usable identity. Distinct from "not configured", which is a 503."""

    reason = "unauthenticated"
    http_status = 401


class Forbidden(ShokuError):
    reason = "forbidden"
    http_status = 403


class Conflict(ShokuError):
    reason = "conflict"
    http_status = 409


class UsageCapExceeded(ShokuError):
    reason = "daily_cap_reached"
    http_status = 429


class Unavailable(ShokuError):
    """An external capability is not configured in this deployment."""

    reason = "not_configured"
    http_status = 503


# ---- pipeline failures ----------------------------------------------------


class PipelineError(ShokuError):
    """A job-level failure; lands in ``import_jobs.reason``."""

    reason = "pipeline_error"


class BudgetExceeded(PipelineError):
    reason = "timeout"


class ExtractionFailed(PipelineError):
    reason = "extraction_failed"


class TranscriptionFailed(PipelineError):
    reason = "transcription_failed"


class StructuringFailed(PipelineError):
    reason = "invalid_recipe"


class ContentTakenDown(PipelineError):
    reason = "taken_down"
