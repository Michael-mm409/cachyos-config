#!/bin/bash
# smart-resume.sh - Michael's Latency-Based Sync Trigger

HUB_IP="100.70.100.118"
HOME_THRESHOLD=10.0
# Updated path to be generic for CachyOS migration
LOG_FILE="$HOME/cachyos-setup/sync-watchdog.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
# Dynamic session name to match setup-cachyos.sh
SESSION_NAME="uni-sync-$(hostname)"

# 1. Capture the numeric latency value
# Ensure 'iputils' and 'bc' are installed: sudo pacman -S iputils bc
CURRENT_LATENCY=$(ping -c 1 $HUB_IP | grep "time=" | awk -F'time=' '{print $2}' | cut -d' ' -f1)

# 2. Safety check
if [ -z "$CURRENT_LATENCY" ]; then
    echo "[$TIMESTAMP] 📵 Hub unreachable. Mutagen staying paused." >> "$LOG_FILE"
    exit 0
fi

# 3. Logic Gate for Location-Aware Sync
if (( $(echo "$CURRENT_LATENCY < $HOME_THRESHOLD" | bc -l) )); then
    echo "[$TIMESTAMP] 🏠 Home Base detected ($CURRENT_LATENCY ms). Resuming Sync..." >> "$LOG_FILE"
    mutagen sync resume "$SESSION_NAME"
else
    echo "[$TIMESTAMP] 🌲 Remote location detected ($CURRENT_LATENCY ms). Bandwidth protection active." >> "$LOG_FILE"
    mutagen sync pause "$SESSION_NAME"
fi