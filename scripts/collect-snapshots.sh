#!/usr/bin/env bash
set -euo pipefail

NS=demo
DEP=web
OUT_DIR="$(cd "$(dirname "$0")/../site/evidence" && pwd)"

mkdir -p "$OUT_DIR"

echo "== collect to $OUT_DIR =="

kubectl -n "$NS" get deploy "$DEP" -o wide > "$OUT_DIR/deploy.txt"
kubectl -n "$NS" get pods -o=custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[0].image,READY:.status.containerStatuses[0].ready,RESTARTS:.status.containerStatuses[0].restartCount,AGE:.metadata.creationTimestamp > "$OUT_DIR/pods.txt"
kubectl -n "$NS" rollout history deploy/"$DEP" > "$OUT_DIR/rollout.txt"
curl -sS http://127.0.0.1:30080 | head -n 8 > "$OUT_DIR/demo-head.txt"

echo "OK"
ls -la "$OUT_DIR"
