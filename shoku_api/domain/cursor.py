"""Opaque pull cursors.

Rendered as a single URL-safe string so the client never has to reason about
pagination internals. Internally it is a per-table keyset
``(change_time, id)`` — timestamps tie often enough (bulk sync) that a bare
timestamp cursor silently drops rows.
"""

import base64
import binascii
import json
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

TABLES = ("dishes", "versions", "cook_logs")


@dataclass(frozen=True)
class TableKey:
    changed_at: datetime
    row_id: str


@dataclass(frozen=True)
class Cursor:
    keys: dict[str, TableKey] = field(default_factory=dict)

    def for_table(self, table: str) -> TableKey | None:
        return self.keys.get(table)


def encode_cursor(cursor: Cursor) -> str:
    payload = {
        "v": 1,
        "k": {
            table: [key.changed_at.astimezone(timezone.utc).isoformat(), key.row_id]
            for table, key in cursor.keys.items()
        },
    }
    raw = json.dumps(payload, separators=(",", ":")).encode()
    return base64.urlsafe_b64encode(raw).decode().rstrip("=")


def decode_cursor(raw: str | None) -> Cursor:
    if not raw:
        return Cursor()
    try:
        padded = raw + "=" * (-len(raw) % 4)
        payload: dict[str, Any] = json.loads(base64.urlsafe_b64decode(padded))
    except (ValueError, binascii.Error, json.JSONDecodeError) as exc:
        raise ValueError("malformed cursor") from exc

    if payload.get("v") != 1:
        raise ValueError("unsupported cursor version")

    keys: dict[str, TableKey] = {}
    for table, value in (payload.get("k") or {}).items():
        if table not in TABLES:
            continue
        timestamp, row_id = value
        parsed = datetime.fromisoformat(timestamp)
        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=timezone.utc)
        keys[table] = TableKey(changed_at=parsed, row_id=str(row_id))
    return Cursor(keys=keys)
