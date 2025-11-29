# Directory Organization Structure

This document outlines the organized directory structure for `/home/seanos1a`.

## 📁 Main Directories

### `/docs/` - Documentation
All markdown documentation and reference materials:
- **`guides/`** - How-to guides, setup instructions, tutorials
- **`projects/`** - Project-specific documentation and reports
- **`architecture/`** - System architecture and design documents
- **`reference/`** - Reference materials and test documentation

### `/active-projects/` - Active Development Projects
Active development work:
- **`web/`** - Web applications and frontend projects
- **`tools/`** - CLI tools, utilities, and system tools
- **`archived/`** - Completed or inactive projects

### `/archived-projects/` - Archived Projects
Completed or inactive projects that are preserved but not actively developed:
- **css/** - Archived web stylesheets
- **js/** - Archived JavaScript libraries
- **backup/** - Old project backups

### `/tools/` - Operational Tools and Utilities
CLI tools, utilities, and system management:
- **`code-server-sync-client/`** - Development synchronization tools
- **`monitoring/`** - System monitoring tools
- **`nginx-logs/`** - Web server log analysis
- **`redis-data/`** - Database management utilities

### `/config/` - Configuration Files
System configuration and service configuration files

### `/system-services/` - System Services
System service configurations and management scripts

### `/scripts/` - Automation Scripts
Shell scripts and automation tools:
- **`setup/`** - Installation and setup scripts
- **`maintenance/`** - System maintenance and backup scripts
- **`testing/`** - Test and validation scripts

### `/services/` - Running Services
Configuration files for running services and servers

### `/workspace/` - Temporary Working Area
Files currently being worked on, temporary files, and work-in-progress

### `/config/` - Configuration Files
System configuration files (package.json, ecosystem files, etc.)

### `/logs/` - Log Files
System and application logs (already existed)

### `/backups/` - Backup Files
System backups and archives (already existed)

## 🗂️ File Categories

**Root Level Files Kept in Place:**
- Hidden system files (`.bashrc`, `.profile`, etc.)
- Essential configuration files (`.gitconfig`, etc.)
- Standard user directories (`Desktop`, `Downloads`)

**Moved to Appropriate Directories:**
- All `.md` files → `/docs/`
- All `.sh` scripts → `/scripts/`
- All `.mjs` modules → `/scripts/`
- Project directories → `/projects/`
- Service configurations → `/services/`
- Working files → `/workspace/`

**Removed:**
- Empty placeholder files (0-byte files)

## 🚀 Quick Navigation

```bash
# Find documentation
find ~/docs -name "*.md" | grep -i "topic"

# Run setup scripts
ls ~/scripts/setup/
~/scripts/setup/some-script.sh

# Access projects
cd ~/projects/web/
cd ~/projects/tools/

# Check services
cd ~/services/
ls -la

# Workspace for temporary work
cd ~/workspace/
```

## 📋 Maintenance

- Keep new organized structure when adding files
- Move completed projects from `/workspace/` to appropriate `/projects/` subdirectory
- Clean up `/workspace/` regularly
- Update this documentation when making structural changes

---
*Created: 2025-11-26*
*Last Updated: 2025-11-26*