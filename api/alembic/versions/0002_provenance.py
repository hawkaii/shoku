"""provenance: thumbnail, platform, creator handle, structuring model

An imported dish should look like it came from a person, not a feed. That means
keeping three facts we were throwing away at extraction time: the reel's own
cover image, the platform, and the creator's handle (as opposed to their display
name, which we already stored).

``structuring_model`` records which model parsed a row. Imports are immutable,
so this stays a fact about that row even after the default model changes — a
dish imported by the heuristic should not later claim a model read it.

Revision ID: 0002_provenance
Revises: 0001_initial
Create Date: 2026-10-31
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0002_provenance"
down_revision: str | None = "0001_initial"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column("content_cache", sa.Column("creator_handle", sa.String(200), nullable=True))
    op.add_column("content_cache", sa.Column("platform", sa.String(32), nullable=True))
    op.add_column("content_cache", sa.Column("thumbnail_url", sa.String(2048), nullable=True))
    op.add_column("content_cache", sa.Column("structuring_model", sa.String(64), nullable=True))

    op.add_column("recipe_versions", sa.Column("origin_handle", sa.String(200), nullable=True))
    op.add_column("recipe_versions", sa.Column("origin_platform", sa.String(32), nullable=True))


def downgrade() -> None:
    op.drop_column("recipe_versions", "origin_platform")
    op.drop_column("recipe_versions", "origin_handle")
    op.drop_column("content_cache", "structuring_model")
    op.drop_column("content_cache", "thumbnail_url")
    op.drop_column("content_cache", "platform")
    op.drop_column("content_cache", "creator_handle")
