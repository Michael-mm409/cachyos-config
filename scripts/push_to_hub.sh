#!/bin/bash

# Configuration
SOURCE="/mnt/Data/University/"
REMOTE="pve_remote:/home/michael/University/"

echo "--- Desktop -> Hub Sync Started: $(date) ---"

# Use 'sync' to make the Hub match your Desktop exactly
rclone sync "$SOURCE" "$REMOTE" \
    --exclude-from "$HOME/scripts/rsync-excludes.txt" \
    --links \
    -P

# The SSH trigger remains the same to start your cloud backup
echo "--- Triggering 4-3-2-1 Cloud Sync on Hub ---"
ssh michael@100.70.100.118 "nohup /home/michael/scripts/global_lab_sync.sh > /home/michael/logs/sync_session.log 2>&1 &"

echo "--- Desktop Handshake Complete: $(date) ---"
