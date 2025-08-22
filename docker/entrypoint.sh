#!/usr/bin/env bash
set -euo pipefail

# Simple logs
echo "[entrypoint] running rclone mounts..."

# Create mount points (must be empty)
mkdir -p /home/jovyan/data/s3_mount
mkdir -p /home/jovyan/data/swift_mount
chown -R "${NB_UID:-1000}:${NB_GID:-100}" /home/jovyan/data || true
# rclone config path (explicit)

RCLONE_CONF="/home/jovyan/.config/rclone/rclone.conf"

# Common fast options
FAST_FLAGS=(
  --vfs-cache-mode full
  --vfs-fast-fingerprint
  --vfs-read-chunk-streams 10
  --no-modtime
  --transfers 10
)

# Mount S3 (Ceph) remote
rclone mount rclone_s3:s3_mount /home/jovyan/data/s3_mount \
  "${FAST_FLAGS[@]}" \
  --daemon
 
# Mount Swift
rclone mount rclone_swift:swift_mount /home/jovyan/data/swift_mount \
  "${FAST_FLAGS[@]}" \
  --daemon

echo "[entrypoint] mounts started. Launching Jupyter..."

# Finally exec Jupyter (use existing image start
exec start.sh jupyter lab --ServerApp.token='' --ServerApp.allow_origin='*' --ServerApp.ip=0.0.0.0 --ServerApp.port=8888
