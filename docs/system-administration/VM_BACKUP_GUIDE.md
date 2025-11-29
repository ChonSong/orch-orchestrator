# VM Backup and Restore Guide

This guide documents the automated backup system for your VM disk images to Google Drive.

## Overview

The backup system automatically creates compressed disk image backups of your VM and stores them in Google Drive. This provides disaster recovery capability in case of system failure, data corruption, or other major issues.

## Files Created

| File | Purpose |
|------|---------|
| `/home/seanos1a/backup-vm.sh` | Main backup script |
| `/home/seanos1a/restore-vm.sh` | Restore script |
| `/home/seanos1a/setup-gdrive.sh` | Google Drive configuration |
| `/etc/systemd/system/vm-backup.service` | systemd service definition |
| `/etc/systemd/system/vm-backup.timer` | systemd timer for daily backups |

## Initial Setup

### 1. Configure Google Drive Access

Run the setup script:

```bash
./setup-gdrive.sh
```

This will:
- Check if rclone is installed
- Guide you through Google Drive OAuth setup
- Create the necessary backup folder in Google Drive
- Test the connection

### 2. Manual Google Drive Setup (Alternative)

If you prefer manual setup:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or use existing one
3. Enable the **Google Drive API**
4. Create OAuth credentials:
   - Go to "Credentials" → "Create Credentials" → "OAuth client ID"
   - Choose "Desktop app" as application type
   - Download the JSON credentials file
5. Run: `rclone config`
6. Create a new remote named `gdrive` using the Drive storage type

## Backup Operations

### Automatic Daily Backups

Backups are scheduled to run automatically every day via systemd timer.

- **Schedule**: Daily at midnight (with 1-hour random delay)
- **Retention**: Last 7 backups kept
- **Compression**: gzip compression to save space
- **Location**: Google Drive → `vm-backups` folder

To check the schedule:
```bash
systemctl list-timers vm-backup
```

### Manual Backup

To trigger an immediate backup:

```bash
sudo /home/seanos1a/backup-vm.sh
```

### Backup Log Files

Monitor backup progress:
```bash
sudo tail -f /var/log/vm-backup.log
```

### Backup File Format

- **Name**: `vm_backup_YYYYMMDD_HHMMSS.img.gz`
- **Content**: Compressed disk image of `/dev/sda`
- **Size**: Typically 5-10GB (depends on disk usage)

## Restore Operations

⚠️ **WARNING**: Restore operations will completely overwrite your current disk!

### List Available Backups

```bash
/home/seanos1a/restore-vm.sh
```

This will show all available backups in Google Drive.

### Restore from Backup

```bash
sudo /home/seanos1a/restore-vm.sh vm_backup_YYYYMMDD_HHMMSS
```

Example:
```bash
sudo /home/seanos1a/restore-vm.sh vm_backup_20250123_150000
```

### Safety Features

The restore script includes multiple safety checks:
1. **Confirmation Prompts**: Must type 'DESTROY' and 'I_UNDERSTAND'
2. **Final Safety Check**: Must type 'YES' to proceed
3. **Backup Verification**: Verifies backup exists before download
4. **Disk Verification**: Confirms target disk exists

## Monitoring and Maintenance

### Check System Status

```bash
# Check if backup timer is active
systemctl status vm-backup.timer

# Check last backup result
journalctl -u vm-backup.service --since "1 day ago"

# View backup schedule
systemctl list-timers vm-backup
```

### Storage Usage

Monitor Google Drive storage usage:
```bash
# List backup files and sizes
rclone ls gdrive:vm-backups

# Get total size
rclone size gdrive:vm-backups
```

### Troubleshooting

#### Common Issues

1. **Authentication Failed**:
   - Re-run setup: `./setup-gdrive.sh`
   - Or manually: `rclone config`

2. **Upload Failed**:
   - Check internet connection
   - Verify Google Drive storage space
   - Check logs: `sudo tail -f /var/log/vm-backup.log`

3. **Backup Timeout**:
   - Disk images are large (30GB), compression takes time
   - Monitor progress in log file
   - Consider running during off-peak hours

4. **Restore Fails**:
   - Ensure sufficient disk space for temporary files
   - Check backup file integrity
   - Verify target disk is correct (`/dev/sda`)

#### Log Files

- **Backup Log**: `/var/log/vm-backup.log`
- **System Log**: `journalctl -u vm-backup.service`

## Configuration Options

### Modify Backup Schedule

Edit the timer file:
```bash
sudo nano /etc/systemd/system/vm-backup.timer
```

Common schedule options:
- `OnCalendar=daily` - Once per day
- `OnCalendar=weekly` - Once per week
- `OnCalendar=*-*-* 02:00:00` - Daily at 2 AM

After editing:
```bash
sudo systemctl daemon-reload
sudo systemctl restart vm-backup.timer
```

### Modify Retention Policy

Edit `/home/seanos1a/backup-vm.sh`:
```bash
MAX_BACKUPS=7  # Change this number
```

### Change Backup Location

Edit the script configuration:
```bash
GDRIVE_REMOTE="gdrive"
GDRIVE_FOLDER="vm-backups"  # Change folder name
```

## Performance Considerations

### Backup Impact

- **CPU Usage**: High during compression
- **Memory**: Up to 8GB allocated
- **Disk I/O**: Heavy during disk image creation
- **Network**: High during upload to Google Drive

### Optimization Tips

1. **Schedule During Off-Peak**: Backups run with random delay to distribute load
2. **Monitor System Load**: Use `htop` to monitor during backup
3. **Network Bandwidth**: Consider upload limits if needed
4. **Disk Space**: Ensure at least 35GB available during backup

## Security Considerations

- **Credentials**: Stored in rclone config file (encrypted)
- **Backup Data**: Contains entire disk image including all data
- **Access Control**: Backup scripts run as root
- **Google Drive**: Ensure 2FA is enabled on your Google account

## Emergency Procedures

### Immediate VM Recovery

1. **Boot into Rescue Mode**: If VM won't boot
2. **Access Terminal**: Use cloud provider console
3. **Download Backup**: Use rclone to download from Google Drive
4. **Restore Disk**: Use restore script or manual dd command
5. **Reboot VM**: Should return to backup state

### Complete Rebuild

If VM is completely lost:

1. **Create New VM**: With same specifications (30GB disk)
2. **Install Dependencies**: rclone, scripts, etc.
3. **Configure Google Drive**: Run setup script
4. **Restore from Backup**: Use most recent backup
5. **Verify System**: Check all services and data

## Support and Maintenance

### Regular Checks

- Weekly: Review backup logs
- Monthly: Check Google Drive storage usage
- Quarterly: Test restore process (in non-production)

### Contact

For issues with the backup system:
1. Check logs first
2. Review this documentation
3. Test with manual backup
4. Verify Google Drive access

---

**Last Updated**: 2025-01-23
**Version**: 1.0
**Compatibility**: Debian 13, systemd, rclone