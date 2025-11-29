#!/bin/bash

echo "=== Quick Google Drive Setup ==="
echo ""

echo "I need to help you authenticate with Google Drive."
echo "Let's use a different approach that should work better."
echo ""

# Remove broken configs
echo "🔧 Cleaning up broken configurations..."
rclone config delete gdrive 2>/dev/null || true
rclone config delete dev 2>/dev/null || true

echo ""
echo "📋 To authenticate, you'll need to run this command on your local computer:"
echo ""
echo "1. First, install rclone on your local machine if not already installed"
echo "   - macOS: brew install rclone"
echo "   - Linux: curl https://rclone.org/install.sh | sudo bash"
echo "   - Windows: Download from https://rclone.org/downloads/"
echo ""
echo "2. Then run this authentication command:"
echo ""
echo "   rclone authorize \"drive\" \"1060122531256-5snug3ol4lt3qffiqpon1efjvqqscqi5.apps.googleusercontent.com\" \"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\""
echo ""
echo "3. This will open your browser - log into your Google account and allow access"
echo "4. Copy the entire token output (it will look like: {\"access_token\":\"...\",...})"
echo ""

read -p "Paste the authentication token here: " token

if [ -z "$token" ]; then
    echo "❌ No token provided. Authentication cancelled."
    exit 1
fi

# Create new config with proper token
echo ""
echo "🔧 Setting up rclone configuration..."

cat > ~/.config/rclone/rclone.conf << EOF
[gdrive]
type = drive
scope = drive
token = $token
client_id = 1060122531256-5snug3ol4lt3qffiqpon1efjvqqscqi5.apps.googleusercontent.com
client_secret = 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
EOF

echo "✅ Configuration created"
echo ""

# Test connection
echo "🔍 Testing Google Drive connection..."
if rclone lsd gdrive: >/dev/null 2>&1; then
    echo "🎉 Authentication successful!"

    # Create backup folder
    echo "📁 Creating vm-backups folder..."
    rclone mkdir gdrive:vm-backups
    echo "✅ vm-backups folder created"

    echo ""
    echo "🚀 Testing backup system..."

    # Create a small test file
    echo "Test backup $(date)" > /tmp/test-backup.txt

    # Upload test file
    if rclone copy /tmp/test-backup.txt gdrive:vm-backups/; then
        echo "✅ Test upload successful"
        rclone delete gdrive:vm-backups/test-backup.txt
        rm -f /tmp/test-backup.txt

        echo ""
        echo "🎯 Backup system is now ready!"
        echo ""
        echo "Your next steps:"
        echo "1. Run a full backup: sudo /home/seanos1a/backup-vm.sh"
        echo "2. Check backup schedule: systemctl list-timers vm-backup"
        echo "3. Monitor logs: sudo tail -f /var/log/vm-backup.log"
        echo ""
        echo "✨ Automatic daily backups are configured and ready!"

    else
        echo "❌ Test upload failed"
    fi

else
    echo "❌ Authentication failed"
    echo "Please check:"
    echo "1. You copied the entire token correctly"
    echo "2. The token hasn't expired"
    echo "3. Your Google account has Drive access"
    echo ""
    echo "Try running the authentication process again."
fi

rm -f /tmp/test-backup.txt