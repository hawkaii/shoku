"""Feed cursors.

Separate from the sync cursor on purpose: sync pages per table on a server
clock, the Wall pages one ordered list on ``(created_at, shortcode)``. Sharing
one format would tie two unrelated paging schemes to the same version number.
"""

import base64
import binascii
import json
from dataclasses import dataclass
from datetime import datetime, timezone


@dataclass(frozen=True)
class FeedPosition:
    created_at: datetime
    #: Tie-break, so a burst of imports sharing one timestamp still pages.
    shortcode: str


def encode_feed_cursor(position: FeedPosition) -> str:
    payload = {
        "v": 1,
        "t": position.created_at.astimezone(timezone.utc).isoformat(),
        "s": position.shortcode,
    }
    raw = json.dumps(payload, separators=(",", ":")).encode()
    return base64.urlsafe_b64encode(raw).decode().rstrip("=")


def decode_feed_cursor(raw: str | None) -> FeedPosition | None:
    if not raw:
        return None
    try:
        padded = raw + "=" * (-len(raw) % 4)
        payload = json.loads(base64.urlsafe_b64decode(padded))
    except (ValueError, binascii.Error, json.JSONDecodeError) as exc:
        raise ValueError("malformed feed cursor") from exc

    if payload.get("v") != 1:
        raise ValueError("unsupported feed cursor version")

    parsed = datetime.fromisoformat(payload["t"])
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return FeedPosition(created_at=parsed, shortcode=str(payload["s"]))
