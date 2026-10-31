"""version tags: the extraction's labels, carried onto the version

``recipe_versions`` gains ``tags``. A version belongs to the user, but the
labels come from the extraction that produced it, so the app can say a recipe
was *seen* ("from video") rather than *stated*. Without this the fact is
recorded only in the cache, which the client never syncs.

Additive and defaulted: every version already stored gets an empty list, and a
client that omits the field still pushes. Nothing is re-parsed — tags are
written by the client on its next import, not by the extractor.

Revision ID: 0005_version_tags
Revises: 0004_shared
Create Date: 2026-10-31
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0005_version_tags"
down_revision: str | None = "0004_shared"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "recipe_versions",
        sa.Column("tags", sa.JSON(), nullable=False, server_default=sa.text("'[]'")),
    )


def downgrade() -> None:
    op.drop_column("recipe_versions", "tags")
