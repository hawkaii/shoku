"""Identity: always a Firebase uid, never an email.

``dev`` trusts an ``X-Firebase-Uid`` header so the API is usable offline.
``firebase`` is where signed ID-token verification belongs; it is deliberately
not implemented here (see README, "Deliberate stubs") because it needs live
Google keys. Refusing to start in that mode is safer than pretending.
"""

from dataclasses import dataclass
from typing import Mapping, Protocol

from .domain.errors import Unauthenticated, Unavailable


@dataclass(frozen=True)
class Identity:
    uid: str


class AuthVerifier(Protocol):
    def verify(self, headers: Mapping[str, str]) -> Identity: ...


class DevHeaderVerifier:
    """Trusts ``X-Firebase-Uid``. Never enable this in a deployed environment."""

    header = "x-firebase-uid"

    def verify(self, headers: Mapping[str, str]) -> Identity:
        uid = (headers.get(self.header) or "").strip()
        if not uid:
            raise Unauthenticated(detail="missing X-Firebase-Uid header")
        if len(uid) > 128:
            raise Unauthenticated(detail="uid too long")
        return Identity(uid=uid)


class FirebaseVerifier:
    """Placeholder for ID-token verification against Google's public keys."""

    def __init__(self, project_id: str = "") -> None:
        self.project_id = project_id

    def verify(self, headers: Mapping[str, str]) -> Identity:
        raise Unavailable(
            detail=(
                "Firebase token verification is not implemented in this build; "
                "run with SHOKU_AUTH_MODE=dev behind a trusted gateway, or wire "
                "google-auth/firebase-admin into FirebaseVerifier."
            ),
            reason="auth_not_configured",
        )


def build_verifier(mode: str, project_id: str = "") -> AuthVerifier:
    if mode == "dev":
        return DevHeaderVerifier()
    if mode == "firebase":
        return FirebaseVerifier(project_id=project_id)
    raise ValueError(f"unknown auth mode {mode!r}")
