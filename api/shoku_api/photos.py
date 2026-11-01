"""Photos: the storage interface, its implementations, and presigning.

The API never proxies bytes. It hands the client a presigned PUT for a key it
chose, and the client uploads straight to the bucket. The key is always under
``photos/<uid>/``, so a client cannot ask for a path in someone else's
namespace.
"""

import hashlib
import hmac
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from typing import Protocol
from urllib.parse import quote

from .domain.errors import Unavailable
from .schemas import PresignRequest, PresignResponse


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

    def put(self, key: str, body: bytes, *, content_type: str) -> str | None:
        """Store bytes server-side and return their public URL.

        ``None`` means this backend cannot serve the object publicly — the dev
        placeholder, or a deployment with no bucket. Callers treat that as "we
        hold no copy" rather than inventing a URL that will 404.
        """
        ...


class DevStorage:
    """Deterministic placeholder URL for local development.

    Exercisable but not uploadable: nothing can PUT to it, and ``put`` reports
    that it stored nothing. A real deployment sets ``SHOKU_STORAGE_BACKEND=r2``.
    """

    #: This backend cannot hold an object, so nothing should claim it did.
    can_store = False

    def __init__(self, public_base_url: str) -> None:
        self._base = public_base_url.rstrip("/")

    def put(self, key: str, body: bytes, *, content_type: str) -> str | None:
        return None

    def presign_put(self, key: str, *, content_type: str, expires_in: int) -> PresignedUpload:
        return PresignedUpload(
            key=key,
            url=f"{self._base}/dev-put/{quote(key)}?content-type={quote(content_type)}",
            method="PUT",
            headers={"Content-Type": content_type},
            expires_in=expires_in,
            public_url=f"{self._base}/{quote(key)}",
        )


class FakeStorage:
    """Records presigns so tests can assert on the key namespace."""

    can_store = True

    def __init__(self, public_base_url: str = "https://media.test") -> None:
        self._base = public_base_url.rstrip("/")
        self.keys: list[str] = []
        self.written: dict[str, bytes] = {}

    def put(self, key: str, body: bytes, *, content_type: str) -> str | None:
        self.written[key] = body
        return f"{self._base}/{quote(key)}"

    def presign_put(self, key: str, *, content_type: str, expires_in: int) -> PresignedUpload:
        self.keys.append(key)
        return PresignedUpload(
            key=key,
            url=f"{self._base}/put/{quote(key)}",
            method="PUT",
            headers={"Content-Type": content_type},
            expires_in=expires_in,
            public_url=f"{self._base}/{quote(key)}",
        )


class R2Storage:
    """Cloudflare R2 via a boto3 S3 client (path-style, region ``auto``).

    boto3 is an optional dependency (``shoku-api[prod]``): the base install and
    the test suite must not need it.
    """

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

    def put(self, key: str, body: bytes, *, content_type: str) -> str | None:
        """Server-side upload: the one path where bytes pass through us.

        Used for a reel's cover, which has to be fetched from a link that is
        already expiring. User photos still go straight to the bucket on a
        presigned PUT; this is not a second upload path for them.
        """
        self._client.put_object(
            Bucket=self._bucket,
            Key=key,
            Body=body,
            ContentType=content_type,
            # The key is the SHA of these bytes, so the same URL is always the
            # same image. Cache it for a year rather than re-uploading hot.
            CacheControl="public, max-age=31536000, immutable",
        )
        return f"{self._public_base}/{quote(key)}" if self._public_base else None


class GcsStorage:
    """Google Cloud Storage on the same bucket that holds user photos.

    No key file anywhere: ``google.auth.default()`` reads the VM's metadata
    server identity, and V4 URL signing goes through ``signBlob`` on that same
    identity, so the bucket credentials can never drift from the machine's.

    The identity itself cannot sign — Compute credentials deliberately hold only
    a token — so presigning impersonates the account once and signs with that.
    It costs one extra IAM permission, ``roles/iam.serviceAccountTokenCreator``,
    and no secret.
    """

    can_store = True

    def __init__(
        self,
        *,
        bucket: str,
        public_base_url: str,
        project: str | None = None,
        service_account: str | None = None,
    ) -> None:
        try:
            from google.auth import default, impersonated_credentials
            from google.cloud import storage as gcs
        except ImportError as exc:  # pragma: no cover - prod only
            raise Unavailable(
                detail="google-cloud-storage is not installed; install shoku-api[prod]"
            ) from exc
        try:
            credentials, project_id = default()
        except Exception as exc:  # pragma: no cover - depends on the host
            raise Unavailable(detail=f"no default credentials: {exc}") from exc

        self._public_base = public_base_url.rstrip("/")
        self._client = gcs.Client(project=project or project_id, credentials=credentials)
        self._bucket = self._client.bucket(bucket)

        #: None means "cannot presign, but can still store server-side".
        self._signer = None
        self._signer_email: str | None = None
        email = service_account or _metadata_service_account()
        if email:
            self._signer = impersonated_credentials.Credentials(
                source_credentials=credentials,
                target_principal=email,
                target_scopes=["https://www.googleapis.com/auth/devstorage.read_write"],
                lifetime=3600,
            )
            self._signer_email = email

    def public_url(self, key: str) -> str | None:
        return f"{self._public_base}/{quote(key)}" if self._public_base else None

    def presign_put(self, key: str, *, content_type: str, expires_in: int) -> PresignedUpload:
        if self._signer is None:  # pragma: no cover - depends on the host
            raise Unavailable(
                detail="cannot sign upload URLs: no service account to impersonate"
            )
        url = self._bucket.blob(key).generate_signed_url(
            version="v4",
            expiration=timedelta(seconds=expires_in),
            method="PUT",
            content_type=content_type,
            credentials=self._signer,
            service_account_email=self._signer_email,
        )
        return PresignedUpload(
            key=key,
            url=url,
            method="PUT",
            headers={"Content-Type": content_type},
            expires_in=expires_in,
            public_url=self.public_url(key),
        )

    def put(self, key: str, body: bytes, *, content_type: str) -> str | None:
        blob = self._bucket.blob(key)
        # Set before uploading: metadata sent with the write is what a CDN and
        # the client cache actually see.
        blob.cache_control = "public, max-age=31536000, immutable"
        blob.upload_from_string(body, content_type=content_type)
        return self.public_url(key)


def _metadata_service_account(timeout: float = 5.0) -> str | None:
    """The VM's own service-account email, needed to impersonate ourselves.

    ``credentials.service_account_email`` is the alias ``"default"``, which is
    not a principal, so the real address comes from the metadata server.
    """
    import httpx  # noqa: PLC0415 - optional at import time

    url = (
        "http://metadata.google.internal/computeMetadata/v1/instance/"
        "service-accounts/default/email"
    )
    try:
        response = httpx.get(url, headers={"Metadata-Flavor": "Google"}, timeout=timeout)
        response.raise_for_status()
    except Exception:  # noqa: BLE001 - a host without metadata is not an error
        return None
    email = response.text.strip()
    return email or None


def object_key(user_id: str, extension: str | None, now: datetime | None = None) -> str:
    """``photos/<uid>/<yyyymm>/<random>.<ext>``, unguessable and namespaced."""
    moment = now or datetime.now(timezone.utc)
    digest = hashlib.sha256(f"{user_id}:{moment.isoformat()}".encode()).hexdigest()
    suffix = (extension or "jpg").lower()
    token = hmac.new(digest.encode(), b"shoku", "sha256").hexdigest()[:24]
    return f"photos/{user_id}/{moment:%Y%m}/{token}.{suffix}"


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
