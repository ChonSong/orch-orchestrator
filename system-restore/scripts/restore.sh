#!/bin/bash

# Configuration
INVENTORY_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")/inventory"

echo "Starting System Restore from $INVENTORY_DIR..."

# 1. Restore Dotfiles
echo "Restoring dotfiles..."
cp -r "$INVENTORY_DIR/dotfiles/." ~/
cp -r "$INVENTORY_DIR/dotfiles/.antigravity" ~/ 2>/dev/null
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

# 3. Install NVM and Node.js (if not present)
echo "Checking for NVM and Node.js..."

if [ ! -d "$HOME/.nvm" ]; then
    echo "NVM not found, installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    # Source NVM for the current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# Source NVM if already installed but not sourced in current script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! command -v node &> /dev/null; then
    echo "Node.js not found, installing Node.js v18 LTS using NVM..."
    nvm install 18
    nvm use 18
    nvm alias default 18
else
    echo "Node.js already installed."
fi

# 4. NPM Globals
echo "Restoring NPM Global packages..."
if [ -f "$INVENTORY_DIR/npm-global.txt" ]; then
    xargs -a "$INVENTORY_DIR/npm-global.txt" npm install -g
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
