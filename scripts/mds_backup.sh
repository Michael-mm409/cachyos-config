#!/bin/bash
# Michael's MDS Hybrid Backup (Daily Incremental / Weekly Full)
# Refactored: Two-Stage "Push then Purge" (Laptop = Absolute Source of Truth)

# --- 1. CONFIGURATION ---
if [ -d "/mnt/Data/University/" ]; then
    SOURCE="/mnt/Data/University/"
    SNAPSHOT_ROOT="/mnt/Data/University/snapshots"
    EXCLUDES="$HOME/fedora-config/scripts/rsync-excludes.txt"
elif [ -d "$HOME/Documents/University/" ]; then
    SOURCE="$HOME/Documents/University/"
    SNAPSHOT_ROOT="$HOME/Documents/University/snapshots"
    EXCLUDES="$HOME/fedora-config/scripts/rsync-excludes.txt"
else
    echo "⚠ CRITICAL ERROR: Could not locate University directory!"
    exit 1
fi

# --- DYNAMIC NETWORK ROUTING VALVE ---
if ping -c 1 -W 1 192.168.8.2 > /dev/null 2>&1; then
    echo "🏠 Connected to home network. Using fast direct IP."
    SSH_OPTS="-i /home/michael/.ssh/id_ed25519_desktop -o StrictHostKeyChecking=no"
    REMOTE_TARGET="michael@192.168.8.2:/home/michael/University/"
    SSH_HOST="192.168.8.2"
else
    echo "🚗 Away from home. Routing backup via Tailscale tunnel."
    SSH_OPTS="-i /home/michael/.ssh/id_ed25519_desktop"
    REMOTE_TARGET="michael@pve:/home/michael/University/"
    SSH_HOST="pve"
fi

# --- GUARDIAN LAYER: ANTI-WIPE VALVE ---
# If your laptop directory is missing or completely empty, STOP IMMEDIATELY.
if [ ! -d "$SOURCE" ] || [ -z "$(ls -A "$SOURCE" 2>/dev/null)" ]; then
    echo "⚠ CRITICAL ERROR: Laptop University path is missing or empty! Aborting to protect your data."
    exit 1
fi

# Double check that the Mini PC target folder actually exists before doing anything
if ! ssh $SSH_OPTS "michael@$SSH_HOST" "[ -d /home/michael/University/ ]"; then
    echo "⚠ CRITICAL ERROR: Remote target directory does not exist on Mini PC! Aborting."
    exit 1
fi

mkdir -p "$SNAPSHOT_ROOT"

# --- NEW GUARDIAN LAYER: PRE-BACKUP CONVERGENT PULL ---
echo "🔄 Phase 0: Checking for newer updates on the Mini PC hub..."
if [ -f "./mds_pull.sh" ]; then
    sh ./mds_pull.sh
    if [ $? -ne 0 ]; then
        echo "⚠ WARNING: Pre-backup pull failed or skipped. Proceeding cautiously..."
    else
        echo "✅ Pre-backup sync complete. Local directory is fully up to date."
    fi
else
    echo "ℹ INFO: mds_pull.sh not found in the current directory. Skipping pre-sync."
fi

# --- PHASE 1: SAFE ADDITIVE SYNC (LOCAL -> MINI PC) ---
echo "--- Step 1: Pushing New and Updated Data to Mini PC ---"

rsync -auv \
   -e "ssh $SSH_OPTS" \
   --exclude-from="$EXCLUDES" \
   --exclude="snapshots/" \
   "$SOURCE" "$REMOTE_TARGET"

if [ $? -ne 0 ]; then
   echo "⚠ CRITICAL: Step 1 Push failed! Aborting."
   exit 1
fi

echo "--- Step 1b: Purging Discarded Files on Mini PC ---"
# Leaves old attributes alone on the target unless the file itself explicitly changed
rsync -av --delete --existing \
   -e "ssh $SSH_OPTS" \
   --exclude-from="$EXCLUDES" \
   --exclude="snapshots/" \
   "$SOURCE" "$REMOTE_TARGET"


# --- PHASE 2: TWO-STAGE LOCAL USB VAULT SYNC (LAPTOP -> USB VAULT) ---
# Safety Check: Verify that the USB vault path is mounted/accessible
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
    echo "⏸ INFO: USB Vault (/mnt/MDS_VAULT/...) is not connected or mounted. Skipping Step 2."
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
    rsync -av -e "ssh $SSH_OPTS" --exclude="*.tar.gz" "$SNAPSHOT_ROOT/" "${REMOTE_TARGET}snapshots/"
fi

# --- PHASE 6: THE LAB CHAIN REACTION ---
echo "--- Step 6: Triggering Global Lab Sync on Remote Mini PC ---"
ssh $SSH_OPTS "michael@$SSH_HOST" "nohup /home/michael/scripts/global_lab_sync.sh > /dev/null 2>&1 &"

echo "Last Global Sync: $(date)" > "${SOURCE}sync_status.txt"
