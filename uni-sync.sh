#!/bin/bash
# Path: /home/michael/cachyos-setup/uni-sync.sh

# --- CONFIGURATION ---
REMOTE_IP="192.168.8.2" 
REMOTE_DEST="pve:/home/michael/University" # Updated to point to existing folder
LOCAL_HDD="/run/media/michael/Rem Backup/University_Backups/" 
SOURCE="/home/michael/Documents/University/" # Keep trailing slash to follow symlink
LATENCY_THRESHOLD=10.0 
LOG="/home/michael/cachyos-setup/sync.log"

echo "--- Sync Started: $(date) ---" >> $LOG

# --- 1. LOCAL EXTERNAL HDD SYNC ---
# Check if the WD Gaming Drive is mounted
if [ -d "/run/media/michael/Rem Backup/" ]; then
    echo "$(date) - WD Drive detected. Starting local backup..." >> $LOG
    rsync -avzuL --partial --delete \
        --exclude=".venv/" --exclude="__pycache__/" \
        "$SOURCE" "/run/media/michael/Rem Backup/University/" >> $LOG 2>&1
else
    echo "$(date) - WD Drive NOT found. Skipping local backup." >> $LOG
fi

# --- 2. REMOTE MINI-PC SYNC ---
# Check latency to the 'Brain'
LATENCY=$(ping -c 3 $REMOTE_IP | tail -1 | awk '{print $4}' | cut -d '/' -f 2)

if [ ! -z "$LATENCY" ] && (( $(echo "$LATENCY < $LATENCY_THRESHOLD" | bc -l) )); then
    echo "$(date) - Mini-PC detected (${LATENCY}ms). Starting network backup..." >> $LOG
    rsync -avzuL --partial --delete \
        --exclude=".venv/" --exclude="__pycache__/" \
        "$SOURCE" "$REMOTE_DEST" >> $LOG 2>&1
else
    echo "$(date) - Mini-PC unreachable or high latency. Skipping network backup." >> $LOG
fi

echo "--- All Sync Tasks Finished: $(date) ---" >> $LOG
