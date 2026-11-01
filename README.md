# Shoku

**A cooking journal that reads recipes off reels.**

Import a reel from Instagram or YouTube. Shoku works out what the dish is, turns
the method into numbered steps, links each step to the ingredients it uses, and
files it in your journal. Cook it, change it, and Shoku remembers which version
you actually preferred.

Built for the **Meta Global AI Developer Hackathon** (Oct 26 – Nov 4, 2026),
**Indie Developer track**.

```
app/     Flutter client (Android, web, desktop)
api/     FastAPI service, import worker, Muse structuring, sync, feed
```

---

## The interesting part: reading a recipe out of a video

A reel is hostile input. Sometimes there is a caption with the whole recipe.
Sometimes the quantities are in the creator's pinned comment. Sometimes the
caption is `#food #recipe` and the method is burned onto the video as text while
someone cooks silently.

The pipeline tries those in order and falls through:

```
caption ─┐
comment ─┤
subtitles┼─→ Muse structuring (schema-constrained JSON) ─→ cache ─→ your dish
ASR ─────┤                    │
frames ──┘                    └─ heuristic fallback if the model fails
```

- **Meta Model API, Muse Spark** (`muse-spark-1.3`) does the structuring, with
  `response_format: json_schema` and `strict`, so the decoder can only emit a
  recipe — a caption trying to give the model orders has nowhere to land.
- **Reasoning effort is pinned to `minimal`** with a generous token budget.
  Muse reasons before answering and bills those tokens as output; a budget sized
  for the recipe alone returns `content: null`.
- **Vision over sampled frames** handles silent reels: ffmpeg pulls 16 stills,
  Muse reads the on-screen text and the visible actions, and the result is tagged
  `from video` because nobody stated those amounts.
- **A heuristic fallback** means a model outage degrades the parse instead of
  losing the recipe.

Everything is cached globally by reel, so a viral recipe is parsed once, ever.

---

## Architecture

```
Flutter app ── sync ──> FastAPI (free e2-micro) ──> Supabase Postgres (RLS on)
                              │
                              └─ queue ─> worker VM (on demand)
                                            yt-dlp · whisper · Muse
```

- **Auth** — Supabase, verified server-side against the project's JWKS.
- **Sync** — client-generated UUIDs, append-only versions and cooks unioned by
  id, last-write-wins on dish metadata, tombstones for deletes.
- **Imports** — jobs on a Redis queue; the worker VM sleeps when idle and the API
  wakes it when a job arrives.
- **Cost** — the API runs on a free-tier VM, the worker only while importing, and
  images live in a GCS bucket.

---

## Running it

```bash
# api
cd api && python -m venv .venv && .venv/bin/pip install -e ".[dev,prod]"
cp .env.example .env          # Supabase URL/keys, Muse key, storage bucket
.venv/bin/alembic upgrade head
.venv/bin/uvicorn shoku_api.asgi:app --reload

# app
cd app && flutter pub get && flutter run
```

`api/DEPLOY.md` is the two-machine runbook. Both test suites run without
network, Postgres or Redis:

```bash
cd api && pytest -q          # 169 tests
cd app && flutter test       # 161 tests
```

---

## Known limitations

- Recipes read from a silent reel carry **guessed amounts**, labelled `from video`.
  The app never invents a number and presents it as measured.
- Nutrition is deliberately **not estimated** (`kcal`/`protein` are 0).
- The Wall is a public feed of imported reels. It has no user-facing report or
  takedown path yet — an operator can remove one.
- Photos per version are modelled and synced, but the UI is not built.

## Licence

MIT — see `LICENSE`.
