# CachyOS-config

# CachyOS-Setup

**Overview** — Brief description of what this repo does (CachyOS system setup with multi-device support and uni file syncing)

## 📋 Quick Start

### Prerequisites
- **CachyOS** installed (Arch-based distribution)
- **Sudo access** (required for system updates and service management)
- **Internet connection** (for package downloads)
- **Tailscale account** (for NAS/Proxmox access) — [Sign up free](https://tailscale.com)
- **Git** (for cloning this repo)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/cachyos-setup.git
   cd cachyos-setup
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x *.sh hosts/*.sh
   ```

3. **Run the main setup:**
   ```bash
   ./setup-cachyos.sh
   ```
   The script will automatically:
   - Detect your device type (desktop/laptop)
   - Install essentials and Tailscale
   - Run hardware-specific configuration
   - Install applications (Brave, VS Code, Discord, etc.)
   - Prompt you to authenticate with Tailscale

4. **Optional: Set up uni-sync scheduling**
   - Edit `smart-resume.sh` with your hub IP if needed
   - Add to crontab for automatic syncing

## 📁 Project Structure
- `setup-cachyos.sh` — Main entry point, auto-detects device and runs hardware-specific configs
- `hosts/` — Device-specific configurations (desktop, laptop)
- `uni-sync.sh` — University file sync utility
- `uni-archive-sync.sh` — Archive-specific syncing
- `backup_uni.sh` — Backup creation
- `smart-resume.sh` — Resume functionality

## 🚀 Available Scripts

### Core Setup
- **setup-cachyos.sh** — Initialize system, install essentials, Tailscale, then run device-specific script

### Device-Specific
- **hosts/desktop.sh** — GPU drivers (NVIDIA), gaming optimization, CUDA
- **hosts/laptop.sh** — Laptop power management, etc.

### University File Sync
- **uni-sync.sh** — Two-way rsync with Proxmox
- **uni-archive-sync.sh** — Archive/backup syncing
- **backup_uni.sh** — Create backups

### Utilities
- **smart-resume.sh** — [Add description]

## 🔧 Hardware Support
List your supported devices and what makes them special

## 🌐 Dependencies

### System Requirements
- **CachyOS** (Arch-based Linux distribution)
- **Sudo access** for system-level changes
- **Pacman** (CachyOS package manager)
- **Paru** (AUR helper, will be available after setup)

### Core CLI Tools
*(Automatically installed by `setup-cachyos.sh`)*
- `tailscale` — VPN for NAS/Proxmox connectivity
- `rsync` — File synchronization
- `git`, `curl`, `wget` — Networking & version control
- `bc` — Calculator (for latency math in smart-resume.sh)
- `nfs-utils` — NFS mounting for network shares
- `direnv` — Directory-specific environment management
- `rclone` — Cloud storage sync

### Hardware-Specific

**Desktop (RTX 5070 Ti):**
- `nvidia-cachyos-dkms` — NVIDIA GPU drivers (auto-rebuilds with kernel)
- `cuda` — NVIDIA CUDA toolkit
- `lib32-nvidia-utils-cachyos` — 32-bit GPU support
- `cachyos-gaming-meta` — Gaming optimization suite

**Laptop (IdeaPad):**
- `auto-cpufreq` — CPU frequency scaling
- `power-profiles-daemon` — Power profile management

### Applications
*(Installed by `setup-cachyos.sh` via AUR)*
- `brave-bin` — Privacy-focused browser
- `visual-studio-code-bin` — Code editor
- `betterbird-bin` — Email client (Thunderbird fork)
- `discord` — Communication
- `obsidian` — Note-taking
- `zoom` — Video conferencing

### Optional: Mutagen (for smart-resume.sh)
- `mutagen` — File sync daemon (required for latency-aware syncing)
- `iputils` — Ping utility for network diagnostics

### Network Requirements
- **Tailscale VPN** — Access to Proxmox NAS (University files)
- **Synology** system — Optional for additional backups

## 📖 Usage

### Initial System Setup
Run once after installing CachyOS:
```bash
./setup-cachyos.sh
```
This handles everything: system updates, Tailscale, device-specific config, and app installation.

### University File Sync

**Manual two-way sync (Pull then Push):**
```bash
./uni-sync.sh
```
Syncs between `~/Documents/University/` and Proxmox NAS at `/mnt/proxmox_uni`. Safe flags prevent permission issues and false re-copies over network shares.

**Archive-specific syncing:**
```bash
./uni-archive-sync.sh
```
Backup or sync archived university data (adjust paths as needed).

### Backups

**Create a backup to USB/external drive:**
```bash
./backup_uni.sh
```
Backs up your home directory to a USB drive at `/run/media/michael/Ventoy/michael_backup/`. Automatically:
- Detects and mounts the USB if not already mounted
- Excludes cache, trash, and Python bytecode
- Shows progress with human-readable sizes
- Syncs deletions (keeps backup up-to-date)

### Smart Resume (Latency-Aware Syncing)

**Automatic sync based on network proximity:**
```bash
./smart-resume.sh
```
Checks latency to your home network hub. If under 10ms (home), resumes Mutagen sync. If higher (remote), pauses to preserve bandwidth.

**Set up automatic checks via cron (every 5 minutes):**
```bash
(crontab -l 2>/dev/null; echo "*/5 * * * * ~/cachyos-setup/smart-resume.sh") | crontab -
```

### Device-Specific Configuration

**Laptop optimization:**
```bash
./hosts/laptop.sh
```
Enables battery conservation (80% threshold), CPU frequency scaling, touchpad tap-to-click.

**Desktop gaming setup:**
```bash
./hosts/desktop.sh
```
Installs NVIDIA drivers, CUDA, enables GPU power management.

### Manual Network Setup (Troubleshooting)

**Check Tailscale status:**
```bash
tailscale status
```

**Manually authenticate with Tailscale:**
```bash
sudo tailscale up --operator=$USER
```

**Mount Proxmox NAS manually:**
```bash
ls /mnt/proxmox_uni  # Triggers automount
```

**Test network latency to hub:**
```bash
ping -c 1 100.70.100.118  # Replace with your hub IP
```

## 🐛 Troubleshooting

### Setup Script Issues

#### Problem: `chmod: permission denied` when making scripts executable
```bash
# Solution: Use full paths or ensure you're in the correct directory
cd ~/cachyos-setup
chmod +x *.sh hosts/*.sh
```

#### Problem: `setup-cachyos.sh` not detecting device type (desktop/laptop)
```bash
# Verify your device chassis type
hostnamectl chassis

# If incorrect, manually run the appropriate script:
./hosts/desktop.sh    # For desktop
./hosts/laptop.sh     # For laptop
```

#### Problem: `paru: command not found`
```bash
# Paru is installed during setup, but if missing, install manually:
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru && makepkg -si
```

---

### Tailscale & Network Issues

#### Problem: `Tailscale login required` keeps appearing
```bash
# Ensure Tailscale service is running
sudo systemctl status tailscaled

# If not, start it:
sudo systemctl enable --now tailscaled

# Manual authentication (if auto-prompt fails):
sudo tailscale up --operator=$USER
# Follow the URL it prints
```

#### Problem: `tailscale status` shows disconnected or "*Stopped*"
```bash
# Restart the Tailscale service
sudo systemctl restart tailscaled

# Wait a few seconds and check again
tailscale status
```

#### Problem: `Proxmox mount not reachable`
```bash
# 1. Check if Tailscale is connected
tailscale status

# 2. Test latency to your NAS/hub (use your actual IP)
ping 100.70.100.118

# 3. Check if mount point exists and is empty
ls -la /mnt/proxmox_uni

# 4. Try manual mount trigger
ls /mnt/proxmox_uni  # This triggers systemd automount

# 5. If still failing, check dmesg for NFS errors
dmesg | tail -20
```

---

### File Sync Issues

#### Problem: `uni-sync.sh` reports "Proxmox University mount not reachable or empty"`
```bash
# Solution: Ensure Tailscale is online and NAS is accessible
tailscale status
ping 100.70.100.118

# Then retry sync
./uni-sync.sh
```

#### Problem: Files sync but then immediately re-sync (false positives)
```bash
# This is usually time skew on network shares
# The script already uses --modify-window=1 to compensate
# If still happening, check NAS clock:
ssh user@nas-ip 'date'  # Compare with your system time
```

#### Problem: Sync is slow or times out
```bash
# Check network speed
iperf3 -c 100.70.100.118  # If iperf3 server running on NAS

# Manually sync with verbose output to see where it hangs
rsync -avzu --modify-window=1 /mnt/proxmox_uni/ ~/Documents/University/
```

---

### Backup & USB Issues

#### Problem: `backup_uni.sh` reports "Error: Plug in the USB drive"`
```bash
# 1. Check if USB is detected
lsblk  # Look for your USB device

# 2. If detected but not mounted, mount manually
sudo mount /dev/sda1 /run/media/michael/Ventoy

# 3. If mount point doesn't exist, create it
sudo mkdir -p /run/media/michael/Ventoy
sudo mount /dev/sda1 /run/media/michael/Ventoy

# 4. Verify the backup destination exists
mkdir -p /run/media/michael/Ventoy/michael_backup
```

#### Problem: `rsync: write failed` during backup
```bash
# Likely USB is full or read-only
# Check USB space:
df -h /run/media/michael/Ventoy

# Check if USB is write-protected (physically check the switch)

# If USB is full, remove old backups:
rm -rf /run/media/michael/Ventoy/michael_backup_old/
```

#### Problem: USB doesn't automount after plugging in
```bash
# Manually trigger mount
sudo mount /dev/sda1 /run/media/michael/Ventoy

# If that works, your automount config may need adjustment
# Check fstab or udev rules (advanced troubleshooting)
```

---

### Laptop-Specific Issues

#### Problem: Battery conservation mode not working (IdeaPad)
```bash
# Check if the sysfs path exists
cat /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode

# If path doesn't exist, check alternative
find /sys -name "conservation_mode" 2>/dev/null

# Manually enable if path is different
echo 1 | sudo tee /sys/path/to/conservation_mode
```

#### Problem: CPU frequency scaling not working
```bash
# Verify auto-cpufreq is running
sudo systemctl status auto-cpufreq

# If not, restart it
sudo systemctl restart auto-cpufreq

# Check current governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

#### Problem: Touchpad tap-to-click not enabled
```bash
# KDE method 1: Open KDE Touchpad settings GUI
kcmshell5 kcm_touchpad

# KDE method 2: Edit config directly
# Add to ~/.config/touchpadrc if it doesn't exist
mkdir -p ~/.config
echo -e "[Touchpad]\nTapToClick=true" >> ~/.config/touchpadrc

# Verify it's set
cat ~/.config/touchpadrc | grep TapToClick
```

---

### Desktop/GPU Issues

#### Problem: NVIDIA driver `not found` or `CUDA not installing`
```bash
# Wait for kernel to finish rebuilding (can take 5-10 minutes)
# You'll see:
# dkms: doing automatic module rebuild...

# Check if driver is loaded
lsmod | grep nvidia

# Force rebuild if needed
sudo dkms install nvidia-cachyos -k $(uname -r)
```
#### Problem: Screen goes black after NVIDIA setup
```bash
# Switch to TTY and troubleshoot
# Press Ctrl+Alt+F2 to get a terminal

# Check X11 logs
cat ~/.local/share/xorg/Xvfb-0.log

# Or Wayland logs
journalctl -ex

# Reinstall drivers if corrupted
sudo pacman -S --noconfirm --force nvidia-cachyos-dkms
```
#### Problem: CUDA not found when compiling
```bash
# Add CUDA to PATH in ~/.bashrc or ~/.zshrc
export PATH=/opt/cuda/bin:$PATH
export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH

# Then source it
source ~/.bashrc
```

---

### Smart Resume Issues

#### Problem: `smart-resume.sh` errors about `mutagen` not found
```bash
# Install Mutagen (if not installed during setup)
paru -S --needed mutagen

# Create a Mutagen sync session (if needed)
mutagen sync create --name uni-sync-$(hostname) ~/Documents/University /mnt/proxmox_uni
```

#### Problem: Cron job for `smart-resume.sh` not running
```bash
# Check if cron is enabled
sudo systemctl status crond

# If not, enable it
sudo systemctl enable --now crond

# Verify your crontab (should show the job):
crontab -l

# Check cron logs for errors
sudo journalctl -u crond -n 20
```

---

### General System Issues

#### Problem: "Permission denied" when running scripts
```bash
# Ensure scripts are executable
chmod +x setup-cachyos.sh uni-sync.sh backup_uni.sh smart-resume.sh
chmod +x hosts/*.sh

# Run with bash if all else fails
bash ./setup-cachyos.sh
```

#### Problem: `pacman: command not found` (shouldn't happen on CachyOS)
```bash
# This means CachyOS isn't properly installed
# Reinstall or verify: grep -i cachyos /etc/os-release
```

#### Problem: Out of disk space during setup
```bash
# Check disk usage
df -h

# Clean pacman cache
sudo pacman -Sc

# Remove old package versions (aggressive)
sudo pacman -Scc
```

## 📝 License

This project is licensed under the **MIT License** — feel free to use, modify, and distribute these scripts.

### MIT License Summary
Copyright (c) 2026 Michael McMillan

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

**THE SOFTWARE IS PROVIDED "AS IS"**, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.

---

**TL;DR:** Use these scripts freely. Attribution appreciated but not required.