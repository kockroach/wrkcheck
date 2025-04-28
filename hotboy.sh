#!/bin/bash

echo "[*] Starting safe miner cleanup..."

# Step 1: Kill miner processes
echo "[*] Killing miner processes..."
pids=$(ps aux | grep -E 'xmrig|minerd|stratum|pool|crypto' | grep -v grep | awk '{print $2}')

if [ -n "$pids" ]; then
    for pid in $pids; do
        echo "[*] Killing PID $pid"
        kill -9 $pid
    done
else
    echo "[*] No miner processes found."
fi

# Step 2: Check systemd services
echo "[*] Checking suspicious systemd services..."
services=$(systemctl list-units --type=service --all | grep -E 'xmrig|minerd|crypto|pool' | awk '{print $1}')

if [ -n "$services" ]; then
    for service in $services; do
        echo "[*] Disabling and removing service $service"
        systemctl stop "$service"
        systemctl disable "$service"
        rm -f "/etc/systemd/system/$service"
    done
else
    echo "[*] No suspicious services found."
fi

# Step 3: Clean suspicious cron jobs
echo "[*] Cleaning crontab entries..."
tmpfile=$(mktemp)
crontab -l | grep -v -E 'xmrig|minerd|crypto|pool' > "$tmpfile"
crontab "$tmpfile"
rm -f "$tmpfile"

# Step 4: Search and remove miner binaries
echo "[*] Searching and removing miner binaries..."
suspicious_binaries=$(find / -type f -executable -exec grep -l -i 'xmrig\|minerd\|pool' {} \; 2>/dev/null)

if [ -n "$suspicious_binaries" ]; then
    for file in $suspicious_binaries; do
        echo "[*] Removing suspicious binary: $file"
        rm -f "$file"
    done
else
    echo "[*] No suspicious binaries found."
fi

echo "[*] Miner cleanup completed safely."
