"""The migration must produce the schema the models describe.

A mismatch here is the classic "works on a fresh test database, fails on a
migrated one" bug, so the check runs in CI rather than in someone's head.
"""

from pathlib import Path

from alembic import command
from alembic.config import Config
from sqlalchemy import create_engine, inspect

from shoku_api.config import get_settings
from shoku_api.models import Base

ROOT = Path(__file__).resolve().parents[1]


def test_alembic_initial_migration_matches_the_models(tmp_path, monkeypatch) -> None:
    database = tmp_path / "migrated.db"
    monkeypatch.setenv("SHOKU_DATABASE_URL", f"sqlite:///{database}")
    get_settings.cache_clear()

    config = Config(str(ROOT / "alembic.ini"))
    config.set_main_option("script_location", str(ROOT / "alembic"))

    command.upgrade(config, "head")

    engine = create_engine(f"sqlite:///{database}")
    tables = set(inspect(engine).get_table_names())
    assert set(Base.metadata.tables) <= tables
    engine.dispose()

    # Autogenerate finds no difference between the migrated schema and the
    # models; anything else means the migration is stale.
    command.check(config)
