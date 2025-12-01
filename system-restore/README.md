# System Restore & Backup Kit

This directory contains tools to backup and restore your development environment configuration, dotfiles, and packages.

## 📂 Structure

- **`scripts/`**: Automation scripts.
  - `backup.sh`: Generates the inventory files from your current system.
  - `restore.sh`: Reinstalls packages and restores configuration from the inventory.
- **`inventory/`**: The stored state of your system.
  - `apt-packages.list`: List of Debian/Ubuntu system packages.
  - `npm-global.txt`: List of global Node.js packages.
  - `vscode-extensions.list`: List of VS Code / Code Server extensions.
  - `pm2-dump.json`: Snapshot of running PM2 background processes.
  - `dotfiles/`: Copies of your `.bashrc`, `.gitconfig`, etc.

## 🚀 How to Backup (Save State)

Run the backup script to update the inventory with your current system state:

```bash
./scripts/backup.sh
```

**Note:** You should commit and push changes to this directory after running a backup.

## 🔄 How to Restore (Reinstall)

On a new or broken system, clone this repository and run:

```bash
./scripts/restore.sh
```

This will:
1. Restore your dotfiles (files starting with `.`).
2. Install missing system packages (requires `sudo`).
3. Install global NPM packages.
4. Install VS Code extensions.
5. Resurrect PM2 processes.

## ⚠️ Security Note
Private keys (like `id_rsa`) are **NOT** backed up by default for security reasons. Only public keys and SSH config are saved. You must manually copy your private keys.
