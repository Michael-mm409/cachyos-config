#!/bin/bash

# 1. Grab the active Source IP
CURRENT_IP=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+')

# 2. MANDATORY Backup to External HDD (The Safety Net)
if [ -d "/mnt/External_Backup" ]; then
    echo "$(date) - [LOCAL] Syncing to WD HDD..." >> ~/cachyos-config/sync.log
    rsync -avzu --no-perms --no-owner --no-group --exclude=".conda/" ~/Documents/University/ /mnt/External_Backup/University_Backup/
else
    echo "$(date) - [ERROR] External HDD not found at /mnt/External_Backup" >> ~/cachyos-config/sync.log
fi

# 3. Intelligent Network Check for Mini-PC (The Brain)
if [[ "$CURRENT_IP" =~ ^192\.168\.[38]\. ]]; then
    NETWORK_STATE="HOME"
    TARGET_IP="192.168.3.145"
    echo "$(date) - [HOME] LAN Detected. Syncing to Mini-PC..." >> ~/cachyos-config/sync.log
    rsync -avzu --no-perms --no-owner --no-group --exclude=".conda/" ~/Documents/University/ michael@$TARGET_IP:/mnt/proxmox_uni/
else
    echo "$(date) - [REMOTE] Outside LAN. Skipping Mini-PC sync." >> ~/cachyos-config/sync.log
fi
