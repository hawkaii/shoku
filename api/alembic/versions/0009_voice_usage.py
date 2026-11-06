"""voice: the daily speech allowance

Metered from the upstream's ``audioProcessedMs`` rather than from bytes we
forwarded: a client that pauses, or drops and reconnects, must not be charged
twice for the same second of speech. One row per user per UTC day, in
milliseconds, so a partially used minute is not rounded up.

Revision ID: 0009_voice_usage
Revises: 0008_pantry_parse
Create Date: 2026-11-03
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0009_voice_usage"
down_revision: str | None = "0008_pantry_parse"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "voice_usage",
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("day", sa.Date(), nullable=False),
        sa.Column("audio_ms", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "day"),
    )


def downgrade() -> None:
    op.drop_table("voice_usage")
