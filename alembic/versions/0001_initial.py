"""initial schema

Mirrors the drift tables in the Flutter client (snake_case), plus the
server-only columns: ``user_id``, ``server_received_at`` and job/usage tables.
``dirty`` is intentionally absent — it means "not yet pushed", which stops
being true the moment a row is stored here.

Revision ID: 0001_initial
Revises:
Create Date: 2026-10-30
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0001_initial"
down_revision: str | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.String(length=128), primary_key=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
    )

    op.create_table(
        "dishes",
        sa.Column("id", sa.String(length=64), primary_key=True),
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("title", sa.String(length=200), nullable=False),
        sa.Column("subtitle", sa.String(length=400), nullable=False),
        sa.Column("cover_url", sa.String(length=2048), nullable=False),
        sa.Column("source_handle", sa.String(length=200), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("minutes", sa.Integer(), nullable=False),
        sa.Column("baseline_kcal", sa.Integer(), nullable=False),
        sa.Column("baseline_protein", sa.Integer(), nullable=False),
        sa.Column("steps", sa.JSON(), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.Column("deleted_at", sa.DateTime(), nullable=True),
        sa.Column("server_received_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_dishes_user_updated", "dishes", ["user_id", "updated_at"])
    op.create_index("ix_dishes_user_received", "dishes", ["user_id", "server_received_at"])
    op.create_index("ix_dishes_user_deleted", "dishes", ["user_id", "deleted_at"])

    op.create_table(
        "recipe_versions",
        sa.Column("id", sa.String(length=64), primary_key=True),
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("dish_id", sa.String(length=64), nullable=False),
        sa.Column("number", sa.Integer(), nullable=False),
        sa.Column("changes", sa.JSON(), nullable=False),
        sa.Column("ingredients", sa.JSON(), nullable=False),
        sa.Column("steps", sa.JSON(), nullable=False),
        sa.Column("kcal", sa.Integer(), nullable=False),
        sa.Column("protein", sa.Integer(), nullable=False),
        sa.Column("origin_kind", sa.String(length=16), nullable=False),
        sa.Column("origin_creator", sa.String(length=200), nullable=True),
        sa.Column("origin_url", sa.String(length=2048), nullable=True),
        sa.Column("origin_shortcode", sa.String(length=64), nullable=True),
        sa.Column("parent_version_id", sa.String(length=64), nullable=True),
        sa.Column("extraction_version", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("server_received_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["dish_id"], ["dishes.id"], ondelete="CASCADE"),
    )
    op.create_index(
        "ix_versions_user_received", "recipe_versions", ["user_id", "server_received_at"]
    )
    op.create_index("ix_versions_dish", "recipe_versions", ["dish_id"])

    op.create_table(
        "cook_logs",
        sa.Column("id", sa.String(length=64), primary_key=True),
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("dish_id", sa.String(length=64), nullable=False),
        sa.Column("version_id", sa.String(length=64), nullable=True),
        sa.Column("version_number", sa.Integer(), nullable=False),
        sa.Column("cooked_at", sa.DateTime(), nullable=False),
        sa.Column("photo_url", sa.String(length=2048), nullable=False),
        sa.Column("photo_state", sa.String(length=16), nullable=False),
        sa.Column("outcome", sa.String(length=32), nullable=False),
        sa.Column("mood", sa.String(length=32), nullable=False),
        sa.Column("note", sa.String(length=2000), nullable=False),
        sa.Column("changes", sa.JSON(), nullable=False),
        sa.Column("rating", sa.Integer(), nullable=False),
        sa.Column("server_received_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["dish_id"], ["dishes.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_cooks_user_received", "cook_logs", ["user_id", "server_received_at"])
    op.create_index("ix_cooks_dish", "cook_logs", ["dish_id"])

    op.create_table(
        "content_cache",
        sa.Column("shortcode", sa.String(length=64), primary_key=True),
        sa.Column("structured_json", sa.JSON(), nullable=True),
        sa.Column("prose_json", sa.JSON(), nullable=True),
        sa.Column("creator", sa.String(length=200), nullable=True),
        sa.Column("source_url", sa.String(length=2048), nullable=False),
        sa.Column("extraction_version", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("deleted_at", sa.DateTime(), nullable=True),
    )

    op.create_table(
        "import_jobs",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("shortcode", sa.String(length=64), nullable=False),
        sa.Column("source_url", sa.String(length=2048), nullable=False),
        sa.Column("state", sa.String(length=16), nullable=False),
        sa.Column("reason", sa.String(length=200), nullable=True),
        sa.Column("progress_stage", sa.String(length=48), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
    )
    op.create_index(
        "ix_import_jobs_user_created", "import_jobs", ["user_id", "created_at"]
    )
    op.create_index(
        "ix_import_jobs_shortcode_state", "import_jobs", ["shortcode", "state"]
    )
    op.create_index("ix_import_jobs_state_created", "import_jobs", ["state", "created_at"])

    op.create_table(
        "assistant_usage",
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("day", sa.Date(), nullable=False),
        sa.Column("count", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "day"),
    )


def downgrade() -> None:
    op.drop_table("assistant_usage")
    op.drop_table("import_jobs")
    op.drop_table("content_cache")
    op.drop_table("cook_logs")
    op.drop_table("recipe_versions")
    op.drop_table("dishes")
    op.drop_table("users")
