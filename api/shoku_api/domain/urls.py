"""URL normalisation for the import pipeline.

The cache key is the shortcode, so this module is the only place that decides
what a shortcode is. Getting it wrong means either duplicate extractions or,
worse, two different reels sharing one cache entry.
"""

import re
from dataclasses import dataclass
from urllib.parse import parse_qs, urlparse

from .errors import UnsupportedUrl

IG_HOSTS = {"instagram.com", "www.instagram.com", "m.instagram.com", "instagr.am"}
YT_HOSTS = {
    "youtube.com",
    "www.youtube.com",
    "m.youtube.com",
    "music.youtube.com",
    "youtube-nocookie.com",
    "www.youtube-nocookie.com",
    "youtu.be",
}

# Instagram shortcodes are base64-ish and case-sensitive.
_IG_CODE = re.compile(r"^[A-Za-z0-9_-]{5,32}$")
# YouTube ids are exactly 11 characters.
_YT_CODE = re.compile(r"^[A-Za-z0-9_-]{11}$")

_IG_PATHS = ("reel", "reels", "p", "tv")


@dataclass(frozen=True)
class NormalisedSource:
    platform: str  # "instagram" | "youtube"
    shortcode: str
    canonical_url: str


def _host(parsed) -> str:
    return (parsed.hostname or "").lower().rstrip(".")


def normalise_url(raw: str) -> NormalisedSource:
    raw = (raw or "").strip()
    if not raw:
        raise UnsupportedUrl(detail="URL is empty")

    if "://" not in raw:
        raw = "https://" + raw

    parsed = urlparse(raw)
    if parsed.scheme not in ("http", "https"):
        raise UnsupportedUrl(detail=f"unsupported scheme {parsed.scheme!r}")

    host = _host(parsed)
    if host.endswith("instagram.com") or host == "instagr.am":
        return _instagram(parsed)
    if host.endswith("youtube.com") or host.endswith("youtube-nocookie.com") or host == "youtu.be":
        return _youtube(parsed, host)
    raise UnsupportedUrl(detail=f"unsupported host {host!r}")


def _instagram(parsed) -> NormalisedSource:
    parts = [p for p in parsed.path.split("/") if p]
    if len(parts) >= 2 and parts[0] in _IG_PATHS:
        code = parts[1]
    elif len(parts) == 1 and parts[0] not in _IG_PATHS:
        # A bare profile name is not content.
        raise UnsupportedUrl(detail="not a post or reel URL")
    else:
        raise UnsupportedUrl(detail="not a post or reel URL")

    if not _IG_CODE.match(code):
        raise UnsupportedUrl(detail="malformed Instagram shortcode")
    return NormalisedSource(
        platform="instagram",
        shortcode=code,
        canonical_url=f"https://www.instagram.com/reel/{code}/",
    )


def _youtube(parsed, host: str) -> NormalisedSource:
    code: str | None = None

    if host == "youtu.be":
        parts = [p for p in parsed.path.split("/") if p]
        if parts:
            code = parts[0]
    else:
        parts = [p for p in parsed.path.split("/") if p]
        query = parse_qs(parsed.query)
        if parts[:1] == ["watch"]:
            code = (query.get("v") or [None])[0]
        elif len(parts) >= 2 and parts[0] in ("shorts", "embed", "live", "v"):
            code = parts[1]

    if not code or not _YT_CODE.match(code):
        raise UnsupportedUrl(detail="malformed YouTube video id")
    return NormalisedSource(
        platform="youtube",
        shortcode=code,
        canonical_url=f"https://www.youtube.com/watch?v={code}",
    )


def platform_of(raw: str) -> str:
    """Which platform a URL belongs to, without fully normalising it."""
    try:
        return normalise_url(raw).platform
    except Exception:  # noqa: BLE001 - callers treat unknown as generic
        return "unknown"
