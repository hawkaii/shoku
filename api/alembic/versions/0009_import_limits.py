"""import limits: a daily allowance for the expensive endpoint

An import boots a worker VM and asks the model to read a video, so it is the one
request whose cost is visible. It gets its own counter and its own idempotency
row, the same shape as the assistant's and the receipt parser's, plus a link on
the job so a job that never ran can hand its unit back.

Numbered ``0009`` with the same parent as the voice migration that is in flight
on another branch; when both land, alembic needs one merge revision.

Revision ID: 0009_import_limits
Revises: 0008_pantry_parse
Create Date: 2026-11-06
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0009_import_limits"
down_revision: str | None = "0008_pantry_parse"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "import_jobs",
        sa.Column("quota_request_id", sa.String(length=64), nullable=True),
    )
    op.create_table(
        "import_usage",
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("day", sa.Date(), nullable=False),
        sa.Column("count", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "day"),
    )
    op.create_table(
        "import_requests",
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("request_id", sa.String(length=64), nullable=False),
        sa.Column("day", sa.Date(), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "request_id"),
    )
    op.create_index(
        "ix_import_requests_user_day", "import_requests", ["user_id", "day"]
    )


def downgrade() -> None:
    op.drop_index("ix_import_requests_user_day", table_name="import_requests")
    op.drop_table("import_requests")
    op.drop_table("import_usage")
    op.drop_column("import_jobs", "quota_request_id")
