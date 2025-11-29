# 📱 Complete Mobile Development Guide

**Consolidated**: 2025-11-27  
**Status**: ✅ Production Ready

---

## 🎯 Overview

This guide combines all mobile development setup and workflows for a seamless development experience on phones and tablets.

---

## 🚀 Quick Start

### 1. Open Mobile Code-Server
- **URL**: https://mobile.codeovertcp.com
- **Password**: dawnofdoyle
- **Port**: 8081 (mobile-optimized)

### 2. Start Claude Code in Mobile Mode
```bash
cdev    # Mobile Development Mode (recommended for phones)
c       # Standard Claude Code
cplan   # Plan Mode for complex tasks
ccont   # Continue last conversation
```

---

## ⚙️ Mobile Optimizations Applied

### Terminal Settings
- **Font Size**: 14px (readable on mobile)
- **Line Height**: 1.2 (compact but clear)
- **Scrollback**: 10,000 lines
- **Cursor**: Blinking line for visibility
- **Tree Indent**: 20px (larger touch targets)

### UI Optimizations
- **Activity Bar**: Hidden (more screen space)
- **Minimap**: Disabled (unnecessary on mobile)
- **Breadcrumbs**: Hidden (cleaner interface)
- **Format on Save**: Enabled (auto-formatting)

### Mobile-Specific Features
- **Mobile Toolbar**: Fixed bottom bar with ESC, Tab, Arrows, Git, Term
- **Touch Targets**: Larger tabs, buttons, and interactive elements
- **Gestures**: 
  - 2-finger swipe for undo
  - 3-finger tap for Command Palette
  - Swipe left to close sidebar

---

## 🧘 Zen Mode (Full-Screen Terminal)

### Method 1: Command Palette
1. Press `F1` or tap hamburger menu (≡)
2. Type: "View: Toggle Maximized Panel"
3. Terminal now fills entire screen

### Method 2: Keyboard Shortcut
- **Desktop**: `Ctrl + J` to toggle panel, then maximize
- **Mobile**: Use Command Palette (Method 1)

### To Exit Zen Mode
- Run the same command again
- Or press `Ctrl + J` (desktop)

---

## 🔄 Optimal Mobile Workflow

### Primary Workflow (Terminal-First)
1. **Open** mobile.codeovertcp.com
2. **Login** with password: dawnofdoyle
3. **Terminal**: Open immediately (hamburger menu → Terminal)
4. **Maximize**: Use Zen Mode for focused work
5. **Claude**: Run `cdev` to start in mobile mode
6. **Build**: Let Claude write code autonomously
7. **Verify**: Toggle to editor when needed
8. **Repeat**: Stay in terminal most of the time

### Alternative: Dual-Screen Workflow
- **Create multiple terminals** for different tasks:
  - Terminal 1: Claude Code CLI
  - Terminal 2: Running dev server (`npm run dev`)
  - Terminal 3: Git operations
- **Switch** between terminals via dropdown

---

## 📋 Essential Commands & Shortcuts

### Bash Aliases (Mobile-Focused)
```bash
c          # Start Claude Code
cdev       # Mobile Development Mode (brief responses)
cplan      # Plan Mode for complex tasks
ccont      # Continue last conversation
```

### Mobile-Friendly Shortcuts
- `F1` or hamburger menu → Command Palette
- `Ctrl + `` - Toggle Terminal
- `Ctrl + P` - Quick Open File
- `Ctrl + Shift + 5` - Split Terminal

### File Navigation (Mobile)
```bash
# Quick file checks
cat filename       # View file contents
less filename      # Browse file (scroll with volume keys)
ls -la            # List directory contents

# Find files quickly
find . -name "*.js" | head -10
grep -r "function" src/
```

---

## 🛠️ Development Features

### MCP Integration
- **Filesystem MCP**: Enhanced file operations
- **Status**: ✅ Connected and active
- **Command**: `claude mcp list` to view all servers

### Git Operations (Mobile Optimized)
```bash
# Quick git workflow
git add .
git commit -m "feat: mobile commit message"
git push

