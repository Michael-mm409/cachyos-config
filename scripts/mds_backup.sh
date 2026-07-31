#!/bin/bash
# Michael's MDS Hybrid Backup (Daily Incremental / Weekly Full)
# Refactored: Environment-driven configuration with Bidirectional Sync

# --- 0. SOURCE ENVIRONMENT CONFIGURATION ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/mds_backup.env"

if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "⚠ CRITICAL ERROR: Configuration file '$ENV_FILE' not found! Aborting."
    exit 1
fi

# Set runtime variables derived from configuration
DOW=$(date +%u)
TIMESTAMP=$(date +%Y%m%d)

# --- 1. NETWORK TARGET SETUP (MagicDNS) ---
SSH_OPTS="-i ${SSH_KEY}"
SSH_HOST="${REMOTE_HOST}"
REMOTE_TARGET="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
REMOTE_CHECK_DIR="${REMOTE_PATH}"

# --- GUARDIAN LAYER: ANTI-WIPE VALVE ---
if [ ! -d "$SOURCE" ] || [ -z "$(ls -A "$SOURCE" 2>/dev/null)" ]; then
    echo "⚠ CRITICAL ERROR: Laptop University path is missing or empty! Aborting to protect your data."
    exit 1
fi

if ! ssh $SSH_OPTS "${REMOTE_USER}@${SSH_HOST}" "[ -d '${REMOTE_CHECK_DIR}' ]"; then
    echo "⚠ CRITICAL ERROR: Remote target directory does not exist on Mini PC! Aborting."
    exit 1
fi

mkdir -p "$SNAPSHOT_ROOT"

# --- PHASE 1: THREE-STAGE BIDIRECTIONAL MINI PC SYNC ---

echo "--- Step 1a: Pulling New/Updated Data from Mini PC ---"
eval rsync -av -u \
    -e '"ssh '$SSH_OPTS'"' \
    --exclude-from="$EXCLUDES" \
    --exclude="snapshots/" \
    "$REMOTE_TARGET" "$SOURCE"

if [ $? -ne 0 ]; then
    echo "⚠ CRITICAL: Step 1a Pull failed! Aborting to prevent data inconsistency."
    exit 1
fi

echo "--- Step 1b: Pushing New/Updated Data to Mini PC ---"
eval rsync -cv \
    -e '"ssh '$SSH_OPTS'"' \
    --exclude-from="$EXCLUDES" \
    --exclude="snapshots/" \
    "$SOURCE" "$REMOTE_TARGET"

if [ $? -ne 0 ]; then
    echo "⚠ CRITICAL: Step 1b Push failed! Skipping cleanup step to protect data."
    exit 1
fi

echo "--- Step 1c: Purging Discarded Files on Mini PC ---"
eval rsync -av --delete --existing \
    -e '"ssh '$SSH_OPTS'"' \
    --exclude-from="$EXCLUDES" \
    --exclude="snapshots/" \
    "$SOURCE" "$REMOTE_TARGET"

# --- PHASE 2: TWO-STAGE LOCAL USB VAULT SYNC (LAPTOP -> USB VAULT) ---
if [ -d "$LOCAL_VAULT" ]; then
    echo "--- Step 2a: Pushing New/Updated Data to USB Vault ---"
    rsync -av --exclude="snapshots/" --exclude-from="$EXCLUDES" "$SOURCE" "$LOCAL_VAULT/Live_Work/"

    if [ $? -eq 0 ]; then
        echo "--- Step 2b: Purging Discarded Files on USB Vault ---"
        rsync -av --delete --existing --exclude="snapshots/" --exclude-from="$EXCLUDES" "$SOURCE" "$LOCAL_VAULT/Live_Work/"
    else
        echo "⚠ WARNING: USB Vault push failed! Skipping cleanup."
    fi
else
    echo "⏸ INFO: USB Vault ($LOCAL_VAULT) is not connected or mounted. Skipping Step 2."
fi

# --- PHASE 3: CATCH-UP ARCHIVING ---
RECENT_FULL=$(find "$SNAPSHOT_ROOT" -name "MDS_Full_Snapshot_*.tar.gz" -mtime -6 2>/dev/null)

# --- PHASE 4: THE HYBRID ARCHIVE LOGIC ---
if [ "$DOW" -eq 7 ] || [ -z "$RECENT_FULL" ]; then
    echo "--- Triggering FULL Weekly Archive ---"
    BACKUP_NAME="MDS_Full_Snapshot_$TIMESTAMP.tar.gz"

    tar -I pigz -cf "$SNAPSHOT_ROOT/$BACKUP_NAME" \
        --exclude='./snapshots' \
        -C "$SOURCE" .

    find "$SNAPSHOT_ROOT" -maxdepth 1 -name "MDS_Daily_*" -type d -mtime +4 -exec rm -rf {} +
else
    echo "--- Triggering Incremental Hard-Link Snapshot ---"
    DEST="$SNAPSHOT_ROOT/MDS_Daily_$TIMESTAMP"
    LATEST="$SNAPSHOT_ROOT/latest"

    rsync -av --delete \
        --link-dest="$LATEST" \
        --exclude 'snapshots/' \
        --exclude-from="$EXCLUDES" \
        "$SOURCE" "$DEST"

    rm -f "$LATEST" && ln -s "$DEST" "$LATEST"
    find "$SNAPSHOT_ROOT" -maxdepth 1 -name "MDS_Daily_*" -type d -mtime +7 -exec rm -rf {} +
fi

# --- PHASE 5: SNAPSHOT ARCHIVE PIPELINE ---
if [ -d "$LOCAL_VAULT" ]; then
    echo "--- Syncing Local Snapshots to USB Vault ---"
    mkdir -p "${LOCAL_VAULT}snapshots/"
    eval rsync -av -e '"ssh '$SSH_OPTS'"' --exclude="*.tar.gz" "$SNAPSHOT_ROOT/" "${REMOTE_TARGET}snapshots/"
fi

# --- PHASE 6: THE LAB CHAIN REACTION ---
echo "--- Step 6: Triggering Global Lab Sync on Remote Mini PC ---"
eval ssh $SSH_OPTS "${REMOTE_USER}@${SSH_HOST}" '"nohup '$REMOTE_SYNC_SCRIPT' > /dev/null 2>&1 &"'

echo "Last Global Sync: $(date)" > "$STATUS_FILE"
