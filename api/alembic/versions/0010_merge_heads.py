"""merge the import-limits and voice-usage heads

The stability work added `0009_import_limits` while the hands-free branch added
`0009_voice_usage`; both descend from `0008_pantry_parse`, so upgrading to
`head` used to fail with "multiple head revisions". This revision has two
parents and does nothing itself: it exists so one `upgrade head` applies both.
"""

from __future__ import annotations

revision: str = "0010_merge_heads"
down_revision: tuple[str, str] = ("0009_import_limits", "0009_voice_usage")
branch_labels = None
depends_on = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
