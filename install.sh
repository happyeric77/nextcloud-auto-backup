#!/bin/bash

set -e

# Configuration
BACKUP_PATH="/mnt/home-drive-2"
BASE_PATH="/opt/backup-nextcloud"
LOG_FILE="$BASE_PATH/backup-nextcloud.log"
SYSTEMD_PATH="/etc/systemd/system"
TIME_ZONE="Asia/Tokyo"

# Ensure the backup drive is mounted
if [ ! -d "$BACKUP_PATH" ]; then
    echo "Backup drive not mounted to $BACKUP_PATH"
    exit 1
fi

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root user"
    exit 1
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl could not be found, please install it."
    exit 1
fi


# Download the backup-nextcloud.sh & systemd files
# Check if files exist, if now download them
if [ ! -f backup-nextcloud.sh ]; then
    curl -O https://raw.githubusercontent.com/happyeric77/nextcloud-auto-backup/main/backup-nextcloud.sh
fi

if [ ! -f backup-nextcloud.service ]; then
    curl -O https://raw.githubusercontent.com/happyeric77/nextcloud-auto-backup/main/backup-nextcloud.service
fi

if [ ! -f backup-nextcloud.timer ]; then
    curl -O https://raw.githubusercontent.com/happyeric77/nextcloud-auto-backup/main/backup-nextcloud.timer
fi

# Check if files exist
for file in backup-nextcloud.sh backup-nextcloud.service backup-nextcloud.timer; do
    if [ ! -f ./$file ]; then
        echo "$file not found!"
        exit 1
    fi
done

# Create base path directory
mkdir -p "$BASE_PATH"

# Redirect output to log file
exec > >(tee -a "$LOG_FILE") 2>&1

echo "[$(TZ=$TIME_ZONE date)]: **Start installing backup-nextcloud process**"

# Install the backup-nextcloud.sh script
install -m 755 -o root -g root ./backup-nextcloud.sh "$BASE_PATH/"

# Install the backup-nextcloud.service
install -m 644 -o root -g root ./backup-nextcloud.service "$SYSTEMD_PATH/"

# Install the backup-nextcloud.timer
install -m 644 -o root -g root ./backup-nextcloud.timer "$SYSTEMD_PATH/"

# Reload the systemd daemon
systemctl daemon-reload

# Enable the backup-nextcloud.timer
systemctl enable backup-nextcloud.timer

# Start the backup-nextcloud.timer
systemctl start backup-nextcloud.timer

echo "[$(TZ=$TIME_ZONE date)]: **backup-nextcloud process installed**"
