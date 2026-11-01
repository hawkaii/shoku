"""Application factory.

`create_app` takes everything it needs as arguments so tests can build an app
with fake interfaces and an in-memory database. `asgi.py` is the only module
with import-time side effects, and it is the uvicorn target.
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from . import __version__
from .routes import v1
from .routes.health import router as health_router
from .config import Settings
from .container import AppContext, build_context
from .domain.errors import ShokuError
from .models import Base


def create_app(
    settings: Settings | None = None,
    *,
    ctx: AppContext | None = None,
    create_tables: bool = True,
) -> FastAPI:
    settings = settings or Settings()
    context = ctx or build_context(settings)

    if create_tables:
        # Convenience for dev and tests. A deployed environment runs Alembic.
        Base.metadata.create_all(context.engine)

    app = FastAPI(
        title="Shoku API",
        version=__version__,
        docs_url="/docs" if settings.environment != "prod" else None,
    )
    app.state.ctx = context

    # The Flutter web build runs in a browser, so every call carries an Origin
    # and the browser blocks the response without these headers. Native builds
    # send no Origin and are unaffected.
    if settings.cors_origins:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.cors_origins,
            allow_credentials=False,
            allow_methods=["GET", "POST", "DELETE", "OPTIONS"],
            allow_headers=["authorization", "content-type"],
        )

    # /health at the root, plus the /v1 group.
    app.include_router(health_router)
    app.include_router(v1)

    @app.exception_handler(ShokuError)
    async def _shoku_error(_request: Request, exc: ShokuError) -> JSONResponse:
        return JSONResponse(
            status_code=exc.http_status,
            content={"error": exc.reason, "detail": exc.detail, **exc.extra},
        )

    return app
