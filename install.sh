#!/bin/bash

REPO_DIR="$HOME/cachyos-setup"
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

# 2. Systemd Integration
echo "⚙️ Linking Systemd units..."
sudo ln -sf "$REPO_DIR/systemd/uni-sync.service" /etc/systemd/system/uni-sync.service
sudo ln -sf "$REPO_DIR/systemd/uni-sync.timer" /etc/systemd/system/uni-sync.timer

sudo systemctl daemon-reload
sudo systemctl enable --now uni-sync.timer

echo "✅ Deployment complete for $HOSTNAME."
