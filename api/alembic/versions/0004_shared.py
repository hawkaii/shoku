"""shared: the Wall publishes an extraction, never a user's work

``content_cache`` gains ``shared``, which starts false for every row that
exists and every row that is written. Publishing is an explicit act by a signed
in user, so the column is never set at import and never backfilled — a
convenience that published on insert would put every journal anyone has ever
imported on the Wall at once.

``reported_count`` counts *distinct users*, not requests. The
``content_reports`` row is what enforces that: its composite primary key means
one account cannot unshare anything by tapping repeatedly.

The server default on ``shared`` stays in place after the backfill because it is
what makes the column safe if anything ever writes a row without naming it.

Revision ID: 0004_shared
Revises: 0003_photos
Create Date: 2026-10-31
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0004_shared"
down_revision: str | None = "0003_photos"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "content_cache",
        sa.Column("shared", sa.Boolean(), nullable=False, server_default=sa.false()),
    )
    op.add_column(
        "content_cache",
        sa.Column(
            "reported_count", sa.Integer(), nullable=False, server_default=sa.text("0")
        ),
    )

    op.create_table(
        "content_reports",
        sa.Column("shortcode", sa.String(length=64), nullable=False),
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(
            ["shortcode"], ["content_cache.shortcode"], ondelete="CASCADE"
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("shortcode", "user_id"),
    )
    op.create_index("ix_content_reports_shortcode", "content_reports", ["shortcode"])


def downgrade() -> None:
    op.drop_index("ix_content_reports_shortcode", table_name="content_reports")
    op.drop_table("content_reports")
    op.drop_column("content_cache", "reported_count")
    op.drop_column("content_cache", "shared")
