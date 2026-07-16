#!/bin/bash

# Configuration
REMOTE="pve_remote:/home/michael/University/"
LOCAL_DIR="$HOME/Documents/University/"
EXCLUDES="$HOME/scripts/rsync-excludes.txt"

# Ensure local directory exists
mkdir -p "$LOCAL_DIR"

echo "--- Pulling latest University data from PVE ---"

rclone copy "$REMOTE" "$LOCAL" \
    --update \
    --use-server-modtime \
    --exclude-from "$HOME/scripts/rsync-excludes.txt" \
    --links \
    -P

echo "--- Sync Complete ---"
