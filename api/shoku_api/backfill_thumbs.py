"""Copy the cover of every cached reel into our storage, once.

    python -m shoku_api.backfill_thumbs --dry-run
    python -m shoku_api.backfill_thumbs

Rows written before covers were copied point at a platform CDN link that has
almost certainly expired. This walks them and rewrites ``thumbnail_url`` to the
copy we hold.

Idempotent by construction: a row already pointing at ``/thumbs/`` is skipped,
and the object key is the SHA-256 of the bytes, so re-copying the same cover
overwrites one object rather than accumulating copies. A row whose platform
image is genuinely gone is skipped, not failed — the client monograms it either
way, and a dead link costs nothing to keep.

A taken-down row is left alone: its payload is erased and it is invisible, so
copying an image for it would be work nobody can see.
"""

import argparse
import sys

from sqlalchemy import select

from .config import get_settings
from .container import build_context
from .models import ContentCache
from .thumbnails import stable_cover

#: Anything under this marker is a copy we made, never a platform link.
_OURS = "/thumbs/"


def is_ours(url: str | None) -> bool:
    return bool(url) and _OURS in str(url)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Copy cached reel covers into our storage.")
    parser.add_argument("--dry-run", action="store_true", help="report, change nothing")
    parser.add_argument("--limit", type=int, default=0, help="stop after N rows")
    args = parser.parse_args(argv)

    settings = get_settings()
    ctx = build_context(settings)
    storage = ctx.storage

    if not getattr(storage, "can_store", False):
        print(
            "storage is not configured on this host "
            "(set SHOKU_STORAGE_BACKEND=r2 and the R2 credentials); nothing to do",
            file=sys.stderr,
        )
        return 2

    copied = skipped = dead = 0
    with ctx.session_factory() as session:
        rows = list(
            session.scalars(
                select(ContentCache)
                .where(
                    ContentCache.structured_json.isnot(None),
                    ContentCache.deleted_at.is_(None),
                )
                .order_by(ContentCache.created_at.asc())
            ).all()
        )
        if args.limit:
            rows = rows[: args.limit]

        for row in rows:
            if not row.thumbnail_url or is_ours(row.thumbnail_url):
                skipped += 1
                continue
            stable = stable_cover(storage, row.thumbnail_url, shortcode=row.shortcode)
            if stable is None:
                dead += 1
                print(f"{row.shortcode}: no copy (source gone); left as it was")
                continue
            if not args.dry_run:
                row.thumbnail_url = stable
                session.commit()
            copied += 1
            print(f"{row.shortcode}: {stable}")

    verb = "would copy" if args.dry_run else "copied"
    print(f"{verb} {copied}, skipped {skipped} (already ours or no source), {dead} dead")
    return 0


if __name__ == "__main__":  # pragma: no cover - module entry point
    raise SystemExit(main())
