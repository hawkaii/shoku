"""pantry: the first mutable synced table

Every other synced list is append-only, so a row that already exists is never
rewritten. The pantry is different: a quantity changes, an alias gets added, an
item is used up. So the merge rule is last-write-wins on ``updated_at`` with a
server-side skew guard, and a removal is a tombstone rather than a delete —
otherwise the other device would never hear about it.

``quantity`` is nullable: "have it, don't know how much" is a real state, and
null never counts as an amount. ``source`` is where the item first came from and
is not editable, which is why it travels on the wire but is read-only in the app.

Revision ID: 0007_pantry
Revises: 0006_assistant_asks
Create Date: 2026-11-02
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0007_pantry"
down_revision: str | None = "0006_assistant_asks"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "pantry_items",
        sa.Column("id", sa.String(length=64), primary_key=True),
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("name", sa.String(length=200), nullable=False),
        # Nullable: an item you have but have not measured is still stock.
        sa.Column("quantity", sa.Float(), nullable=True),
        sa.Column("unit", sa.String(length=16), nullable=True),
        sa.Column("aliases", sa.JSON(), nullable=False),
        sa.Column("wanted", sa.Boolean(), nullable=False),
        sa.Column("source", sa.String(length=16), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.Column("deleted_at", sa.DateTime(), nullable=True),
        sa.Column("server_received_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_pantry_user_updated", "pantry_items", ["user_id", "updated_at"])
    op.create_index(
        "ix_pantry_user_received", "pantry_items", ["user_id", "server_received_at"]
    )


def downgrade() -> None:
    op.drop_index("ix_pantry_user_received", table_name="pantry_items")
    op.drop_index("ix_pantry_user_updated", table_name="pantry_items")
    op.drop_table("pantry_items")
