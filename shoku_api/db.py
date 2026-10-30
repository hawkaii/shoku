"""Engine and session plumbing.

SQLite is deliberately kept viable so the whole test suite runs without
Postgres. That costs us two things: no ``JSONB`` (plain ``JSON`` in the shared
model) and a ``UTCDateTime`` decorator, because SQLite has no timezone type.
"""

from collections.abc import Iterator
from contextlib import contextmanager

from sqlalchemy import Engine, create_engine, event
from sqlalchemy.engine import make_url
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from .config import Settings


def _configure_sqlite(dbapi_connection, _record) -> None:
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA foreign_keys = ON")
    cursor.close()


def build_engine(settings: Settings, *, echo: bool = False) -> Engine:
    url = make_url(settings.database_url)
    kwargs: dict = {"echo": echo, "future": True}

    if url.get_backend_name() == "sqlite":
        kwargs["connect_args"] = {"check_same_thread": False}
        if url.database in (None, "", ":memory:"):
            # One shared connection, or every session sees a different empty db.
            kwargs["poolclass"] = StaticPool
    else:
        kwargs["pool_pre_ping"] = True

    engine = create_engine(url, **kwargs)
    if url.get_backend_name() == "sqlite":
        event.listen(engine, "connect", _configure_sqlite)
    return engine


def build_session_factory(engine: Engine) -> sessionmaker[Session]:
    return sessionmaker(bind=engine, expire_on_commit=False, future=True)


@contextmanager
def session_scope(factory: sessionmaker[Session]) -> Iterator[Session]:
    session = factory()
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()
