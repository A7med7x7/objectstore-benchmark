#!/usr/bin/env bash
set -euo pipefail

echo "[entrypoint] running rclone mounts..."

mkdir -p /home/jovyan/data/s3_mount
mkdir -p /home/jovyan/data/swift_mount
chown -R "${NB_UID:-1000}:${NB_GID:-100}" /home/jovyan/data || true

RCLONE_CONF="/home/jovyan/.config/rclone/rclone.conf"

FAST_FLAGS=(
  --vfs-cache-mode full
  --vfs-fast-fingerprint
  --vfs-read-chunk-streams 10
  --no-modtime
  --transfers 10
)

rclone mount rclone_s3:s3_mount /home/jovyan/data/s3_mount \
  "${FAST_FLAGS[@]}" \
  --daemon
 
rclone mount rclone_swift:swift_mount /home/jovyan/data/swift_mount \
  "${FAST_FLAGS[@]}" \
  --daemon

echo "[entrypoint] mounts started. Launching Jupyter..."
exec start.sh jupyter lab --ServerApp.token='' --ServerApp.allow_origin='*' --ServerApp.ip=0.0.0.0 --ServerApp.port=8888
