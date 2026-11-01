"""The GCS backend: no key file, and a presigned URL that actually works.

These tests fake the google client rather than reaching the network. What is
worth pinning is the shape: a PUT-presigned V4 URL under our key, signed by an
impersonated copy of the VM's own identity (compute credentials cannot sign at
all), a public URL built from the configured base, and the cache headers that
make a copied cover cheap to re-read.
"""

import sys
import types

import pytest

from shoku_api.photos import GcsStorage

BASE = "https://storage.googleapis.com/shoku-media-test"
SIGNER = "reel-board@test.iam.gserviceaccount.com"


class Blob:
    def __init__(self, name: str) -> None:
        self.name = name
        self.cache_control = None
        self.uploaded: tuple[bytes, str] | None = None
        self.signed: dict | None = None

    def generate_signed_url(self, **kwargs):
        self.signed = kwargs
        return f"{BASE}/{self.name}?X-Goog-Signature=abc"

    def upload_from_string(self, body: bytes, content_type: str) -> None:
        self.uploaded = (body, content_type)


class Bucket:
    def __init__(self) -> None:
        self.blobs: dict[str, Blob] = {}

    def blob(self, name: str) -> Blob:
        return self.blobs.setdefault(name, Blob(name))


class Impersonated:
    """Stands in for google.auth.impersonated_credentials.Credentials."""

    instances: list["Impersonated"] = []

    def __init__(self, **kwargs) -> None:
        self.kwargs = kwargs
        Impersonated.instances.append(self)


@pytest.fixture
def gcs(monkeypatch):
    """Install fake google modules and return (storage, bucket)."""
    bucket = Bucket()
    Impersonated.instances = []

    class Client:
        def __init__(self, project=None, credentials=None) -> None:
            self.project = project
            self.credentials = credentials

        def bucket(self, name: str) -> Bucket:
            assert name == "shoku-media-test"
            return bucket

    storage_module = types.SimpleNamespace(Client=Client)
    auth_module = types.SimpleNamespace(
        default=lambda: ("base-credentials", "shoku-project"),
        impersonated_credentials=types.SimpleNamespace(Credentials=Impersonated),
    )
    google = types.ModuleType("google")
    cloud = types.ModuleType("google.cloud")
    cloud.storage = storage_module
    google.auth = auth_module

    monkeypatch.setitem(sys.modules, "google", google)
    monkeypatch.setitem(sys.modules, "google.auth", auth_module)
    monkeypatch.setitem(sys.modules, "google.cloud", cloud)
    monkeypatch.setitem(sys.modules, "google.cloud.storage", storage_module)

    storage = GcsStorage(
        bucket="shoku-media-test", public_base_url=BASE, service_account=SIGNER
    )
    return storage, bucket


def test_presigning_impersonates_the_machine_identity(gcs) -> None:
    """Compute credentials hold a token and cannot sign; the copy can."""
    storage, bucket = gcs

    upload = storage.presign_put(
        "photos/user-1/202601/x.jpg", content_type="image/jpeg", expires_in=900
    )

    signer = Impersonated.instances[0]
    assert signer.kwargs["target_principal"] == SIGNER
    assert signer.kwargs["source_credentials"] == "base-credentials"

    blob = bucket.blobs["photos/user-1/202601/x.jpg"]
    assert blob.signed["version"] == "v4"
    assert blob.signed["method"] == "PUT"
    assert blob.signed["content_type"] == "image/jpeg"
    assert blob.signed["credentials"] is signer
    assert blob.signed["service_account_email"] == SIGNER
    assert blob.signed["expiration"].total_seconds() == 900

    assert upload.method == "PUT"
    assert upload.key == "photos/user-1/202601/x.jpg"
    assert "X-Goog-Signature" in upload.url
    assert upload.public_url == f"{BASE}/photos/user-1/202601/x.jpg"


def test_without_an_identity_presigning_fails_loudly(monkeypatch) -> None:
    """Better a clear 503 than a URL nothing can upload to."""
    from shoku_api.domain.errors import Unavailable

    bucket = Bucket()

    class Client:
        def __init__(self, project=None, credentials=None) -> None:
            pass

        def bucket(self, name):
            return bucket

    storage_module = types.SimpleNamespace(Client=Client)
    auth_module = types.SimpleNamespace(
        default=lambda: ("base", "p"),
        impersonated_credentials=types.SimpleNamespace(Credentials=Impersonated),
    )
    google = types.ModuleType("google")
    cloud = types.ModuleType("google.cloud")
    cloud.storage = storage_module
    google.auth = auth_module
    for name, module in {
        "google": google,
        "google.auth": auth_module,
        "google.cloud": cloud,
        "google.cloud.storage": storage_module,
    }.items():
        monkeypatch.setitem(sys.modules, name, module)

    storage = GcsStorage(bucket="shoku-media-test", public_base_url=BASE)

    with pytest.raises(Unavailable):
        storage.presign_put("photos/x.jpg", content_type="image/jpeg", expires_in=900)


def test_a_server_side_put_sets_immutable_cache_headers(gcs) -> None:
    storage, bucket = gcs

    url = storage.put("thumbs/abc/deadbeef.jpg", b"bytes", content_type="image/jpeg")

    blob = bucket.blobs["thumbs/abc/deadbeef.jpg"]
    assert blob.uploaded == (b"bytes", "image/jpeg")
    assert "immutable" in blob.cache_control
    assert url == f"{BASE}/thumbs/abc/deadbeef.jpg"


def test_the_backend_can_store_so_the_backfill_runs(gcs) -> None:
    storage, _ = gcs
    assert storage.can_store is True


def test_a_missing_library_is_not_a_crash_but_an_unavailable(monkeypatch) -> None:
    """A host without the GCS client must fail loudly, not half-work."""
    from shoku_api.domain.errors import Unavailable

    for name in list(sys.modules):
        if name == "google" or name.startswith("google."):
            monkeypatch.delitem(sys.modules, name, raising=False)

    with pytest.raises(Unavailable):
        GcsStorage(bucket="b", public_base_url=BASE)
