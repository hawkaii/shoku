"""Starting and stopping the import worker VM.

The worker is the expensive half of the system and is not left running, so a
job has to be able to summon it. Three pieces, deliberately separate:

* ``WorkerPool`` talks to the cloud. ``GceWorkerPool`` uses the Compute REST API
  with the VM's own metadata token — the container has no gcloud binary, and a
  privileged CLI inside an app image is a larger thing to own than an HTTP call.
* ``WakeGate`` is the debounce: ten imports arriving together must pay for one
  boot, not ten.
* ``WorkerWaker`` is the policy that joins them.

Autostart is **off** unless the deployment asks for it, so a laptop running the
API never calls GCP, and the test suite never leaves the machine.
"""

import time
from typing import Protocol

import httpx

from .errors import Unavailable

#: What ``ensure_awake`` reports, and what the job's progress_stage becomes.
RUNNING = "running"
STARTING = "starting"

_METADATA_TOKEN = (
    "http://metadata.google.internal/computeMetadata/v1/instance/"
    "service-accounts/default/token"
)
_COMPUTE = "https://compute.googleapis.com/compute/v1"


class WorkerPool(Protocol):
    def status(self) -> str:
        """GCE instance status, or ``UNKNOWN`` when it cannot be read."""

    def start(self) -> None: ...

    def stop(self) -> None: ...


class NoWorkerPool:
    """Autostart is off: assume a worker is there, and never call GCP.

    ``status`` says RUNNING so nothing tries to wake anything, and ``can_stop``
    is false so a dev worker never tries to power down the machine it is on.
    Local dev and the test suite run this one.
    """

    can_stop = False

    def status(self) -> str:
        return "RUNNING"

    def start(self) -> None:
        return None

    def stop(self) -> None:
        return None


class GceWorkerPool:
    """Compute Engine instance control over REST, authenticated by the metadata
    server. No service-account key file exists on the box, which is the point.
    """

    def __init__(
        self,
        *,
        project: str,
        zone: str,
        instance: str,
        timeout: float = 10.0,
    ) -> None:
        self.project = project
        self.zone = zone
        self.instance = instance
        self.timeout = timeout
        self.can_stop = True
        self._token: str | None = None
        self._expires_at = 0.0

    @property
    def _url(self) -> str:
        return f"{_COMPUTE}/projects/{self.project}/zones/{self.zone}/instances/{self.instance}"

    def _access_token(self) -> str:
        now = time.monotonic()
        if self._token is not None and now < self._expires_at:
            return self._token
        try:
            response = httpx.get(
                _METADATA_TOKEN,
                headers={"Metadata-Flavor": "Google"},
                timeout=self.timeout,
            )
            response.raise_for_status()
            body = response.json()
        except Exception as exc:  # noqa: BLE001 - every failure is "no identity"
            raise Unavailable(detail=f"no metadata token: {exc}") from exc
        self._token = str(body["access_token"])
        # Renew a minute early; a token that expires mid-call is indistinguishable
        # from a permission error in the logs.
        self._expires_at = now + max(60.0, float(body.get("expires_in", 300)) - 60.0)
        return self._token

    def _call(self, method: str, url: str) -> dict:
        try:
            response = httpx.request(
                method,
                url,
                headers={"Authorization": f"Bearer {self._access_token()}"},
                timeout=self.timeout,
            )
            response.raise_for_status()
            return response.json()
        except Unavailable:
            raise
        except Exception as exc:  # noqa: BLE001 - surfaced as one stable reason
            raise Unavailable(detail=f"compute api {method} {self.instance}: {exc}") from exc

    def status(self) -> str:
        # A status read that fails must not fail an import: trying to start an
        # instance that is already running is harmless, and refusing to try
        # would strand the job. So an unreadable status is simply "unknown".
        try:
            return str(self._call("GET", self._url).get("status", "UNKNOWN"))
        except Unavailable:
            return "UNKNOWN"

    def start(self) -> None:
        self._call("POST", f"{self._url}/start")

    def stop(self) -> None:
        self._call("POST", f"{self._url}/stop")


class WakeGate(Protocol):
    def claim(self, window: int) -> bool:
        """True if this caller should perform the wake in this window."""


class AlwaysWakeGate:
    """No debounce. Correct only when the wake is free — i.e. when it is a no-op."""

    def claim(self, window: int) -> bool:
        return True


class RedisWakeGate:
    """``SET NX EX`` on a Redis key: the first caller in the window boots the VM."""

    def __init__(self, url: str, *, key: str = "shoku:worker:wake") -> None:
        import redis  # noqa: PLC0415 - optional dependency

        self._client = redis.Redis.from_url(url, decode_responses=True)
        self._key = key

    def claim(self, window: int) -> bool:
        try:
            return bool(self._client.set(self._key, "1", nx=True, ex=max(1, window)))
        except Exception:  # noqa: BLE001 - a broken gate must not strand a job
            # Better to start a VM that is already starting than to leave the
            # user's import queued because Redis hiccuped.
            return True


class WorkerWaker:
    def __init__(self, pool: WorkerPool, gate: WakeGate, *, window: int = 120) -> None:
        self.pool = pool
        self.gate = gate
        self.window = window

    def ensure_awake(self) -> str:
        """``RUNNING`` if the worker is up, ``STARTING`` if a boot is owed.

        Raises ``Unavailable`` when the start itself is refused — the caller
        turns that into a failed job rather than a job that waits forever.
        """
        if self.pool.status() == "RUNNING":
            return RUNNING
        if self.gate.claim(self.window):
            self.pool.start()
        return STARTING
