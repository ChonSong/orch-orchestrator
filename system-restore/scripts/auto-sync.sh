#!/bin/bash

# Configuration
REPO_ROOT="$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")"
BACKUP_SCRIPT="$REPO_ROOT/system-restore/scripts/backup.sh"
DATE_STR=$(date +"%Y-%m-%d %H:%M:%S")

# Ensure we are in the repo root
cd "$REPO_ROOT" || exit 1

echo "🔄 Starting Automated Backup Sync [$DATE_STR]..."

# 1. Update Repository (Prevent conflicts)
echo "📥 Pulling latest changes from GitHub..."
git pull --rebase origin main

# 2. Run the Backup Generation
echo "⚙️  Generating system inventory..."
if [ -f "$BACKUP_SCRIPT" ]; then
    "$BACKUP_SCRIPT"
else
    echo "❌ Error: Backup script not found at $BACKUP_SCRIPT"
    exit 1
fi

# 3. Check for Changes
if [[ -z $(git status -s system-restore/inventory) ]]; then
    echo "✅ No changes detected. System is already backed up."
    exit 0
fi

# 4. Commit and Push
echo "d 📤 Changes detected. Pushing to GitHub..."
git add system-restore/inventory
git commit -m "backup: Auto-sync system state [$DATE_STR]"
git push origin main

echo "🎉 Backup Sync Complete!"
