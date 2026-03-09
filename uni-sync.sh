#!/bin/bash
# uni-sync.sh - Michael's Manual rsync Fallback (CachyOS/Btrfs Edition)

LOCAL_DIR="$HOME/Documents/University"
REMOTE_DIR="/mnt/proxmox_uni"

echo "🔍 Checking Proxmox Mount ($REMOTE_DIR)..."

# 1. Trigger the systemd automount & Check Connectivity
# We check for a specific directory to ensure it's actually MOUNTED, not just an empty folder
if ! mountpoint -q "$REMOTE_DIR"; then
    echo "⚙️  Triggering automount..."
    ls "$REMOTE_DIR" &>/dev/null
    sleep 1 # Give systemd a second to catch up
fi

if [ ! -d "$REMOTE_DIR" ] || [ -z "$(ls -A "$REMOTE_DIR")" ]; then
    echo "❌ Proxmox University mount not reachable or empty. Is Tailscale up?"
    exit 1
fi

# 2. Two-way sync (Pull then Push)
# Added --modify-window=1 to prevent "false positive" re-copies on network shares
# Added --delete to keep things clean (optional, remove if you want to keep deleted files)
COMMON_FLAGS="-avzu --no-perms --no-owner --no-group --modify-window=1 --exclude=.conda/ --exclude=__pycache__/"

echo "📥 [1/2] Pulling updates from Proxmox..."
rsync $COMMON_FLAGS "$REMOTE_DIR/" "$LOCAL_DIR/"

echo "📤 [2/2] Pushing local changes to Proxmox..."
rsync $COMMON_FLAGS "$LOCAL_DIR/" "$REMOTE_DIR/"

echo "✅ Manual sync complete."
