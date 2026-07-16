#!/bin/bash
# Michael's Laptop -> Proxmox
# Robust Latency Check + Stable SSH Sync

SOURCE="/mnt/Data/University"
REMOTE="pve_remote:/home/michael/University"
PVE_HOST="pve" 

echo "--- 1. Tailscale Path Optimization ---"
LATENCY=$(ping -c 5 $PVE_HOST | tail -1 | awk -F'/' '{print $4}' | awk '{print $NF}')

if [ -z "$LATENCY" ]; then
    echo "ERROR: Cannot reach Proxmox host ($PVE_HOST)."
    exit 1
fi

echo "Best Latency detected: ${LATENCY}ms"

if (( $(echo "$LATENCY < 15.0" | bc -l) )); then
    echo "Direct Path confirmed. Starting sync..."
else
    echo "WARNING: High Latency (${LATENCY}ms). Connection may be relayed."
    read -p "Push anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "--- 2. Syncing MDS Data ---"
# --transfers 4: Limits simultaneous files to prevent SSH reset
rclone sync "$SOURCE" "$REMOTE" \
    --update \
    --use-server-modtime \
    --exclude "snapshots/**" \
    --exclude "UOW/**" \
    --transfers 4 \
    --progress \
    --stats-one-line || { echo "ERROR: rclone sync failed!"; exit 1; }

echo "--- Backup Successful: $(date) ---"
