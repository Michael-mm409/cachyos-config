#!/bin/bash

# Ensure system is updated and install the Nord components
echo "Installing CachyOS Nord components and Qogir icons..."
sudo pacman -Syu --needed \
    cachyos-nord-kde-git \
    cachyos-nord-gtk-theme-git \
    qogir-icon-theme \
    kdeplasma-addons

# Optional: Install Kvantum for better transparency control
echo "Installing Kvantum for advanced theming..."
sudo pacman -S --needed kvantum

# Create local icon directory if it doesn't exist
mkdir -p "$HOME/.local/share/icons"

# Copy custom icons from your repo to the system
if [ -d "./Icons" ]; then
    echo "🎨 Installing custom local icons..."
    cp -r ./Icons/* "$HOME/.local/share/icons/"
else
    echo "⚠️  No local Icons/ directory found to copy."
fi

echo "--------------------------------------------------------"
echo "INSTALLATION COMPLETE"
echo "Next Steps to apply the look:"
echo "1. Go to System Settings > Colors & Themes > Global Theme."
echo "2. Select 'CachyOS Nord'."
echo "3. Go to Icons and select 'Qogir-dark'."
echo "--------------------------------------------------------"

