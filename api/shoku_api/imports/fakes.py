"""Fakes for every external stage of the pipeline.

These live in the package rather than in ``tests/`` on purpose: they are the
reference implementation of each interface, the thing a new real adapter is
compared against, and they let the import pipeline be exercised end-to-end
offline.
"""

from pathlib import Path
from typing import Any

from ..domain.clock import Deadline
from ..domain.errors import ExtractionFailed
from .interfaces import Extraction

DEFAULT_CAPTION = "250 g paneer, 2 tbsp butter, 100 ml cream — simmer for 20 minutes."


def recipe(**overrides: Any) -> dict[str, Any]:
    """A valid ``RecipePayload`` as a plain dict, ready for a structurer."""
    payload: dict[str, Any] = {
        "title": "Paneer butter masala",
        "servings": 3,
        "minutes": 35,
        "kcal": 420,
        "protein": 18,
        "ingredients": [
            {"name": "paneer", "amount": "250 g", "grams": 250},
            {"name": "butter", "amount": "2 tbsp"},
            {"name": "cream", "amount": "100 ml"},
        ],
        "steps": ["Fry the paneer.", "Simmer the gravy for 20 minutes."],
        "tags": ["weeknight"],
    }
    payload.update(overrides)
    return payload


class FakeExtractor:
    """Writes a dummy audio file into the workdir and returns a rich caption."""

    def __init__(
        self,
        *,
        caption: str = DEFAULT_CAPTION,
        creator: str | None = "@ravi",
        with_audio: bool = True,
        with_video: bool = True,
        thumbnail: str | None = None,
        fail: bool = False,
    ) -> None:
        self.caption = caption
        self.creator = creator
        self.with_audio = with_audio
        self.with_video = with_video
        self.thumbnail = thumbnail
        self.fail = fail
        self.calls = 0
        self.audio_path: Path | None = None
        self.workdir: Path | None = None

    def extract(self, url: str, workdir: Path, deadline: Deadline) -> Extraction:
        self.calls += 1
        self.workdir = workdir
        if self.fail:
            raise ExtractionFailed(detail="fake extractor was told to fail")
        audio: Path | None = None
        if self.with_audio:
            audio = workdir / "audio.m4a"
            audio.write_bytes(b"\x00fake-audio")
            self.audio_path = audio
        video: Path | None = None
        if self.with_video:
            video = workdir / "media.mp4"
            video.write_bytes(b"\x00fake-video")
        return Extraction(
            caption=self.caption,
            creator=self.creator,
            source_url=url,
            thumbnail_url=self.thumbnail,
            audio_path=audio,
            video_path=video,
        )


class ScriptedExtractor(FakeExtractor):
    """Unusable caption and no audio: forces the transcription or degrade path."""

    def __init__(self, **kwargs: Any) -> None:
        kwargs.setdefault("caption", "vibes only, no quantities here at all, just a nice reel")
        kwargs.setdefault("with_audio", True)
        super().__init__(**kwargs)


class FakeTranscriber:
    def __init__(self, text: str = "Fry 200 g paneer in 2 tbsp butter, then simmer.") -> None:
        self.text = text
        self.calls = 0
        self.warmed = 0
        self.audio_seen: list[Path] = []

    def warm(self) -> None:
        self.warmed += 1

    def transcribe(self, audio_path: Path, deadline: Deadline) -> str:
        self.calls += 1
        self.audio_seen.append(audio_path)
        if not audio_path.exists():
            raise AssertionError("audio was deleted before transcription ran")
        return self.text


class FakeStructurer:
    def __init__(self, payload: dict[str, Any] | None = None) -> None:
        self.payload = payload if payload is not None else recipe()
        self.calls = 0
        self.texts: list[str] = []
        self.caption_first: list[bool] = []

    def structure(self, text: str, *, caption_first: bool) -> dict[str, Any]:
        self.calls += 1
        self.texts.append(text)
        self.caption_first.append(caption_first)
        return dict(self.payload)


class FakeVision:
    """Stands in for the frame reader, so the pipeline can be tested offline."""

    name = "fake-vision"

    def __init__(self, result: dict | None = None) -> None:
        self.result = result or {
            "title": "Read from the video",
            "servings": 2,
            "minutes": 20,
            "kcal": 0,
            "protein": 0,
            "ingredients": [{"name": "paneer", "amount": "200 g", "grams": 200}],
            "steps": ["Fry the paneer"],
            "tags": [],
        }
        self.calls = 0
        self.frames_seen: list[Path] = []
        self.hint = ""

    def structure_frames(self, frames, *, hint: str = "") -> dict:
        self.calls += 1
        self.frames_seen = list(frames)
        self.hint = hint
        return self.result
