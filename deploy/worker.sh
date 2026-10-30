#!/usr/bin/env bash
# Start the worker VM, drain the queue, and stop it again.
#
# The worker is the only part of Shoku that costs money per hour, so it is not
# left running. Imports queue in Redis on the API box and wait here.
#
#   ./deploy/worker.sh up      # start the VM and follow the worker log
#   ./deploy/worker.sh down    # stop the VM (disk stays, compute stops)
#   ./deploy/worker.sh status  # what state is it in, and what is queued
set -euo pipefail

ZONE="${SHOKU_ZONE:-us-central1-a}"
INSTANCE="${SHOKU_WORKER:-reel-worker}"
API_VM="${SHOKU_API_VM:-instance-20260524-054843}"
GCLOUD=(gcloud --configuration="${SHOKU_GCLOUD_CONFIG:-default}" compute)

status() {
  "${GCLOUD[@]}" instances describe "$INSTANCE" --zone="$ZONE" \
    --format="value(name,status,machineType.basename())"
  "${GCLOUD[@]}" ssh "$API_VM" --zone="$ZONE" \
    --command="sudo docker compose -f /opt/shoku/docker-compose.yml exec -T redis redis-cli LLEN shoku:imports" \
    2>/dev/null | sed 's/^/queued jobs: /' || true
}

case "${1:-up}" in
  up)
    "${GCLOUD[@]}" instances start "$INSTANCE" --zone="$ZONE"
    echo "waiting for ssh…"
    for _ in $(seq 1 30); do
      if "${GCLOUD[@]}" ssh "$INSTANCE" --zone="$ZONE" --command=true 2>/dev/null; then break; fi
      sleep 5
    done
    # Boot does not start containers on its own; compose is idempotent.
    "${GCLOUD[@]}" ssh "$INSTANCE" --zone="$ZONE" \
      --command="cd /opt/shoku && sudo docker compose up -d && sudo docker compose logs -f --tail=40 worker"
    ;;
  down)
    "${GCLOUD[@]}" ssh "$INSTANCE" --zone="$ZONE" \
      --command="cd /opt/shoku && sudo docker compose stop worker" || true
    "${GCLOUD[@]}" instances stop "$INSTANCE" --zone="$ZONE"
    echo "worker stopped; queue depth is preserved in Redis"
    ;;
  status)
    status
    ;;
  *)
    echo "usage: $0 {up|down|status}" >&2
    exit 2
    ;;
esac
