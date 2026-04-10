#!/bin/bash
# Michael's Master of Data Science - Clean Sync

SOURCE_UNI="/home/michael/Documents/University/"
SOURCE_CODE="/home/michael/Code/"
DEST_DIR="/mnt/External_Backup/Desktop_Sync"
MOUNT_POINT="/mnt/External_Backup"

echo "------------------------------------------"
echo "  USQ Masters Data Science - Clean Sync   "
echo "------------------------------------------"

# 1. MOUNT CHECK (Updated with ownership)
if ! mountpoint -q "$MOUNT_POINT"; then
    echo "[*] USB not found. Attempting mount..."
    # Get your current UID and GID (usually 1000)
    USER_ID=$(id -u)
    GROUP_ID=$(id -g)
    
    # Mount with explicit ownership for your user
    sudo mount -o uid=$USER_ID,gid=$GROUP_ID /dev/sda1 "$MOUNT_POINT" || { echo "[!!] Error: Plug in USB."; exit 1; }
fi

# 2. RUN TARGETED RSYNC (Avoiding System Loops)
echo "[*] Syncing University Data (Follows portal to 2TB drive)..."
# Changed -ahPL to -rtvhPL --no-g --no-o
# Updated rsync line for external drives
rsync -rtvhPL -O --no-g --no-o --delete "$SOURCE_UNI" "$DEST_DIR/University/"

if [ -d "$SOURCE_CODE" ]; then
    echo "[*] Syncing Code projects..."
    rsync -rtvhPL --no-g --no-o --delete "$SOURCE_CODE" "$DEST_DIR/Code/"
fi

# 3. VERIFICATION (Uses the Physical ADATA Path)
echo "[*] Verifying University integrity..."
SRC_COUNT=$(find "$SOURCE_UNI" -type f | wc -l)
DEST_COUNT=$(find "$DEST_DIR/University/" -type f | wc -l)

echo "    Source (ADATA): $SRC_COUNT files"
echo "    Backup (USB):   $DEST_COUNT files"

if [ "$SRC_COUNT" -eq "$DEST_COUNT" ] && [ "$SRC_COUNT" -gt 0 ]; then
    echo "[SUCCESS] University work is safely mirrored."
else
    echo "[!] Mismatch! Check if the script finished or if files are locked."
fi

# 4. FINISH
sync
echo "[DONE] Backup process complete."
