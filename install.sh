#!/bin/bash

REPO_DIR="$HOME/cachyos-config"
HOSTNAME=$(hostname)

echo "🚀 Environment Restore for: $HOSTNAME"

# 1. SSH Configuration Pick-and-Place
echo "🔑 Selecting SSH profile for $HOSTNAME..."
mkdir -p ~/.ssh

if [[ "$HOSTNAME" == *"laptop"* ]]; then
    cp "$REPO_DIR/ssh_config_laptop" ~/.ssh/config
    echo "✅ Applied Laptop SSH Profile"
elif [[ "$HOSTNAME" == *"desktop"* ]]; then
    cp "$REPO_DIR/ssh_config_desktop" ~/.ssh/config
    echo "✅ Applied Desktop SSH Profile"
else
    echo "⚠️ Unknown host ($HOSTNAME). Manual SSH setup required."
fi
chmod 600 ~/.ssh/config

# 2. Fish Configuration (Syncing Aliases & Prompts)
echo "🐟 Syncing Fish configuration..."
mkdir -p ~/.config/fish
if [ -f "$REPO_DIR/config.fish" ]; then
    # Backup existing config if it's not a link or already managed
    cp ~/.config/fish/config.fish ~/.config/fish/config.fish.bak 2>/dev/null
    cp "$REPO_DIR/config.fish" ~/.config/fish/config.fish
    echo "✅ Fish config updated from repo"
else
    echo "⚠️ config.fish not found in repo, skipping..."
fi

# 3. Systemd Integration
echo "⚙️ Linking Systemd units..."
sudo ln -sf "$REPO_DIR/systemd/uni-sync.service" /etc/systemd/system/uni-sync.service
sudo ln -sf "$REPO_DIR/systemd/uni-sync.timer" /etc/systemd/system/uni-sync.timer

sudo systemctl daemon-reload
sudo systemctl enable --now uni-sync.timer

echo "✅ Deployment complete for $HOSTNAME."
