#!/bin/bash
# uni-sync.sh - Michael's USQ Data Science Hub Sync

# 1. Hardware Aware Path Selection
if [ -d "/mnt/Data/University" ]; then
    SOURCE="/mnt/Data/University/"
    echo "Hardware: Desktop detected."
else
    SOURCE="$HOME/Documents/University/"
    echo "Hardware: Laptop detected."
fi

LOG_FILE="$HOME/cachyos-config/sync.log"

# 2. MANDATORY Backup to External HDD (The WD Drive)
if [ -d "/mnt/External_Backup" ]; then
    echo "$(date) - [LOCAL] Syncing to WD HDD..." >> "$LOG_FILE"
    rsync -avzu --no-perms --no-owner --no-group \
        --exclude=".conda/" --exclude=".venv/" --exclude="__pycache__/" \
        "$SOURCE" "/mnt/External_Backup/University_Backup/"
fi

# 3. Mini-PC Sync via Tailscale (The Hub)
TARGET_IP="100.70.100.118"
# Grab current IP to check if we're home (192.168.x.x)
CURRENT_IP=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+')

if [[ "$CURRENT_IP" =~ ^192\.168\.[38]\. ]]; then
    echo "$(date) - [TRUSTED] Network $CURRENT_IP. Syncing to Mini-PC..." >> "$LOG_FILE"
    
    rsync -avzu --no-perms --no-owner --no-group \
        --exclude=".conda/" --exclude=".venv/" --exclude="__pycache__/" \
        "$SOURCE" "michael@$TARGET_IP:/home/michael/University/"
else
    # In Jerangle, you'll likely hit this branch.
    echo "$(date) - [REMOTE] Network ($CURRENT_IP) is not Home. Skipping Mini-PC rsync." >> "$LOG_FILE"
fi
