#!/bin/bash
# Proxmox (PVE) -> Laptop (Local Sync)
# High-speed sync via Tailscale/SFTP

REMOTE="pve_remote:/home/michael/University/" # UPDATE THIS PATH
LOCAL="/mnt/Data/University"

echo "--- 1. Checking Connectivity ---"
if tailscale status | grep -q "pve.*idle\|active"; then
    echo "PVE is online via Tailscale."
else
    echo "ERROR: Proxmox (pve) is offline or Tailscale is disconnected."
    exit 1
fi

echo "--- 2. Pulling University Data from PVE ---"
# Using rsync over rclone here as it's often faster for SFTP-like local transfers, 
# but since you have rclone configured, we'll stick to that for consistency.

rclone sync "$REMOTE" "$LOCAL" \
    --update \
    --use-server-modtime \
    --exclude "snapshots/**" \
    --exclude "UOW/**" \
    --exclude "Synology_Home" \
    --exclude "Synology_Home/**" \
    --links \
    --no-unicode-normalization \
    --ignore-errors \
    -P

echo "--- Sync Complete: $(date) ---"
