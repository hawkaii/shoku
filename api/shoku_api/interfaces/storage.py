"""Object storage, behind a presigner.

The API never proxies bytes. It hands the client a presigned PUT for a key it
chose, and the client uploads straight to the bucket.
"""

import hashlib
import hmac
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Protocol
from urllib.parse import quote

from ..domain.errors import Unavailable


@dataclass(frozen=True)
class PresignedUpload:
    key: str
    url: str
    method: str
    headers: dict[str, str] = field(default_factory=dict)
    expires_in: int = 900
    public_url: str | None = None


class Storage(Protocol):
    def presign_put(
        self, key: str, *, content_type: str, expires_in: int
    ) -> PresignedUpload: ...


class DevStorage:
    """Deterministic placeholder. Clearly not a real bucket.

    Exists so the endpoint is exercisable locally; the URL cannot be PUT to.
    """

    def __init__(self, public_base_url: str) -> None:
        self._base = public_base_url.rstrip("/")

    def presign_put(self, key: str, *, content_type: str, expires_in: int) -> PresignedUpload:
        return PresignedUpload(
            key=key,
            url=f"{self._base}/dev-put/{quote(key)}?content-type={quote(content_type)}",
            method="PUT",
            headers={"Content-Type": content_type},
            expires_in=expires_in,
            public_url=f"{self._base}/{quote(key)}",
        )


class R2Storage:
    """Cloudflare R2 via a boto3 S3 client (path-style, region ``auto``)."""

    def __init__(
        self,
        *,
        account_id: str,
        access_key_id: str,
        secret_access_key: str,
        bucket: str,
        public_base_url: str,
    ) -> None:
        if not (account_id and access_key_id and secret_access_key and bucket):
            raise Unavailable(detail="R2 storage is not configured")
        try:
            import boto3  # noqa: PLC0415 - optional dependency
        except ImportError as exc:  # pragma: no cover - prod only
            raise Unavailable(
                detail="boto3 is not installed; install shoku-api[prod]"
            ) from exc

        self._bucket = bucket
        self._public_base = public_base_url.rstrip("/")
        self._client = boto3.client(
            "s3",
            endpoint_url=f"https://{account_id}.r2.cloudflarestorage.com",
            aws_access_key_id=access_key_id,
            aws_secret_access_key=secret_access_key,
            region_name="auto",
            config=boto3.session.Config(signature_version="s3v4"),
        )

    def presign_put(self, key: str, *, content_type: str, expires_in: int) -> PresignedUpload:
        url = self._client.generate_presigned_url(
            "put_object",
            Params={"Bucket": self._bucket, "Key": key, "ContentType": content_type},
            ExpiresIn=expires_in,
        )
        return PresignedUpload(
            key=key,
            url=url,
            method="PUT",
            headers={"Content-Type": content_type},
            expires_in=expires_in,
            public_url=f"{self._public_base}/{quote(key)}" if self._public_base else None,
        )


def object_key(user_id: str, extension: str | None, now: datetime | None = None) -> str:
    """``photos/<uid>/<yyyymm>/<random>.<ext>``.

    The uid prefix is what stops a presigned key from ever pointing into
    another user's namespace.
    """
    moment = now or datetime.now(timezone.utc)
    digest = hashlib.sha256(f"{user_id}:{moment.isoformat()}".encode()).hexdigest()
    suffix = (extension or "jpg").lower()
    return f"photos/{user_id}/{moment:%Y%m}/{hmac.new(digest.encode(), b'shoku', 'sha256').hexdigest()[:24]}.{suffix}"
