# Shoku API

The server side of Shoku: journal sync, reel imports, the shared content cache,
the scoped assistant, and photo uploads.

The client is a Flutter app whose local schema lives in
`app/lib/data/db/app_database.dart`. **Field names here mirror it
exactly** (snake_case). If you change one, change both.

## Design rules this code follows

- **Ids are client-generated UUIDs.** The server never assigns one for journal
  rows, and never uses autoincrement. The only server-minted id is
  `import_jobs.id`, because a job is server state, not journal data.
- **Versions and cook logs are append-only.** They are inserted, never updated;
  a duplicate id is ignored, not rewritten.
- **Dishes are mutable.** Last-write-wins on the client's `updated_at`, guarded
  by a clock-skew check; the server stamps `server_received_at` on every
  accepted write and pull pages on that, so a device with a slow clock still
  sees its own rows and one with a fast clock cannot hide them.
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

Dev auth trusts an `X-Firebase-Uid` header:

```bash
curl -X POST localhost:8000/v1/sync/pull \
  -H 'X-Firebase-Uid: user-1' -H 'content-type: application/json' -d '{}'
```

`SHOKU_AUTH_MODE=firebase` refuses to serve rather than pretending to verify
tokens (see [Deliberate stubs](#deliberate-stubs)).

Postgres instead of SQLite (the deployed path), with migrations:

```bash
export SHOKU_DATABASE_URL='postgresql+psycopg://shoku:shoku@localhost:5432/shoku'
.venv/bin/pip install -e ".[dev,prod]"
.venv/bin/alembic upgrade head
.venv/bin/alembic check   # models and migration agree
.venv/bin/python -m shoku_api.imports.worker   # in another shell
```

With containers (api, worker, postgres, redis):

```bash
docker compose up --build
```

The api container runs `alembic upgrade head` before it serves.

## Tests

```bash
.venv/bin/pytest -q
```

The suite runs the real HTTP surface, the real services and the real worker
against SQLite in memory, with fakes only where an external service would be.
No Postgres, Redis, bucket, ffmpeg or model provider is needed. The Alembic
migration is checked against the models in `tests/test_migration.py`.

## Endpoints

All routes except `/health` require an identity (`X-Firebase-Uid` in dev).

| Method | Path | Purpose |
|---|---|---|
| GET | `/health` | liveness + dependency check |
| POST | `/v1/sync/pull` | rows changed since a cursor, tombstones included |
| POST | `/v1/sync/push` | idempotent upsert; append-only rows ignored if present |
| POST | `/v1/imports` | normalise a reel URL, return cache hit (200) or enqueue a job (202) |
| GET | `/v1/imports/{job_id}` | `queued \| extracting \| ready \| failed` |
| POST | `/v1/imports/{job_id}/cancel` | cancel a queued or running job |
| GET | `/v1/content/{shortcode}` | cached extraction (recipe + prose + attribution) |
| DELETE | `/v1/content/{shortcode}` | takedown; erases the payload, keeps the stub |
| POST | `/v1/assistant/ask` | scoped answer, capped per user per day |
| POST | `/v1/photos/presign` | presigned upload target |

Errors are `{"error": "<stable reason>", "detail": "..."}` with a matching
status (`401 unauthenticated`, `404 not_found`, `410 gone`, `422
unsupported_url`, `429 daily_cap_reached`, `503 not_configured`).

### Sync

`POST /v1/sync/push` returns, per table, one result per row:
`accepted`, `ignored` (already there / already applied) or `conflict` (stale
write, clock ahead, unknown dish, id owned by someone else). It is safe to
retry a whole batch.

`POST /v1/sync/pull` takes `{since, cursor, limit}`, returns rows grouped as
`dishes`, `versions`, `cook_logs`, plus `cursor`, `has_more` and `server_time`.
Loop while `has_more`, passing `cursor` back. A corrupt cursor restarts the page
rather than failing the sync.

### Imports

`POST /v1/imports` returns `{job_id, state, cached, shortcode}`. A cache hit
returns `job_id: null` and state `ready` — no job exists because no work was
needed. A concurrent request for a shortcode already queued returns that same
job. A shortcode that was taken down returns `410`, permanently: re-extracting
it would undo the takedown.

Cancellation is `state: failed` with `reason: "cancelled"`. The public state
set is the four values above; a fifth state would be one more thing for the
client to learn.

### Pipeline

`queued → extracting → ready | failed`, one job at a time per worker.

- **Hard 60-second budget** (`BUDGET_SECONDS`), monotonic, checked between
  stages and passed into every stage so an implementation can abort its own I/O.
  Configuration may shorten it, never lengthen it.
- **Caption first**: if the caption already contains quantities, the caption is
  structured and ASR never starts.
- **Rolling breaker**: over the last 20 terminal jobs, a success rate below 60%
  degrades new jobs to caption-only (no ASR). Cancellations are not failures and
  do not count.
- **No media persists**: audio lives in a `TemporaryDirectory` that is removed
  on success, failure and timeout alike.

### Assistant

`POST /v1/assistant/ask` takes `{dish_id, version_id?, question}` and returns
`{answer, remaining}`. The model sees one dish and one version — nothing from
another user, nothing else from the journal. The daily cap is enforced with a
conditional `UPDATE ... WHERE count < cap`, so concurrent requests cannot both
slip through; a failed model call refunds the credit. There is no code path from
this module to a recipe write.

## Layout

```
shoku_api/
  main.py       app factory (no import-time side effects)
  asgi.py       uvicorn target
  routes/       HTTP: validate, call a service, return
  sync.py       merge rules for pull/push
  imports/      interfaces + fakes, queue, worker (state machine), job service
  assistant.py  AssistantModel interface, fake, daily cap
  content.py    shared extraction cache and takedown
  photos.py     Storage interface, presign, R2/dev fakes
  domain/       pure helpers: URL normalisation, captions, cursors, clock, breaker
  schemas.py    pydantic models; strict where the model is untrusted
  models.py     SQLAlchemy tables mirroring the drift schema
  container.py  composition root — the one place implementations are chosen
alembic/        initial migration + env
tests/          pytest, SQLite in memory
```

## Deliberate stubs

Each fails loudly with `503 not_configured` (or a job failure reason) rather
than returning something plausible and wrong. Wire a real implementation in
`container.py`; the interfaces are the contract.

- **`FirebaseVerifier`** — ID-token verification against Google's public keys
  needs `google-auth`/`firebase-admin` and a project id. Dev mode trusts the
  header and must only run behind a trusted gateway.
- **`UnconfiguredExtractor`** — media fetch + audio strip (yt-dlp/ffmpeg).
  Returns job reason `extractor_not_configured`.
- **`UnconfiguredTranscriber`** — ASR (Whisper or a hosted API). Reason
  `transcriber_not_configured`.
- **`UnconfiguredStructurer`** — caption/transcript → `RecipePayload`. Reason
  `structurer_not_configured`.
- **`UnconfiguredAssistantModel`** — assistant provider.
- **`R2Storage`** — implemented against boto3 but requires real R2 credentials;
  `DevStorage` returns a URL that looks presigned and is not uploadable.
- **Account deletion** — `users.delete_account()` erases everything (the only
  hard delete in the system) but has no HTTP route, because account deletion was
  not in the agreed endpoint list.
