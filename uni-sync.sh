#!/bin/bash
# --- Settings ---
SOURCE="/home/michael/Documents/University/"
HDD_DEST="/run/media/michael/Rem Backup/University/"
REMOTE_IP="192.168.8.10"
REMOTE_DEST="michael@$REMOTE_IP:/home/michael/University/"
LOG="/home/michael/cachyos-config/sync.log"

# --- 1. LOCAL HDD SYNC ---
if [ -d "$HDD_DEST" ]; then
    echo "$(date) - [HDD] Syncing to External Drive..." >> "$LOG"
    rsync -avzuL --partial --delete --stats --human-readable "$SOURCE" "$HDD_DEST" >> "$LOG" 2>&1
fi

# --- 2. LAN CHECK (Only .3 or .8) ---
CURRENT_IP=$(hostname -I | awk '{print $1}')

if [[ $CURRENT_IP == 192.168.8.* ]] || [[ $CURRENT_IP == 192.168.3.* ]]; then
    echo "$(date) - [LAN] $CURRENT_IP detected. Fast connection confirmed." >> "$LOG"
    
    # Catch-up: HDD to Brain
    if [ -d "$HDD_DEST" ]; then
        rsync -avzuL --partial "$HDD_DEST" "$REMOTE_DEST" >> "$LOG" 2>&1
    fi

    # Finalize: Local to Brain
    rsync -avzuL --partial "$SOURCE" "$REMOTE_DEST" >> "$LOG" 2>&1
else
    # This is where you'll be at your dad's or Canberra
    echo "$(date) - [REMOTE] Slow or Unknown Network. Skipping Mini-PC to save bandwidth." >> "$LOG"
fi
