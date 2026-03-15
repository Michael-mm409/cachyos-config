#!/bin/bash

# 1. Grab the active Source IP to check if we are on a "Trusted" network
CURRENT_IP=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+')

# 2. MANDATORY Backup to External HDD (The WD Drive)
if [ -d "/mnt/External_Backup" ]; then
    echo "$(date) - [LOCAL] Syncing to WD HDD..." >> ~/cachyos-config/sync.log
    rsync -avzu --no-perms --no-owner --no-group --exclude=".conda/" ~/Documents/University/ /mnt/External_Backup/University_Backup/
fi

# 3. Mini-PC Sync via Tailscale
# This IP (The Brain) stays the same no matter what network you are on.
TARGET_IP="100.70.100.118"

# Check if you are at Home (.3) or if the Lab network (.8) is visible
if [[ "$CURRENT_IP" =~ ^192\.168\.[38]\. ]]; then
    echo "$(date) - [TRUSTED] Network $CURRENT_IP detected. Syncing to Mini-PC via Tailscale..." >> ~/cachyos-config/sync.log
    rsync -avzu --no-perms --no-owner --no-group --exclude=".conda/" ~/Documents/University/ michael@$TARGET_IP:/home/michael/University/
else
    # This will trigger at your Dad's or on public Wi-Fi to save bandwidth
    echo "$(date) - [REMOTE] Unknown network ($CURRENT_IP). Skipping Mini-PC sync." >> ~/cachyos-config/sync.log
fi
