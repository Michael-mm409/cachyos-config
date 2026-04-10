#!/bin/bash
# uni-sync.sh - Michael's USQ Data Science Hub Sync

# 1. Use the PHYSICAL path to avoid symlink recursion loops
SOURCE="/mnt/Data/University/"
LOG_FILE="$HOME/cachyos-config/sync.log"

# 2. MANDATORY Backup to External HDD (The WD Drive)
if [ -d "/mnt/External_Backup" ]; then
    echo "$(date) - [LOCAL] Syncing to WD HDD..." >> "$LOG_FILE"
    # Added .venv and __pycache__ excludes to save space/time
    rsync -avzu --no-perms --no-owner --no-group \
        --exclude=".conda/" --exclude=".venv/" --exclude="__pycache__/" \
        "$SOURCE" "/mnt/External_Backup/University_Backup/"
fi

# 3. Mini-PC Sync via Tailscale (The Hub)
TARGET_IP="100.70.100.118"
CURRENT_IP=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+')

if [[ "$CURRENT_IP" =~ ^192\.168\.[38]\. ]]; then
    echo "$(date) - [TRUSTED] Network $CURRENT_IP. Syncing to Mini-PC..." >> "$LOG_FILE"
    
    # NOTE: Since you just set up MUTAGEN, rsync here is technically redundant.
    # If you want Mutagen to handle the real-time stuff, you can comment this out.
    # If you want a "forced" sync, keep it:
    rsync -avzu --no-perms --no-owner --no-group \
        --exclude=".conda/" --exclude=".venv/" --exclude="__pycache__/" \
        "$SOURCE" "michael@$TARGET_IP:/home/michael/University/"
else
    echo "$(date) - [REMOTE] Unknown network ($CURRENT_IP). Skipping Mini-PC rsync." >> "$LOG_FILE"
fi
