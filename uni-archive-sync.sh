#!/bin/bash
# uni-archive-sync.sh - Michael's WebDAV Backup for CachyOS (Btrfs Optimized)

SOURCE="$HOME/Documents/University"
DEST="nas_direct:/home/Documents/University"
ARCHIVE_ROOT="nas_direct:/home/Documents/University_Archive"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)

echo "🚀 Starting University Archive Sync to $DEST..."

# 1. Direct rclone sync
# Added --fast-list to speed up Synology WebDAV indexing
# Added --transfers 4 to balance speed vs Synology CPU load
rclone sync "$SOURCE" "$DEST" \
    -L \
    --one-file-system \
    --fast-list \
    --transfers 4 \
    --exclude "Synology_Home/**" \
    --exclude ".conda/**" \
    --exclude "**/__pycache__/**" \
    --exclude ".direnv/**" \
    --backup-dir "$ARCHIVE_ROOT/$TIMESTAMP" \
    --ignore-errors \
    --progress

# 2. Rotation: Keep only last 5 versions
echo "🔄 Rotating archives (keeping last 5)..."

# List directories, sort them (newest first), skip the first 5, delete the rest
OLD_ARCHIVES=$(rclone lsf "$ARCHIVE_ROOT" --dirs-only | sort -r | tail -n +6)

if [ -n "$OLD_ARCHIVES" ]; then
    echo "$OLD_ARCHIVES" | while read -r dir; do
        # Strip trailing slash for purge command safety
        CLEAN_DIR="${dir%/}"
        echo "🗑️ Deleting old archive: $CLEAN_DIR"
        rclone purge "$ARCHIVE_ROOT/$CLEAN_DIR"
    done
else
    echo "✅ Archive count is within limits (5 or fewer)."
fi

echo "🏁 Backup Process Finished."
