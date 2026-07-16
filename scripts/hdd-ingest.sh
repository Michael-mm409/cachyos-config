#!/bin/bash
# Michael's Desktop -> MDS Ingest Logic
# BTRFS Vault (HDD) -> Desktop -> Global 4-3-2-1 Hub

# --- 1. CONFIGURATION ---
HDD_SOURCE="/mnt/MDS_VAULT/University_Vault/Live_Work/"
LOCAL_TARGET="/mnt/Data/University/"

if mountpoint -q "/mnt/MDS_VAULT"; then
    echo "--- Phase 1: Ingesting Laptop Data to Desktop ---"
    
    # -a: archive, -v: verbose, -u: update (safety), --delete: mirror removals
    # Update this line in your script
    rsync -avu --delete --exclude='snapshots/' "$HDD_SOURCE" "$LOCAL_TARGET"

    echo "--- Phase 2: Triggering Master 4-3-2-1 Chain Reaction ---"
    if [ -f "/home/michael/scripts/mds_backup.sh" ]; then
        # This pushes to PVE, Synology, and Google Drive
        /home/michael/scripts/mds_backup.sh
    else
        echo "Warning: mds_backup.sh not found."
    fi
    
    notify-send "MDS Vault" "Ingest Complete! All systems synced." --icon=drive-harddisk
else
    echo "ERROR: BTRFS HDD not detected at /mnt/MDS_VAULT"
fi
