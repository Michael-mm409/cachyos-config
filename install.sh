#!/bin/bash

echo "🚀 Starting Full CachyOS Environment Restore..."

# 1. Fix Ownership & Permissions
echo "🔐 Repairing permissions..."
sudo chown -R michael:michael ~/cachyos-setup/
chmod +x ~/cachyos-setup/*.sh

# 2. SSH Configuration
echo "🔑 Setting up SSH config..."
mkdir -p ~/.ssh
cp ~/cachyos-setup/ssh_config ~/.ssh/config
chmod 600 ~/.ssh/config

# 3. Systemd Units (The Backup Engine)
echo "⚙️ Linking Systemd units..."
sudo ln -sf ~/cachyos-setup/uni-sync.service /etc/systemd/system/uni-sync.service
sudo ln -sf ~/cachyos-setup/uni-sync.timer /etc/systemd/system/uni-sync.timer

# 4. Shell Environment (Fish)
echo "🐟 Configuring Fish shell (EDITOR=micro)..."
mkdir -p ~/.config/fish
if ! grep -q "EDITOR micro" ~/.config/fish/config.fish; then
    echo 'set -gx EDITOR micro' >> ~/.config/fish/config.fish
    echo 'set -gx VISUAL micro' >> ~/.config/fish/config.fish
fi

# 5. Reload and Fire
echo "🔄 Reloading system services..."
sudo systemctl daemon-reload
sudo systemctl enable --now uni-sync.timer

echo "✅ ALL SYSTEMS OPERATIONAL"
echo "-----------------------------------------------"
systemctl list-timers uni-sync.timer
