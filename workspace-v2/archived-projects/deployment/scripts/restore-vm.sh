#!/bin/bash

# VM Disk Restore Script from Google Drive
# This script restores a VM disk image from Google Drive backup

set -euo pipefail

# Configuration
BACKUP_DIR="/tmp/vm-restore"
LOG_FILE="/var/log/vm-restore.log"
GDRIVE_REMOTE="gdrive"  # rclone remote name
GDRIVE_FOLDER="vm-backups"

# Function to display usage
usage() {
    echo "Usage: $0 [backup_name]"
    echo "  backup_name: Optional. Name of the backup to restore (e.g., vm_backup_20250123_150000)"
    echo "              If not provided, will show list of available backups"
    echo ""
    echo "Examples:"
    echo "  $0                    # Show available backups"
    echo "  $0 vm_backup_20250123_150000  # Restore specific backup"
    echo ""
    echo "⚠️  WARNING: This will OVERWRITE your current disk (/dev/sda)"
    echo "⚠️  Make sure you have a current backup before proceeding!"
}

# Create necessary directories
sudo mkdir -p "$BACKUP_DIR"
sudo mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | sudo tee -a "$LOG_FILE"
}

# Check if rclone is configured
if ! rclone config show | grep -q "$GDRIVE_REMOTE"; then
    echo "ERROR: rclone remote '$GDRIVE_REMOTE' not configured. Please run 'rclone config' first."
    exit 1
fi

# List available backups
list_backups() {
    echo "Available backups in Google Drive:"
    rclone lsf "${GDRIVE_REMOTE}:${GDRIVE_FOLDER}/" | grep -E "^vm_backup_[0-9]{8}_[0-9]{6}\.img\.gz$" | sort -r
}

# Show available backups if no argument provided
if [ $# -eq 0 ]; then
    list_backups
    echo ""
    echo "To restore a backup, run: $0 <backup_name>"
    echo "Example: $0 vm_backup_20250123_150000"
    exit 0
fi

BACKUP_NAME="$1"
BACKUP_FILE="${BACKUP_NAME}.img.gz"

# Verify backup exists
if ! rclone lsf "${GDRIVE_REMOTE}:${GDRIVE_FOLDER}/" | grep -q "^${BACKUP_FILE}$"; then
    echo "ERROR: Backup '$BACKUP_FILE' not found in Google Drive."
    echo ""
    list_backups
    exit 1
fi

# Safety warnings
echo ""
echo "⚠️  CRITICAL WARNING ⚠️"
echo "This operation will COMPLETELY OVERWRITE your current disk (/dev/sda)"
echo "All data on the disk will be permanently destroyed!"
echo ""
echo "You are about to restore backup: $BACKUP_FILE"
echo ""

read -p "Are you absolutely sure you want to continue? Type 'DESTROY' to confirm: " confirm

if [ "$confirm" != "DESTROY" ]; then
    echo "Operation cancelled for your safety."
    exit 1
fi

# Double confirmation
echo ""
echo "This is your last chance to cancel."
echo "Type 'I_UNDERSTAND' to proceed with disk destruction: "

read -p "> " confirm2

if [ "$confirm2" != "I_UNDERSTAND" ]; then
    echo "Operation cancelled. Your disk is safe."
    exit 1
fi

log "Starting VM restore process: $BACKUP_NAME"

# Download backup
log "Downloading backup from Google Drive..."
if ! rclone copy "${GDRIVE_REMOTE}:${GDRIVE_FOLDER}/${BACKUP_FILE}" "$BACKUP_DIR/" --progress; then
    log "ERROR: Failed to download backup from Google Drive"
    exit 1
fi

# Decompress backup
log "Decompressing backup image..."
if ! gunzip -c "${BACKUP_DIR}/${BACKUP_FILE}" > "${BACKUP_DIR}/${BACKUP_NAME}.img"; then
    log "ERROR: Failed to decompress backup image"
    exit 1
fi

# Get disk information
BACKUP_IMAGE="${BACKUP_DIR}/${BACKUP_NAME}.img"
TARGET_DISK="/dev/sda"

log "Backup image size: $(numfmt --to=iec <<< $(stat -c%s "$BACKUP_IMAGE"))"
log "Target disk: $TARGET_DISK"

# Safety check: verify target disk exists and is the right one
if [ ! -b "$TARGET_DISK" ]; then
    log "ERROR: Target disk $TARGET_DISK does not exist or is not a block device"
    exit 1
fi

# Final safety check
echo ""
echo "FINAL SAFETY CHECK:"
echo "About to write $(numfmt --to=iec <<< $(stat -c%s "$BACKUP_IMAGE")) to $TARGET_DISK"
echo ""
read -p "Last chance - Type 'YES' to proceed with writing to disk: " final_confirm

if [ "$final_confirm" != "YES" ]; then
    log "Operation cancelled at final safety check"
    exit 1
fi

# Restore disk image
log "Restoring disk image to $TARGET_DISK..."
log "This will take a while and cannot be interrupted..."

if ! sudo dd if="$BACKUP_IMAGE" of="$TARGET_DISK" bs=1M status=progress conv=fdatasync; then
    log "ERROR: Failed to restore disk image"
    exit 1
fi

# Clean up
log "Cleaning up temporary files..."
sudo rm -f "$BACKUP_IMAGE" "${BACKUP_DIR}/${BACKUP_FILE}"

log "Restore process completed successfully!"
log "The VM has been restored to state from backup: $BACKUP_NAME"
log ""
echo "✅ Restore completed successfully!"
echo "📁 Backup used: $BACKUP_FILE"
echo "💾 Target disk: $TARGET_DISK"
echo ""
echo "⚠️  You should now reboot the VM to ensure all changes take effect."
echo "   Run: sudo reboot"

# Send notification if possible
if command -v notify-send >/dev/null 2>&1; then
    notify-send "VM Restore Completed" "Successfully restored VM from backup: $BACKUP_FILE"
fi

exit 0