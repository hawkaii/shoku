"""Presigned photo uploads.

The server picks the key, always under ``photos/<uid>/``, so a client cannot
request a path outside its own namespace even if it tries.
"""

from dataclasses import dataclass

from ..interfaces.storage import Storage, object_key
from ..schemas.wire import PresignRequest, PresignResponse


@dataclass(frozen=True)
class PhotoDeps:
    storage: Storage
    expires_in: int
    public_base_url: str = ""


def presign_upload(deps: PhotoDeps, *, uid: str, request: PresignRequest, now) -> PresignResponse:
    key = object_key(uid, request.extension, now)
    upload = deps.storage.presign_put(
        key, content_type=request.content_type, expires_in=deps.expires_in
    )
    return PresignResponse(
        key=upload.key,
        upload_url=upload.url,
        method="PUT",
        headers=upload.headers,
        expires_in=upload.expires_in,
        public_url=upload.public_url,
    )
