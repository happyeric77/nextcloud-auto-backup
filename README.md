# Nextcloud Backup System

This project let you periodically backup your Nextcloud snap. The backup process is automated and ensures that your Nextcloud data is safely stored on a mounted backup drive.

> **Note**: 
> - This project is designed to work with a [Nextcloud snap installation](https://github.com/nextcloud-snap/nextcloud-snap/wiki/Backup-and-Restore). 
> - To restore from backup, check the [official Nextcloud documentation](https://github.com/nextcloud-snap/nextcloud-snap/wiki/Backup-and-Restore).
> - This project is powered by systemd services and timers. 

## Installation

1. **Ensure the backup drive is mounted**:
    Make sure your backup drive is mounted to `/mnt/home-drive-2` (The default dir).

    > You can change the backup drive mount point by editing the `BACKUP_PATH` variable in both `backup-nextcloud.sh` and `install.sh`.

2. **Run the install script as root**:

    Run the install script as the root user to ensure all files are correctly installed and permissions are set properly. You can use the following one-liner to download and run the install script:

    ```bash
    curl -fsSL https://raw.githubusercontent.com/happyeric77/nextcloud-auto-backup/main/install.sh | sudo bash
    ```

## Usage

The systemd timer is configured to run the backup script every Tuesday at 5:30 AM. You can check the status of the timer and service using the following commands:

- **Check the timer status**:

  ```sh
  systemctl status backup-nextcloud.timer
  ```

- **Check the service status**:

  ```sh
  systemctl status backup-nextcloud.service
  ```

- **Manually start the backup**:

  ```sh
  sudo systemctl start backup-nextcloud.service
  ```

## Customization

- **Change the backup schedule**:

  edule by editing the `OnCalendar` directive.

- **Change the backup drive mount point**:

  You can change the backup drive mount point by editing the `BACKUP_PATH` variable in both `backup-nextcloud.sh` and `install.sh`.


## Logs

The backup process logs are stored in `/opt/backup-nextcloud/backup-nextcloud.log`. You can check the logs using the following command:

```sh
cat /opt/backup-nextcloud/backup-nextcloud.log
```

## License

This project is licensed under the MIT License.