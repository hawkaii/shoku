# Deploying Shoku

Two machines, because the work is wildly asymmetric:

| | Machine | Runs | Cost |
|---|---|---|---|
| **API** | free `e2-micro` (`instance-20260524-054843`) | api, redis | free tier |
| **Worker** | `reel-worker` (10 vCPU) | the import pipeline, yt-dlp, whisper | per hour — start it when needed |

The API is always on. The worker is not: extraction and speech recognition are
bursty, memory-hungry, and useless when nobody is importing.

## API box

```bash
cd /opt/shoku
sudo cp deploy/docker-compose.prod.yml docker-compose.yml
sudo docker compose up -d --pull never
curl localhost:8000/health
```

`.env` on this box needs:

```
SHOKU_DATABASE_URL=postgresql+psycopg://…@aws-0-eu-central-2.pooler.supabase.com:5432/postgres
SHOKU_QUEUE_BACKEND=redis
SHOKU_REDIS_URL=redis://redis:6379/0
SHOKU_AUTH_MODE=supabase
SHOKU_SUPABASE_URL=https://<project>.supabase.co
SHOKU_IMAGE=shoku-api:api
```

Images are built on the box (no registry pull: the GHCR package is private and
needs `read:packages` to fetch):

```bash
sudo docker build --build-arg EXTRAS=prod -t shoku-api:api .
```

## Worker VM

Same repo, heavier image:

```bash
sudo docker build --build-arg EXTRAS="prod,worker,whisper" -t shoku-api:worker .
sudo cp deploy/docker-compose.worker.yml docker-compose.yml
sudo docker compose up -d
```

Its `.env` is the API's, with the two hostnames swapped for the API box's
**private** IP (they share the VPC, so this never leaves Google's network):

```
SHOKU_REDIS_URL=redis://10.128.0.2:6379/0
SHOKU_EXTRACTOR=ytdlp
SHOKU_TRANSCRIBER=whisper
SHOKU_STRUCTURER=heuristic
SHOKU_WHISPER_MODEL=base
SHOKU_IMAGE=shoku-api:worker
```

Firewall, once:

```bash
gcloud compute firewall-rules create allow-shoku-redis \
  --allow=tcp:6379 --source-ranges=10.128.0.0/20
```

## Why whisper is not in the API image

`faster-whisper` pulls `ctranslate2` and `onnxruntime` (~600 MB installed) and
needs ~1 GB resident to transcribe. The free e2-micro has 953 MB in total and a
disk that already sits above 90% full — putting whisper there fills the disk
during the build. It belongs on the worker, which is started on demand.

## Cost control

`gcloud compute instances stop reel-worker --zone=us-central1-a` when done. A
stopped VM costs only its disk. Nothing in the API depends on the worker being
up: imports queue in Redis and drain when it comes back.
