"""assistant asks: one row per metered request_id

The cap counter alone cannot tell a retry from a new ask: a dropped response
makes the client POST again, and the second POST used to spend another unit.
Keying a row on ``(user_id, request_id)`` makes the reservation idempotent — the
retry finds its own row and is free. The row is removed when the model call
fails, so a failed ask leaves no trace and costs nothing.

Revision ID: 0006_assistant_asks
Revises: 0005_version_tags
Create Date: 2026-11-02
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0006_assistant_asks"
down_revision: str | None = "0005_version_tags"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "assistant_asks",
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("request_id", sa.String(length=64), nullable=False),
        sa.Column("day", sa.Date(), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "request_id"),
    )
    op.create_index("ix_assistant_asks_user_day", "assistant_asks", ["user_id", "day"])


def downgrade() -> None:
    op.drop_index("ix_assistant_asks_user_day", table_name="assistant_asks")
    op.drop_table("assistant_asks")
