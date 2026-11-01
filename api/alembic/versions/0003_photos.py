"""photos: many per version, many per debrief, none of them the dish cover

A photo used to be two columns on ``cook_logs`` — exactly one per cook, which
was wrong on both ends: a version can be photographed several times, and a
debrief is a set, not a frame.

``role`` names the surface, and decides which target column is set: ``version``
hangs off ``recipe_versions``, ``debrief`` off ``cook_logs``. There is
deliberately no ``cover`` role — ``dishes.cover_url`` stays the one source of
truth for the cover, so this table can never disagree with it.

``key`` is the R2 object key under ``photos/<uid>/``. The public URL is derived
from the storage base at read time and is therefore not a column: storing it
would make a bucket move a data migration.

``deleted_at`` is a tombstone. Rows are append-only and their contents never
change; the tombstone is the single mutation they accept, from null, once.

Revision ID: 0003_photos
Revises: 0002_provenance
Create Date: 2026-10-31
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0003_photos"
down_revision: str | None = "0002_provenance"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "photos",
        sa.Column("id", sa.String(length=64), primary_key=True),
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("version_id", sa.String(length=64), nullable=True),
        sa.Column("cook_id", sa.String(length=64), nullable=True),
        sa.Column("role", sa.String(length=16), nullable=False),
        sa.Column("key", sa.String(length=512), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("deleted_at", sa.DateTime(), nullable=True),
        sa.Column("server_received_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["version_id"], ["recipe_versions.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["cook_id"], ["cook_logs.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_photos_user_received", "photos", ["user_id", "server_received_at"])
    op.create_index("ix_photos_version", "photos", ["version_id"])
    op.create_index("ix_photos_cook", "photos", ["cook_id"])


def downgrade() -> None:
    op.drop_index("ix_photos_cook", table_name="photos")
    op.drop_index("ix_photos_version", table_name="photos")
    op.drop_index("ix_photos_user_received", table_name="photos")
    op.drop_table("photos")
