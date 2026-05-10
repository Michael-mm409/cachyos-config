#!/bin/zsh

echo "--- 1. Refreshing Mirrors ---"
sudo cachyos-rate-mirrors arch
sudo cachyos-rate-mirrors cachyos

echo "--- 2. Synchronizing & Upgrading ---"
sudo pacman -Syyu --noconfirm

echo "--- 3. Removing Micromamba ---"
# Silently try to remove the binary and folder if they exist
rm -f ~/.local/bin/micromamba 2>/dev/null
rm -rf ~/micromamba
# Clean up .zshrc only if the block exists
sed -i '/# >>> mamba initialize >>>/,/# <<< mamba initialize <<</d' ~/.zshrc

echo "--- 4. Ensuring Miniconda is Active ---"
# This points your shell to your miniconda3 install in /opt/
/opt/miniconda3/bin/conda init zsh

echo "--- 5. System Cleanup ---"
sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null
sudo paccache -r
# Use 'get-updates' first to see what's available
fwupdmgr get-updates

echo "--- Maintenance Complete! ---"
echo "Please restart your terminal to activate the Miniconda environment."
