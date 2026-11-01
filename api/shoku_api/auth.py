"""Identity: a Supabase user id (``sub``), never an email.

Three modes:

* ``dev``      — trusts an ``X-Firebase-Uid`` header. Never deploy this.
* ``supabase`` — verifies the JWT that Supabase Auth issues, against the
                 project's JWKS endpoint. This is the mode the app uses.
* ``firebase`` — kept only as a stub; it refuses to serve rather than pretend.

Why JWKS and not a shared secret: the project is configured with asymmetric
signing keys (ES256), so the public half is enough to verify a token and no
secret has to be stored on the server.
"""

from dataclasses import dataclass
from typing import Any, Mapping, Protocol

import jwt
from jwt import PyJWKClient

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


class SupabaseJwtVerifier:
    """Verifies a Supabase Auth access token against the project JWKS.

    ``sub`` is the user id. We deliberately do not read ``user_metadata``: it is
    user-editable, so it must never drive authorization (see the Supabase
    security checklist). Ownership lives in our own tables.
    """

    def __init__(
        self,
        project_url: str,
        *,
        audience: str = "authenticated",
        leeway_seconds: int = 30,
        jwk_client: PyJWKClient | None = None,
        decode: Any = jwt.decode,
    ) -> None:
        self.project_url = project_url.rstrip("/")
        self.issuer = f"{self.project_url}/auth/v1"
        self.audience = audience
        self.leeway = leeway_seconds
        self._decode = decode
        self._jwks = jwk_client or PyJWKClient(
            f"{self.project_url}/auth/v1/.well-known/jwks.json",
            cache_keys=True,
            lifespan=600,  # Supabase caches JWKS for ~10 minutes; match it.
        )

    def verify(self, headers: Mapping[str, str]) -> Identity:
        raw = headers.get("authorization") or headers.get("Authorization") or ""
        token = raw[7:].strip() if raw.lower().startswith("bearer ") else raw.strip()
        if not token:
            raise Unauthenticated(detail="missing bearer token")

        try:
            signing_key = self._jwks.get_signing_key_from_jwt(token)
            claims = self._decode(
                token,
                signing_key.key,
                algorithms=["ES256", "RS256"],
                audience=self.audience,
                issuer=self.issuer,
                leeway=self.leeway,
                options={"require": ["exp", "sub", "iss", "aud"]},
            )
        except jwt.ExpiredSignatureError as exc:
            raise Unauthenticated(detail="token expired") from exc
        except jwt.InvalidTokenError as exc:
            # One reason for every kind of bad token: the client does not need
            # to know whether it was the signature, the audience or the issuer.
            raise Unauthenticated(detail="invalid token") from exc
        except Exception as exc:  # noqa: BLE001 - JWKS fetch failures included
            raise Unavailable(detail=f"could not verify token: {exc}") from exc

        sub = (claims.get("sub") or "").strip()
        if not sub or len(sub) > 128:
            raise Unauthenticated(detail="token has no usable subject")
        return Identity(uid=sub)


class FirebaseVerifier:
    """Placeholder for ID-token verification against Google's public keys."""

    def __init__(self, project_id: str = "") -> None:
        self.project_id = project_id

    def verify(self, headers: Mapping[str, str]) -> Identity:
        raise Unavailable(
            detail=(
                "Firebase token verification is not implemented in this build; "
                "use Supabase Auth (SHOKU_AUTH_MODE=supabase) or dev mode."
            ),
            reason="auth_not_configured",
        )


def build_verifier(
    mode: str,
    project_id: str = "",
    *,
    supabase_url: str = "",
    supabase_audience: str = "authenticated",
) -> AuthVerifier:
    if mode == "dev":
        return DevHeaderVerifier()
    if mode == "supabase":
        if not supabase_url:
            raise ValueError("supabase auth mode needs SHOKU_SUPABASE_URL")
        return SupabaseJwtVerifier(supabase_url, audience=supabase_audience)
    if mode == "firebase":
        return FirebaseVerifier(project_id=project_id)
    raise ValueError(f"unknown auth mode {mode!r}")
