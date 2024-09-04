#!/bin/bash
set -e

# You must ensure the backup drive is mounted before running.
# NOTE: if you want to change the backup path, you can edit the BACKUP_PATH variable below. In this case, you also need to make respective changes in the `install.sh` script.
BACKUP_PATH=/mnt/home-drive-2
if [ ! -d "$BACKUP_PATH" ]; then
    echo "Backup drive not mounted to $BACKUP_PATH"
    exit 1
fi

BACKUP_FILE=$(find "$BACKUP_PATH" -name '*_nextcloud_*.zip' -print -quit)
BASE_PATH=/opt/backup-nextcloud
LOG_FILE="$BASE_PATH/backup-nextcloud.log"
SYSTEMD_PATH=/etc/systemd/system
TIME_ZONE=Asia/Tokyo
SNAPSHOT_PATH=$(find /var/lib/snapd/snapshots -name '*_nextcloud_*.zip' -print -quit)

exec > >(tee -a "$LOG_FILE") 2>&1

echo "[$(TZ=$TIME_ZONE date)]: **Nextcloud backup process start**"

if [ -n "$SNAPSHOT_PATH" ]; then
    if [ -n "$BACKUP_FILE" ]; then
        echo "[$(TZ=$TIME_ZONE date)]:  Backup of snapshot ($BACKUP_FILE) already exists, removing it"
        rm "$BACKUP_FILE"
        sync
    fi

    echo "[$(TZ=$TIME_ZONE date)]:  Copying snapshot ($SNAPSHOT_PATH) to backup location"
    cp "$SNAPSHOT_PATH" "$BACKUP_PATH/"
    sync

    echo "[$(TZ=$TIME_ZONE date)]:  Snapshot copied, removing snapshot"
    rm "$SNAPSHOT_PATH"
    sync

    echo "[$(TZ=$TIME_ZONE date)]:  Snapshot removed, backup new one"
else
    echo "[$(TZ=$TIME_ZONE date)]:  Snapshot not found, backup new one"
fi

snap stop nextcloud &&
snap save nextcloud &&
snap start nextcloud

echo "[$(TZ=$TIME_ZONE date)]: **nextcloud backup migration complete**"