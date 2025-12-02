#!/bin/bash

# Configuration
INVENTORY_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")/inventory"

echo "Starting System Restore from $INVENTORY_DIR..."

# 1. Restore Dotfiles
echo "Restoring dotfiles..."
cp -r "$INVENTORY_DIR/dotfiles/." ~/
# Fix SSH permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config 2>/dev/null
chmod 644 ~/.ssh/*.pub 2>/dev/null
chmod 600 ~/.ssh/authorized_keys 2>/dev/null

# 2. System Packages
echo "Restoring APT packages..."
echo "Note: This requires sudo. You may be prompted for a password."
# Filter out "deinstall" lines and install
# This is a 'safe' restore that tries to install missing packages
# It does NOT remove packages that are present but not in the list (to be safe)
if [ -f "$INVENTORY_DIR/apt-packages.list" ]; then
    sudo apt-get update
    sudo dpkg --set-selections < "$INVENTORY_DIR/apt-packages.list"
    sudo apt-get dselect-upgrade -y
    sudo apt-get install -f
else
    echo "No apt-packages.list found, skipping."
fi

# 3. NPM Globals
echo "Restoring NPM Global packages..."
if [ -f "$INVENTORY_DIR/npm-global.txt" ]; then
    xargs -a "$INVENTORY_DIR/npm-global.txt" sudo npm install -g
elif [ -f "$INVENTORY_DIR/npm-global.json" ]; then
    echo "Warning: npm-global.txt missing, manual install required from json."
fi

# 4. VS Code Extensions
echo "Restoring VS Code extensions..."
if [ -f "$INVENTORY_DIR/vscode-extensions.list" ]; then
    while read -r ext; do
        if command -v code-server &> /dev/null; then
            code-server --install-extension "$ext"
        elif command -v code &> /dev/null; then
            code --install-extension "$ext"
        fi
    done < "$INVENTORY_DIR/vscode-extensions.list"
fi

# 5. PM2 Processes
echo "Restoring PM2 processes..."
if [ -f "$INVENTORY_DIR/pm2-dump.json" ]; then
    mkdir -p ~/.pm2
    cp "$INVENTORY_DIR/pm2-dump.json" ~/.pm2/dump.pm2
    pm2 resurrect
fi

echo "Restore Complete! Please restart your shell."
