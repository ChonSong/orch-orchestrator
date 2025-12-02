#!/bin/bash

# Configuration
BACKUP_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")/inventory"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

echo "Starting System Backup to $BACKUP_DIR..."

# 1. System Packages (APT)
echo "Backing up APT package list..."
dpkg --get-selections > "$BACKUP_DIR/apt-packages.list"

# 2. Node.js / NPM
echo "Backing up Global NPM packages..."
npm list -g --depth=0 --json > "$BACKUP_DIR/npm-global.json"
# Use Node to parse the JSON and extract package names correctly (including scopes)
node -e "
  const fs = require('fs');
  const json = JSON.parse(fs.readFileSync('$BACKUP_DIR/npm-global.json', 'utf8'));
  const packages = Object.keys(json.dependencies || {}).filter(pkg => pkg !== 'npm' && pkg !== 'lib');
  console.log(packages.join('\n'));
" > "$BACKUP_DIR/npm-global.txt"

# 3. PM2 Process List
echo "Backing up PM2 configuration..."
pm2 save
cp ~/.pm2/dump.pm2 "$BACKUP_DIR/pm2-dump.json"

# 4. VS Code / Code Server Extensions
echo "Backing up VS Code extensions..."
if command -v code-server &> /dev/null; then
    code-server --list-extensions > "$BACKUP_DIR/vscode-extensions.list"
elif command -v code &> /dev/null; then
    code --list-extensions > "$BACKUP_DIR/vscode-extensions.list"
else
    echo "No VS Code found."
fi

# 5. Dotfiles
echo "Backing up dotfiles..."
cp ~/.bashrc "$BACKUP_DIR/dotfiles/.bashrc" 2>/dev/null
cp ~/.profile "$BACKUP_DIR/dotfiles/.profile" 2>/dev/null
cp ~/.gitconfig "$BACKUP_DIR/dotfiles/.gitconfig" 2>/dev/null
cp ~/.zshrc "$BACKUP_DIR/dotfiles/.zshrc" 2>/dev/null
cp -r ~/.antigravity "$BACKUP_DIR/dotfiles/.antigravity" 2>/dev/null

# 6. SSH Config (Public keys and config only, NO PRIVATE KEYS)
mkdir -p "$BACKUP_DIR/dotfiles/.ssh"
cp ~/.ssh/config "$BACKUP_DIR/dotfiles/.ssh/config" 2>/dev/null
cp ~/.ssh/authorized_keys "$BACKUP_DIR/dotfiles/.ssh/authorized_keys" 2>/dev/null
cp ~/.ssh/*.pub "$BACKUP_DIR/dotfiles/.ssh/" 2>/dev/null

echo "Backup Complete! artifacts saved in $BACKUP_DIR"
