from fastapi import APIRouter

from . import assistant, content, feed, imports, pantry, photos, pool, sync, voice
from .health import router as health_router

v1 = APIRouter(prefix="/v1")
v1.include_router(sync.router)
v1.include_router(imports.router)
v1.include_router(content.router)
v1.include_router(feed.router)
v1.include_router(pantry.router)
v1.include_router(voice.router)
v1.include_router(pool.router)
v1.include_router(assistant.router)
v1.include_router(photos.router)
v1.include_router(health_router)

__all__ = ["v1", "health_router"]
