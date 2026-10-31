"""Runtime configuration.

Everything is read from the environment with a ``SHOKU_`` prefix. No secrets
live in the repo; ``.env.example`` documents the shape only.
"""

from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="SHOKU_",
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    environment: str = "dev"

    # Local default keeps `uvicorn shoku_api.main:app` runnable with no setup.
    database_url: str = "sqlite:///./shoku.db"

    # "redis" in every deployed environment; "memory" is for a single-process
    # dev box and for tests.
    queue_backend: str = "memory"
    redis_url: str = "redis://localhost:6379/0"
    import_queue_name: str = "shoku:imports"

    # Import pipeline.
    import_budget_seconds: float = 60.0
    breaker_window: int = 20
    breaker_threshold: float = 0.6
    breaker_min_samples: int = 5
    media_tmp_dir: str = ""  # empty -> system temp dir

    # Which real adapters the worker uses. Empty means "not configured", which
    # makes jobs fail with a stable reason instead of producing junk.
    extractor: str = ""          # "ytdlp"
    transcriber: str = ""        # "whisper"
    structurer: str = ""         # "heuristic" | "muse"
    whisper_model: str = "base"
    cookies_file: str = ""
    structurer_base_url: str = ""
    structurer_api_key: str = ""
    structurer_model: str = ""
    # Muse reasons before it answers, and its reasoning tokens come out of the
    # same budget as the reply. "minimal" is the cheapest level that still
    # works for extraction; the budget must cover thinking plus the recipe.
    structurer_reasoning_effort: str = "minimal"
    structurer_max_tokens: int = 8000
    structurer_timeout: float = 120.0
    #: "auto" reads a silent reel from sampled frames; "off" refuses instead.
    vision: str = "auto"
    vision_frames: int = 16

    # Assistant.
    assistant_daily_cap: int = 20
    assistant_model_name: str = "fake-assistant"

    # Storage. "dev" returns a placeholder PUT URL and is not usable by a real
    # client; "r2" presigns against Cloudflare R2.
    storage_backend: str = "dev"
    storage_bucket: str = "shoku-media"
    storage_public_base_url: str = "https://media.example.invalid"
    r2_account_id: str = ""
    r2_access_key_id: str = ""
    r2_secret_access_key: str = ""
    presign_expires_seconds: int = 900

    # Sync.
    sync_page_size: int = 500
    sync_max_page_size: int = 1000
    clock_skew_allowance_seconds: int = 300

    # Auth. "dev" trusts the X-Firebase-Uid header (never deploy it); "firebase"
    # verifies signed ID tokens (see shoku_api.auth).
    auth_mode: str = "dev"

    # Supabase Auth: the JWT issuer is <url>/auth/v1 and user tokens carry
    # audience "authenticated". Both are required to verify an access token.
    supabase_url: str = ""
    supabase_audience: str = "authenticated"

    cors_origins: list[str] = Field(default_factory=list)


@lru_cache
def get_settings() -> Settings:
    return Settings()
