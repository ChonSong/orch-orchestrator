# PORTS_SUMMARY.md
# Complete Port Infrastructure Summary

**Generated**: 2025-11-26
**Purpose**: Comprehensive overview of all ports, services, and applications running on the infrastructure

## 🔧 SYSTEM SERVICES

### Standard System Ports
| Port | Service | Purpose | Status |
|------|---------|---------|---------|
| 22 | SSHD | Remote shell access | ✅ Active |
| 53 | systemd-resolved | DNS resolver (127.0.0.53, 127.0.0.54) | ✅ Active |
| 25 | Exim4 | Mail server (localhost only) | ✅ Active |
| 5355 | systemd-resolved | Multicast DNS | ✅ Active |

## 🌐 WEB SERVER & REVERSE PROXY

### Nginx (Main Web Server)
| Port | Domain | Purpose | Backend | Status |
|------|--------|---------|---------|---------|
| 80, 443 | dev.codeovertcp.com | VS Code in Browser (Standard) | code-server (127.0.0.1:8080) | ✅ Active |
| 80, 443 | mobile.codeovertcp.com | VS Code Mobile Optimized | code-server mobile (127.0.0.1:8081) | ✅ Active |
| 80, 443 | sean.codeovertcp.com | Main Portfolio & Apps Hub | Static files with path routing | ✅ Active |
| 80, 443 | sync.codeovertcp.com | Real-time Sync Server | Sync server (127.0.0.1:3010) | ✅ Active |
| 80 | eza.codeovertcp.com | File Tree Viewer | EZA viewer (127.0.0.1:3003) | ✅ Active |

#### Path-based Routes (sean.codeovertcp.com)
- `/` → sean-s-landing-page (main portfolio)
- `/ecommerce` → ecommerce-dash (React dashboard)
- `/ecotracker` → ecotracker-app (environmental tracker)
- `/news` → global-news-ai (news aggregator)
- `/nebula` → nebula-ui (UI components)
- `/h2h` → h2h (peer-to-peer app)
- `/hyperspeed` → hyperspeed (performance tool)
- `/portfolio` → portfolio-hub (portfolio management)

## 🚀 APPLICATION SERVERS

### Code-Servers
| Port | Service | Configuration | Purpose | Status |
|------|---------|---------------|---------|---------|
| 8080 | code-server (standard) | bind-addr: 0.0.0.0:8080 | VS Code in browser - Desktop UI | ✅ Active |
| 8081 | code-server (mobile) | bind-addr: 0.0.0.0:8081 | VS Code in browser - Mobile UI | ✅ Active |

### Node.js Applications
| Port | Application | Framework | Purpose | Status |
|------|-------------|-----------|---------|---------|
| 3000 | sean-s-landing-page | Vite | Main portfolio site | ✅ Active |
| 3001 | ecommerce-dash | Next.js | E-commerce dashboard | ✅ Active |
| 3002 | global-news-ai | Next.js | News aggregation app | ✅ Active |
| 3003 | eza-viewer | Node.js | File tree viewer (Server-Sent Events) | ✅ Active |
| 3010 | realtime-sync-server | Node.js | WebSocket sync server | ⚠️ Configured but not running |

### Database Services
| Port | Service | Type | Purpose | Status |
|------|---------|------|---------|---------|
| 6379 | Redis (native) | Database | In-memory data store | ✅ Active (localhost) |
| 6380 | Redis (Docker) | Database | Dockerized Redis instance | ✅ Active (all interfaces) |

## 📱 MOBILE & TERMINAL SERVICES

### Terminal in Browser
- **ttyd**: Terminal in browser service (compiled from source)
- **Status**: Available but not currently running
- **Typical Port**: 7681 (when started)

## 🔍 SERVICE DISCOVERY

### Running Processes Analysis
- **Node.js processes**: 15+ active instances
- **Docker containers**: Redis container active
- **Nginx workers**: 1 master + 1 worker process
- **System services**: SSH, DNS, mail

### PM2 Process Manager
- **Status**: PM2 daemon running
- **Managed processes**: Various Node.js applications
- **Log directory**: `/home/seanos1a/.pm2/logs`

## 🛡️ SECURITY CONFIGURATION

