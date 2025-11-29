#!/bin/bash

echo "=== Google Drive Authentication Helper ==="
echo ""
echo "This script will help you authenticate with Google Drive."
echo "You'll need to open a browser on your local machine."
echo ""

# Check if gdrive config exists
if ! rclone config show | grep -q "\[gdrive\]"; then
    echo "❌ gdrive configuration not found in rclone config"
    exit 1
fi

echo "✅ Found gdrive configuration"
echo ""
echo "📋 To authenticate:"
echo ""
echo "1. Run this command on your local machine (not in the VM):"
echo "   rclone authorize \"drive\" \"1060122531256-5snug3ol4lt3qffiqpon1efjvqqscqi5.apps.googleusercontent.com\" \"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\""
echo ""
echo "2. This will open your browser"
echo "3. Log in to your Google account and grant permissions"
echo "4. Copy the resulting token (starts with {\"access_token\":...})"
echo ""
echo "⚠️  The token is long - make sure you copy the entire thing"
echo ""

read -p "Paste the token here (or press Enter to skip): " token

if [ -n "$token" ]; then
    # Update the config with the token
    echo "Updating rclone config with token..."

    # Create a temporary config file
    cp ~/.config/rclone/rclone.conf ~/.config/rclone/rclone.conf.bak

    # Add the token to gdrive config
    sed -i '/\[gdrive\]/,/\[/ s/$/\ntoken = '"$token"'/' ~/.config/rclone/rclone.conf

    echo "✅ Token added to configuration"
    echo ""
    echo "Testing connection..."

    if rclone lsd gdrive: >/dev/null 2>&1; then
        echo "🎉 Authentication successful!"
        echo ""
        echo "Creating vm-backups folder..."
        rclone mkdir gdrive:vm-backups
        echo "✅ Created vm-backups folder"
        echo ""
        echo "Your backup system is now ready!"
    else
        echo "❌ Authentication failed"
        echo "Please check the token and try again"
        echo "Restoring backup config..."
        cp ~/.config/rclone/rclone.conf.bak ~/.config/rclone/rclone.conf
    fi
else
    echo ""
    echo "⏭️  Authentication skipped"
    echo "You can authenticate later by running:"
    echo "   ./authenticate-gdrive.sh"
    echo ""
    echo "Or manually by updating the token in ~/.config/rclone/rclone.conf"
fi

echo ""
echo "Next steps:"
echo "1. Test the backup: sudo ./backup-vm.sh"
echo "2. Check the schedule: systemctl list-timers vm-backup"