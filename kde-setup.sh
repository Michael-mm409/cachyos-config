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

echo "--------------------------------------------------------"
echo "INSTALLATION COMPLETE"
echo "Next Steps to apply the look:"
echo "1. Go to System Settings > Colors & Themes > Global Theme."
echo "2. Select 'CachyOS Nord'."
echo "3. Go to Icons and select 'Qogir-dark'."
echo "--------------------------------------------------------"