### SSL/TLS
- **Certificate**: `/home/seanos1a/realtime-sync-server/ssl/sync.codeovertcp.com.crt`
- **Key**: `/home/seanos1a/realtime-sync-server/ssl/sync.codeovertcp.com.key`
- **Protocols**: TLSv1.2, TLSv1.3
- **Cipher suites**: ECDHE-RSA with AES GCM/SHA256/384

### Security Headers
- **HSTS**: Strict-Transport-Security (max-age=31536000)
- **Content Security Policy**: Configured per domain
- **X-Frame-Options**: DENY
- **X-Content-Type-Options**: nosniff
- **Referrer Policy**: strict-origin-when-cross-origin

### Rate Limiting
- **API rate limiting**: 10 requests/second
- **Zone**: api (10m shared memory)

## 📊 MONITORING & LOGS

### Access Logs
- **Dev server**: `/var/log/nginx/dev-access.log`
- **Mobile**: `/var/log/nginx/mobile-access.log`
- **Main site**: `/var/log/nginx/sean-access.log`
- **Sync server**: `/var/log/nginx/sync-access.log`
- **EZA viewer**: `/var/log/nginx/eza-access.log`

### Error Logs
- **Nginx error**: `/var/log/nginx/error.log`
- **System logs**: `journalctl` available

## 🔧 CONFIGURATION FILES

### Nginx
- **Main config**: `/etc/nginx/nginx.conf`
- **Sites enabled**: `/etc/nginx/sites-enabled/`
- **Upstreams configured**: code_server, code_server_mobile, sync_server

### Code-Servers
- **Standard**: `/home/seanos1a/.config/code-server/config.yaml`
- **Mobile**: `/home/seanos1a/.config/code-server-mobile/config.yaml`
- **Password**: dawnofdoyle (both instances)

## 🚦 QUICK STATUS CHECK

### Critical Services Status
- ✅ **Nginx**: Running and serving all domains
- ✅ **Code-Servers**: Both standard and mobile instances active
- ✅ **Node.js Apps**: All Next.js and Vite applications running
- ✅ **Database**: Redis instances operational
- ✅ **SSL**: Valid certificates and secure configuration
- ⚠️ **Sync Server**: Configured but backend service not running
- ⚠️ **ttyd**: Available but not started

### Port Conflicts
- **None detected** - all services have unique port assignments
- **Docker Redis** (6380) and **native Redis** (6379) running on different ports

## 📝 USAGE NOTES

### Development Workflow
1. **Primary Development**: Use `dev.codeovertcp.com` (VS Code standard)
2. **Mobile Development**: Use `mobile.codeovertcp.com` (VS Code mobile)
3. **App Testing**: Access apps via `sean.codeovertcp.com/{app-name}`
4. **File Management**: Use `eza.codeovertcp.com` for real-time file tree view

### Authentication
- **Code-Servers**: Password protected (dawnofdoyle)
- **SSH**: Key-based authentication recommended
- **Database**: Redis running without password (localhost access)

### Backup Considerations
- **Code**: Git repositories for all projects
- **Configuration**: Nginx and code-server configs backed up
- **SSL**: Certificates stored in `/home/seanos1a/realtime-sync-server/ssl/`
- **Data**: Redis data in Docker volume and native instance

---

## ✅ REMOVED SERVICES (2025-11-26)

### code.codeovertcp.com
- **Status**: Completely removed
- **Reason**: DNS caching conflicts with eza.codeovertcp.com
- **Actions taken**:
  - ✅ Removed from nginx configuration
  - ✅ Deleted `/var/www/sean/gemini-assistant` files
  - ✅ Removed `~/.gemini` config directory
  - ✅ Deleted `gemini-delegation` project
  - ✅ Cleaned nginx logs
  - ⚠️ **Pending**: Remove from Cloudflare DNS

### Development Workflow
1. **Primary Development**: Use `dev.codeovertcp.com` (VS Code standard)
2. **Mobile Development**: Use `mobile.codeovertcp.com` (VS Code mobile)
3. **App Testing**: Access apps via `sean.codeovertcp.com/{app-name}`
4. **File Management**: Use `eza.codeovertcp.com` for real-time file tree view

**Last Updated**: 2025-11-26
**Review Frequency**: Weekly recommended
**Maintenance**: Monitor log files and service status regularly