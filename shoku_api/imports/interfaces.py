"""Contracts for the three unreliable stages of extraction.

Each is a Protocol so the pipeline can be exercised end-to-end with fakes and
no network, no ffmpeg and no model provider. Real implementations are wired in
one place (``shoku_api.container``), which is also where a deployment without
credentials fails loudly instead of silently returning junk.

Audio is transient by design: ``Extraction.audio_path`` must live inside the
``workdir`` the pipeline hands in, and the pipeline deletes that directory
before the job leaves ``extracting``.
"""

from dataclasses import dataclass
from pathlib import Path
from typing import Any, Protocol

from ..domain.clock import Deadline
from ..domain.errors import ExtractionFailed, StructuringFailed, TranscriptionFailed


@dataclass(frozen=True)
class Extraction:
    """What the media fetch produced. Everything except audio is metadata."""

    caption: str = ""
    #: Spoken words already published by the platform (YouTube subtitles).
    #: When present this replaces ASR entirely — same stage, free and faster.
    transcript: str = ""
    #: Pinned / first comment. Creators put the real quantities there when the
    #: caption is truncated, so it is a first-class text source, not a fallback.
    comment: str = ""
    creator: str | None = None
    #: "@handle" rather than the display name; what the dish should attribute.
    creator_handle: str | None = None
    platform: str | None = None
    #: The platform's own cover image, when it exposes one.
    thumbnail_url: str | None = None
    source_url: str = ""
    audio_path: Path | None = None
    #: The video itself, when it was downloaded. Speech recognition can use it,
    #: and a silent reel can still be read by sampling frames from it.
    video_path: Path | None = None
    duration_seconds: float | None = None


class Extractor(Protocol):
    def extract(self, url: str, workdir: Path, deadline: Deadline) -> Extraction: ...


class Transcriber(Protocol):
    def transcribe(self, audio_path: Path, deadline: Deadline) -> str: ...

    def warm(self) -> None:
        """Get ready before a job exists.

        A real transcriber loads a model; doing that lazily puts the download
        inside the first import's budget, where the deadline kills the job and
        the next attempt starts over.
        """
        ...


class Structurer(Protocol):
    def structure(self, text: str, *, caption_first: bool) -> dict[str, Any]: ...


class UnconfiguredExtractor:
    """No media fetcher is wired into this deployment.

    Fails the job with a stable reason rather than pretending an empty caption
    is an extraction.
    """

    def extract(self, url: str, workdir: Path, deadline: Deadline) -> Extraction:
        raise ExtractionFailed(detail="extractor is not configured")


class UnconfiguredTranscriber:
    def transcribe(self, audio_path: Path, deadline: Deadline) -> str:
        raise TranscriptionFailed(detail="transcriber is not configured")

    def warm(self) -> None:
        # Nothing to load. The failure belongs to the job, where the reason
        # field can carry it, not to startup.
        return None


class UnconfiguredStructurer:
    def structure(self, text: str, *, caption_first: bool) -> dict[str, Any]:
        raise StructuringFailed(detail="structurer is not configured")
