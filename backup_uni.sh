#!/bin/bash

# --- CONFIGURATION ---
# We use the standard home path since you are now inside the system
SOURCE="/home/michael/"
DEST="/run/media/michael/Ventoy/michael_backup/"
MOUNT_POINT="/run/media/michael/Ventoy"
DEVICE="/dev/sda1"

echo "------------------------------------------"
echo "  USQ Masters Data Science - Backup Sync  "
echo "------------------------------------------"

# 1. MOUNT CHECK
# This checks if the USB is already mounted (e.g., by the file manager)
if ! mountpoint -q "$MOUNT_POINT"; then
    echo "[*] USB not detected at $MOUNT_POINT. Attempting manual mount..."
    sudo mount "$DEVICE" "$MOUNT_POINT" || { echo "[!!] Error: Plug in the USB drive."; exit 1; }
fi

# 2. RUN RSYNC
# Optimized flags: 
# -a (archive), -h (human readable), -P (progress + partial)
# --delete: Removes files from backup if you deleted them from Home (Keep things synced)
echo "[*] Syncing Documents and Code..."
rsync -ahP --delete \
    --exclude=".cache" \
    --exclude=".local/share/Trash" \
    --exclude=".thumbnails" \
    --exclude="__pycache__" \
    --exclude=".ipynb_checkpoints" \
    "$SOURCE" "$DEST"

# 3. VERIFICATION
echo "[*] Verifying file integrity..."
SRC_COUNT=$(find "${SOURCE}Documents/University/" -type f | wc -l)
DEST_COUNT=$(find "${DEST}Documents/University/" -type f | wc -l)

echo "    Local Files:  $SRC_COUNT"
echo "    Backup Files: $DEST_COUNT"

if [ "$SRC_COUNT" -eq "$DEST_COUNT" ]; then
    echo "[SUCCESS] University folder is 100% synced."
else
    echo "[!] Mismatch! Check for open files or permission issues."
fi

# 4. FINISH
echo "[*] Syncing hardware..."
sync
echo "[DONE] Backup complete. You can safely unmount via file manager or 'umount $MOUNT_POINT'."
