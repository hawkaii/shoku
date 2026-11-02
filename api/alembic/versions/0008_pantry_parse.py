"""pantry parse: a second metered endpoint, and its own daily counter

Ten receipts a day and twenty conversations a day are different budgets, so the
parse gets its own counter rather than sharing the assistant's. Reusing one
number would let a photo of a shopping bag spend the allowance for questions
about a recipe.

Two tables, the same shape as the assistant's: a counter that is incremented and
checked in one statement, and a row per ``request_id`` that makes a retry free.

Revision ID: 0008_pantry_parse
Revises: 0007_pantry
Create Date: 2026-11-02
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0008_pantry_parse"
down_revision: str | None = "0007_pantry"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "pantry_parse_usage",
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("day", sa.Date(), nullable=False),
        sa.Column("count", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "day"),
    )
    op.create_table(
        "pantry_parse_requests",
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("request_id", sa.String(length=64), nullable=False),
        sa.Column("day", sa.Date(), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "request_id"),
    )
    op.create_index(
        "ix_pantry_parse_asks_user_day", "pantry_parse_requests", ["user_id", "day"]
    )


def downgrade() -> None:
    op.drop_index("ix_pantry_parse_asks_user_day", table_name="pantry_parse_requests")
    op.drop_table("pantry_parse_requests")
    op.drop_table("pantry_parse_usage")
