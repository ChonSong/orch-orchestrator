#!/bin/bash

# Google Drive Setup Script for VM Backups
# This script helps configure rclone to access Google Drive

set -euo pipefail

echo "=== Google Drive Backup Setup ==="
echo ""
echo "This script will help you configure rclone to access your Google Drive account"
echo "for storing VM disk image backups."
echo ""

# Check if rclone is installed
if ! command -v rclone >/dev/null 2>&1; then
    echo "ERROR: rclone is not installed. Please install it first:"
    echo "curl https://rclone.org/install.sh | sudo bash"
    exit 1
fi

# Check if already configured
if rclone config show | grep -q "gdrive"; then
    echo "✅ Google Drive is already configured!"
    echo ""
    echo "Current configuration:"
    rclone config show gdrive
    echo ""
    echo "You can now:"
    echo "1. Run a backup: sudo /home/seanos1a/backup-vm.sh"
    echo "2. List available backups: /home/seanos1a/restore-vm.sh"
    echo "3. Check backup status: systemctl status vm-backup.timer"
    exit 0
fi

echo "Let's configure Google Drive access..."
echo ""
echo "You will need:"
echo "1. A Google account"
echo "2. To create a Google Cloud project and enable the Drive API"
echo "3. To create OAuth credentials"
echo ""
echo "Instructions:"
echo "1. Go to: https://console.cloud.google.com/"
echo "2. Create a new project (or use existing)"
echo "3. Enable 'Google Drive API'"
echo "4. Go to 'Credentials' → 'Create Credentials' → 'OAuth client ID'"
echo "5. Choose 'Desktop app' as application type"
echo "6. Download the JSON file"
echo ""
read -p "Press Enter to continue with rclone configuration..."

# Run rclone config
echo ""
echo "🔧 Configuring rclone..."
echo "Please follow these steps:"
echo "1. Choose 'New remote'"
echo "2. Name it 'gdrive' (exactly this name)"
echo "3. Choose 'Drive' for storage"
echo "4. Leave client_id and client_secret blank (press Enter)"
echo "5. Choose 'N' for advanced config"
echo "6. Choose 'N' for auto config"
echo "7. rclone will give you a URL - open it in your browser"
echo "8. Log in to Google and allow access"
echo "9. Copy the verification code back to rclone"
echo ""

rclone config

# Test the connection
echo ""
echo "🔍 Testing Google Drive connection..."
if rclone lsd gdrive: >/dev/null 2>&1; then
    echo "✅ Google Drive connection successful!"

    # Create backup folder
    echo ""
    echo "📁 Creating backup folder..."
    if ! rclone lsd gdrive:vm-backups >/dev/null 2>&1; then
        rclone mkdir gdrive:vm-backups
        echo "✅ Created 'vm-backups' folder in Google Drive"
    else
        echo "✅ 'vm-backups' folder already exists"
    fi

    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Your VM backup system is now ready. You can:"
    echo ""
    echo "1. Run a manual backup:"
    echo "   sudo /home/seanos1a/backup-vm.sh"
    echo ""
    echo "2. Check backup schedule:"
    echo "   systemctl status vm-backup.timer"
    echo ""
    echo "3. View backup logs:"
    echo "   sudo tail -f /var/log/vm-backup.log"
    echo ""
    echo "4. Restore from backup (if needed):"
    echo "   /home/seanos1a/restore-vm.sh"
    echo ""
    echo "📅 Automatic backups are scheduled to run daily"
    echo "💾 Backups will be compressed to save space"
    echo "🗑️  Old backups will be automatically cleaned up (keeping last 7)"
    echo ""

else
    echo "❌ Google Drive connection failed!"
    echo "Please check your configuration and try again."
    echo "Run 'rclone config' to fix the setup."
    exit 1
fi

exit 0