# Status and diff
git status
git diff --stat
```

### Auto-Save Configuration
- **Delay**: 1 second (optimized for mobile)
- **Format**: Auto-format on save enabled
- **Backup**: Auto-git commits available

---

## 📱 Mobile vs Desktop Comparison

| Feature | Mobile (Port 8081) | Desktop (Port 8080) |
|---------|-------------------|-------------------|
| **Font Size** | 14px (larger) | 14px (standard) |
| **Touch Targets** | 20px indent | 14px indent |
| **UI Layout** | Mobile-optimized | Standard VS Code |
| **Primary Use** | Phones/tablets | Laptops/desktops |
| **Best For** | Quick edits, CLI work | Full development sessions |

---

## 🎨 Customization

### Adjust Font Sizes
Edit `~/.local/share/code-server/User/settings.json`:
```json
{
  "terminal.integrated.fontSize": 16,
  "editor.fontSize": 16,
  "workbench.colorTheme": "Default Dark+"
}
```

### Mobile-Specific Settings
```json
{
  "workbench.activityBar.visible": false,
  "editor.minimap.enabled": false,
  "editor.fontSize": 16,
  "terminal.integrated.fontSize": 14,
  "workbench.tree.indent": 20
}
```

---

## 🐛 Troubleshooting

### Terminal Issues
```bash
# Reset terminal
source ~/.bashrc

# Create new terminal
F1 → "Terminal: Create New Terminal"

# Clear terminal
Ctrl + L
```

### Performance Issues
- **Close unused terminals**
- **Reload page** (Ctrl + R)
- **Clear browser cache**
- **Check internet connection**

### Connection Problems
```bash
# Test code-server status
curl -I https://mobile.codeovertcp.com

# Restart service if needed
sudo systemctl restart code-server-mobile

# Check service status
sudo systemctl status code-server-mobile
```

### Claude Code Issues
```bash
# Check Claude installation
claude --version

# Test MCP connectivity
claude mcp list

# Restart Claude Code
# Close browser tab and reopen
```

---

## 🔧 Configuration Files

### Code-Server Mobile Config
**Location**: `~/.config/code-server/config.yaml`
```yaml
bind-addr: 127.0.0.1:8081
auth: password
password: dawnofdoyle
cert: false
```

### Mobile Development Prompt
**Location**: `~/.claude/mobile-dev-prompt.md`
- Auto-loaded when using `cdev`
- Brief responses with bullet points
- Auto git operations
- Mobile-first viewport (375px)

### Bash Aliases
**Location**: `~/.bashrc` (lines 119-123)
- All mobile aliases configured
- Auto-reload on terminal start

---

## 📊 Available Services

| Service | URL | Port | Purpose |
|---------|-----|------|---------|
| **Mobile Code-Server** | https://mobile.codeovertcp.com | 8081 | Mobile-optimized development |
| **Desktop Code-Server** | https://dev.codeovertcp.com | 8080 | Standard VS Code experience |
| **Gemini Web Chat** | https://code.codeovertcp.com | 3000 | Backup web interface |
| **Portfolio Hub** | https://sean.codeovertcp.com | 3000 | Personal projects |

---

## 🎯 Best Practices

### For Phone Users
1. **Use Zen Mode** for focused terminal work
2. **Let Claude write code** - minimize manual editing
3. **Use voice-to-text** for longer prompts when possible
4. **Bookmark frequently used commands** in browser
5. **Enable auto-rotate** for better terminal visibility

### For Tablet Users
1. **Use split screen** with terminal + editor
2. **Landscape orientation** works best
3. **Connect external keyboard** for extended sessions
4. **Use multiple terminals** for complex workflows

### General Mobile Tips
1. **Keep terminal maximized** most of the time
2. **Use file explorer** only when browsing structure
3. **Copy/paste works great** on mobile browsers
4. **Auto-save is enabled** - don't worry about losing work
5. **Git operations are automatic** with `cdev` mode

---

## 📚 Additional Resources

- [VS Code Mobile Shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf)
- [Claude Code CLI Documentation](https://github.com/anthropics/claude-code)
- [code-server Mobile Guide](https://coder.com/docs/code-server)

---

## 🎉 Setup Complete!

You now have a fully mobile-optimized development environment with:
- ✅ Touch-friendly interface
- ✅ Optimized fonts and spacing
- ✅ Full terminal capabilities
- ✅ Claude Code integration
- ✅ Auto-save and git operations
- ✅ Dual-port strategy (mobile + desktop)

**Happy coding on the go!** 📱💻

---

**Last Updated**: 2025-11-27  
**Consolidated From**: MOBILE_SETUP_COMPLETE.md + CODE_SERVER_MOBILE_GUIDE.md