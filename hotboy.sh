#!/bin/bash

echo "[*] Starting advanced miner cleanup..."

# Step 1: Kill any miner-related processes
echo "[*] Searching and killing miner processes..."
miner_processes=$(ps aux | awk '{print $11}' | grep -i -E 'tmp|home|bin|lib|usr|var|opt|dev' | grep -vE 'cron|systemd|ssh|init' | sort -u)

if [ -n "$miner_processes" ]; then
    echo "[*] Found the following miner-related processes: $miner_processes"
    for process in $miner_processes; do
        pid=$(pgrep -f "$process")
        if [ -n "$pid" ]; then
            echo "[*] Killing process with PID $pid"
            kill -9 $pid
        fi
    done
else
    echo "[*] No miner-related processes found."
fi

# Step 2: Check for and remove any systemd services from suspicious locations
echo "[*] Searching for and removing suspicious systemd services..."
suspicious_services=$(systemctl list-units --type=service --all | grep -i -E '/tmp|/home|/var/tmp|/usr/local|/opt' | awk '{print $1}')

if [ -n "$suspicious_services" ]; then
    echo "[*] Found suspicious systemd services: $suspicious_services"
    for service in $suspicious_services; do
        echo "[*] Stopping and disabling $service"
        systemctl stop $service
        systemctl disable $service
        rm -f /etc/systemd/system/$service
    done
else
    echo "[*] No suspicious systemd services found."
fi

# Step 3: Remove any suspicious cron jobs scheduled to restart mining or related processes
echo "[*] Searching for and removing suspicious cron jobs..."
suspicious_crons=$(crontab -l | grep -i -E '/tmp|/home|/usr|bin|lib|sbin|etc' || true)

if [ -n "$suspicious_crons" ]; then
    echo "[*] Found suspicious cron jobs: $suspicious_crons"
    crontab -l | grep -v -i -E '/tmp|/home|/usr|bin|lib|sbin|etc' | crontab -
else
    echo "[*] No suspicious cron jobs found."
fi

# Step 4: Search for suspicious files commonly used by miners (executables, scripts, configs)
echo "[*] Searching for and removing suspicious miner files..."
suspicious_files=$(find /tmp /home /var /usr /opt -type f -name "*.sh" -o -name "*.json" -o -name "*.bin" -o -name "*.out" -o -name "*.log" -o -name "miner*")

if [ -n "$suspicious_files" ]; then
    echo "[*] Found suspicious files: $suspicious_files"
    for file in $suspicious_files; do
        echo "[*] Removing file: $file"
        rm -f "$file"
    done
else
    echo "[*] No suspicious files found."
fi

# Step 5: Remove suspicious miner-related directories (including hidden ones)
echo "[*] Searching for and removing suspicious miner directories..."
suspicious_dirs=$(find /tmp /home /usr /etc /var /opt -type d -name "*xmrig*" -o -name "*miner*" -o -name "*nginx*" -o -name "*sleep*" -o -name "*worker*" -o -name "*protect*" -o -name "*killer*")

if [ -n "$suspicious_dirs" ]; then
    echo "[*] Found suspicious directories: $suspicious_dirs"
    for dir in $suspicious_dirs; do
        echo "[*] Removing directory: $dir"
        rm -rf "$dir"
    done
else
    echo "[*] No suspicious directories found."
fi

# Step 6: Check for and remove hidden files, including rootkits and backdoors
echo "[*] Searching for and removing hidden files and rootkits..."
hidden_files=$(find / -type f -name ".*" -exec ls -l {} \; | grep -E 'rootkit|backdoor|suspicious' || true)

if [ -n "$hidden_files" ]; then
    echo "[*] Found hidden files: $hidden_files"
    for file in $hidden_files; do
        echo "[*] Removing hidden file: $file"
        rm -f "$file"
    done
else
    echo "[*] No hidden files found."
fi

# Step 7: Search for any other suspicious scripts, binaries, or files used for persistence mechanisms
echo "[*] Searching for and removing other persistence mechanisms..."
persistence_files=$(find /etc /var /tmp /home /usr -type f -name "*rc.local*" -o -name "*init*" -o -name "*startup*" -o -name "*bashrc*" -o -name "*profile*")

if [ -n "$persistence_files" ]; then
    echo "[*] Found persistence files: $persistence_files"
    for file in $persistence_files; do
        echo "[*] Removing persistence file: $file"
        rm -f "$file"
    done
else
    echo "[*] No persistence files found."
fi

# Step 8: Remove any startup scripts that may automatically restart the miner
echo "[*] Removing startup scripts..."
startup_scripts=$(find /etc /var /home /tmp -type f -name "*rc.local*" -o -name "*init.d*" -o -name "*profile*" -o -name "*.sh" -o -name "*.bash")

if [ -n "$startup_scripts" ]; then
    echo "[*] Found startup scripts: $startup_scripts"
    for script in $startup_scripts; do
        echo "[*] Removing startup script: $script"
        rm -f "$script"
    done
else
    echo "[*] No startup scripts found."
fi

# Step 9: Remove any potentially dangerous and unnecessary hidden processes or services
echo "[*] Searching for and stopping hidden or suspicious services..."
hidden_services=$(systemctl list-units --type=service --all | grep -i -E 'tmp|usr|home|sbin|etc|var|opt' | awk '{print $1}')

if [ -n "$hidden_services" ]; then
    echo "[*] Found hidden services: $hidden_services"
    for service in $hidden_services; do
        echo "[*] Stopping and disabling service: $service"
        systemctl stop $service
        systemctl disable $service
        rm -f /etc/systemd/system/$service
    done
else
    echo "[*] No hidden services found."
fi

echo "[*] Cleanup complete. All suspicious miner files, processes, services, and persistence mechanisms have been removed."
