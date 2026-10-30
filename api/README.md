# Shoku API

The server side of Shoku: journal sync, reel imports, the shared content cache,
the scoped assistant, and photo uploads.

The client is a Flutter app whose local schema lives in
`food-finder-app/lib/data/db/app_database.dart`. **Field names here mirror it
exactly** (snake_case). If you change one, change both.

## Design rules this code follows

- **Ids are client-generated UUIDs.** The server never assigns one.
- **Versions and cook logs are append-only.** They are inserted, never updated;
  a duplicate id is ignored, not rewritten.
- **Dishes are mutable**, with last-write-wins on `updated_at` where the server
  stamps the time it received the row.
- **Deletes are tombstones** (`deleted_at`). Rows stay; clients hide them.
- **Identity is a Firebase `uid`**, never an email.
- **Media is transient.** Audio exists only inside a temp directory for the
  duration of a job; no video is ever stored.

## Run it

```bash
python3 -m venv .venv
.venv/bin/pip install -e ".[dev]"
SHOKU_AUTH_MODE=dev .venv/bin/uvicorn shoku_api.asgi:app --reload
curl localhost:8000/health
```

Dev auth trusts an `X-Firebase-Uid` header. `SHOKU_AUTH_MODE=firebase` refuses
to serve rather than pretending to verify tokens.

With containers:

```bash
docker compose up --build
```

## Tests

```bash
.venv/bin/pytest -q
```

The suite runs the real HTTP surface, the real services and the real worker
against SQLite in memory, with fakes only where an external service would be.

## Endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | `/health` | liveness + dependency check |
| POST | `/v1/sync/pull` | rows changed since a cursor, tombstones included |
| POST | `/v1/sync/push` | idempotent upsert; append-only rows ignored if present |
| POST | `/v1/imports` | normalise a reel URL, return cache hit or enqueue a job |
| GET | `/v1/imports/{job_id}` | job state |
| POST | `/v1/imports/{job_id}/cancel` | cancel a queued job |
| GET | `/v1/content/{shortcode}` | cached extraction (recipe + prose + attribution) |
| DELETE | `/v1/content/{shortcode}` | takedown; erases the payload |
| POST | `/v1/assistant/ask` | scoped answer, capped per user per day |
| POST | `/v1/photos/presign` | presigned upload target |

## Deliberate stubs

These raise `503` with a stable reason rather than returning something wrong:

- `FirebaseVerifier` — needs Google's public keys.
- `UnconfiguredExtractor/Transcriber/Structurer` — wire yt-dlp, the Meta
  transcriber and the structuring model in `container.py`.
- `UnconfiguredAssistantModel` — the assistant model provider.
- `R2Storage` — needs real credentials; `DevStorage` is used locally.

## Layout

```
shoku_api/
  api/          HTTP routers (thin: validate, call a service, return)
  services/     business rules; own their transaction boundaries
  worker/       import pipeline: claim → extract → transcribe → structure → persist
  domain/       pure helpers: URL normalisation, cursors, clock, circuit breaker
  interfaces/   protocols + unconfigured implementations
  schemas/      pydantic request/response, strict where the model is untrusted
  models.py     SQLAlchemy tables mirroring the drift schema
```
