#!/bin/bash
# uni-archive-sync.sh - Michael's USQ Data Science Backup

SOURCE="$HOME/Documents/University"
DEST="nas_direct:/University"
ARCHIVE_ROOT="nas_direct:/University_Archive"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)

echo "🚀 Starting University Archive Sync to $DEST..."

# 1. Direct rclone sync
rclone sync "$SOURCE" "$DEST" \
    -L \
    --one-file-system \
    --fast-list \
    --transfers 4 \
    --exclude "Synology_Home/**" \
    --exclude ".conda/**" \
    --exclude "**/__pycache__/**" \
    --exclude ".venv/**" \
    --exclude ".direnv/**" \
    --backup-dir "$ARCHIVE_ROOT/$TIMESTAMP" \
    --ignore-errors \
    --progress

# 2. SAFER ROTATION (The Insurance Policy)
echo "🔄 Rotating archives (keeping last 5)..."

# This grep ensures we ONLY look at timestamped folders starting with "20"
OLD_ARCHIVES=$(rclone lsf "$ARCHIVE_ROOT" --dirs-only | grep "^20" | sort -r | tail -n +6)

if [ -n "$OLD_ARCHIVES" ]; then
    echo "$OLD_ARCHIVES" | while read -r dir; do
        CLEAN_DIR="${dir%/}"
        echo "🗑 Deleting old archive: $CLEAN_DIR"
        rclone purge "$ARCHIVE_ROOT/$CLEAN_DIR"
    done
else
    echo "✅ No old archives to rotate."
fi

echo "🏁 Backup Process Finished."
