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

# 1. Ensure the local icon path exists and copy your files
mkdir -p "$HOME/.local/share/icons"
if [ -d "./Icons" ]; then
    echo "🎨 Deploying custom icons from repository..."
    cp -r ./Icons/* "$HOME/.local/share/icons/"
fi

# 2. Force KDE to refresh the icon cache
# This is often the missing step when icons look 'broken'
echo "🔄 Refreshing icon cache..."
gtk-update-icon-cache -f -t "$HOME/.local/share/icons" 2>/dev/null
kbuildsycoca6 --noincremental

# 3. Apply the theme via CLI (Ensures consistency across the panel)
# Change 'Qogir-dark' to the folder name inside your Icons/ directory
kwriteconfig6 --file kdeglobals --group Icons --key Theme "Qogir-dark"

echo "--------------------------------------------------------"
echo "INSTALLATION COMPLETE"
echo "Next Steps to apply the look:"
echo "1. Go to System Settings > Colors & Themes > Global Theme."
echo "2. Select 'CachyOS Nord'."
echo "3. Go to Icons and select 'Qogir-dark'."
echo "--------------------------------------------------------"

