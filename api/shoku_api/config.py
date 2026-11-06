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
    import_budget_seconds: float = 180.0
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
    #: Muse endpoint for the assistant. Empty means "reuse the structurer's",
    #: which is the same provider and the same key in every deployment so far.
    assistant_base_url: str = ""
    assistant_api_key: str = ""
    assistant_model: str = ""
    assistant_timeout: float = 60.0

    # The worker pool. One broker owns start and stop for every tenant sharing
    # the machine; tenants publish leases and demand, never GCE calls.
    pool_name: str = "render"
    pool_tenant: str = "shoku"
    pool_broker_enabled: bool = False
    pool_loop_seconds: int = 15
    pool_lease_ttl: int = 60
    pool_demand_ttl: int = 900
    pool_beat_ttl: int = 120
    pool_boot_grace_seconds: int = 180
    #: Comma-separated. Empty means "just worker_instance".
    pool_instances: str = ""

    # Hands-free voice. The upstream socket is the model's, opened with the
    # server-side key; the app never sees that key.
    voice_asr_url: str = "wss://api.meta.ai/v1/asr/realtime"
    voice_asr_model: str = "muse-voice-transcribe-1.0"
    voice_daily_minutes: int = 120
    #: Also the upstream connect timeout: a socket that has not opened in this
    #: long is a failure, not a slow start.
    voice_handshake_timeout: float = 10.0
    # An import is the expensive one: it boots a worker VM and calls the model
    # to read the video. Five a day is invisible to a normal kitchen and still
    # bounds what one account can cost.
    import_daily_cap: int = 5

    # Receipt parsing has its own allowance: a bag of shopping is not a
    # conversation, and sharing the assistant's 20 would spend it twice over.
    pantry_parse_daily_cap: int = 10

    # The Wall. A report is counted per distinct user; at this many, the row
    # leaves the feed. Never below 2 — a threshold of one is an unshare button.
    feed_report_threshold: int = 3

    # Worker VM. Off by default so a laptop never calls GCP; the deployed API
    # sets SHOKU_AUTOSTART_WORKER=1.
    autostart_worker: bool = False
    worker_instance: str = "reel-worker"
    gcp_project: str = ""
    gcp_zone: str = "us-central1-a"
    #: Ten imports arriving together must pay for one boot.
    worker_wake_debounce_seconds: int = 120
    #: An idle worker stops its own VM after this long with an empty queue.
    idle_shutdown_seconds: int = 300
    #: A job nobody claimed in this long is dead, not merely slow. Its own
    #: extraction budget starts at claim time, so this only catches wiring
    #: failures: a worker that never booted, or one that never came back.
    worker_unclaimed_timeout_seconds: int = 180

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
    #: Service-role key, used only to erase an account's auth identity. Empty
    #: means deletion removes the product data but leaves the login behind.
    supabase_service_key: str = ""
    supabase_audience: str = "authenticated"

    cors_origins: list[str] = Field(default_factory=list)


@lru_cache
def get_settings() -> Settings:
    return Settings()
