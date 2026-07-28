#!/bin/bash
# Michael's MDS Pull Script: Fetch latest files from Mini PC to local machine

# --- DYNAMIC LOCAL PATH DETECTION ---
if [ -d "/mnt/Data/University/" ]; then
    LOCAL_TARGET="/mnt/Data/University/"
    EXCLUDES="$SCRIPT_DIR/rsync-excludes.txt"
elif [ -d "$HOME/Documents/University/" ]; then
    LOCAL_TARGET="$HOME/Documents/University/"
    EXCLUDES="$SCRIPT_DIR/rsync-excludes.txt"
else
    echo "⚠ CRITICAL ERROR: Local University path does not exist. Create it first!"
    exit 1
fi

# --- DYNAMIC ROUTING (Local LAN vs Tailscale) ---
if ping -c 3 -W 2 192.168.8.2 > /dev/null 2>&1; then
    echo "🏠 Connected to home network. Using fast direct IP."
    SSH_OPTS="-i /home/michael/.ssh/id_ed25519_desktop" # Fixed key path too
    REMOTE_SOURCE="michael@192.168.8.2:/home/michael/University/"
else
    echo "🚗 Away from home. Routing pull via Tailscale tunnel."
    SSH_OPTS="-i /home/michael/.ssh/id_ed25519_desktop"
    REMOTE_SOURCE="michael@pve:/home/michael/University/"
fi

echo "--- Pulling latest files from Mini PC to Local Machine ---"
# -a (archive), -u (update: only grab files newer on remote or missing locally), -v (verbose)
rsync -auv \
    -e "ssh $SSH_OPTS" \
    --exclude-from="$EXCLUDES" \
    --exclude="snapshots/" \
    "$REMOTE_SOURCE" "$LOCAL_TARGET"

if [ $? -eq 0 ]; then
    echo "✅ Pull complete! Your local machine is now up to date."
else
    echo "⚠ CRITICAL ERROR: Pull failed!"
    exit 1
fi
