#!/bin/bash

set -e

# You must ensure the backupd drive is mounted to before running.
# NOTE: if you want to change the backup path, you can edit the BACKUP_PATH variable below. This case, you also need to make respective changes in `backup-nextcloud.sh` script.
if [ ! -d /mnt/home-drive-2 ]; then
    echo "Backup drive not mounted to /mnt/home-drive-2"
    exit 1
fi

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root user"
    exit 1
fi

# Check if files exist
if [ ! -f ./backup-nextcloud.sh ]; then
    echo "backup-nextcloud.sh not found!"
    exit 1
fi

if [ ! -f ./backup-nextcloud.service ]; then
    echo "backup-nextcloud.service not found!"
    exit 1
fi

if [ ! -f ./backup-nextcloud.timer ]; then
    echo "backup-nextcloud.timer not found!"
    exit 1
fi

BASE_PATH=/opt/backup-nextcloud
LOG_FILE="$BASE_PATH/backup-nextcloud.log"
SYSTEMD_PATH=/etc/systemd/system
TIME_ZONE=Asia/Tokyo

mkdir -p "$BASE_PATH"

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