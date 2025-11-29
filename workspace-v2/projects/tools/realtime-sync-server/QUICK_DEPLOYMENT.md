# Quick Deployment Guide - sync.codeovertcp.com

## Overview

This guide provides step-by-step instructions to deploy the real-time sync server to production with Docker containerization, load balancing, and horizontal scaling support.

## Prerequisites

- **Server**: Linux server with Docker and Docker Compose installed
- **Domain**: sync.codeovertcp.com pointing to your server IP
- **SSL**: SSL certificates for the domain
- **Resources**: Minimum 2GB RAM, 1 CPU core for single instance

## Deployment Options

### 1. Single Instance Deployment (Recommended for Starters)

**Use Case**: Production deployment with a single server instance, Redis cache, and Nginx reverse proxy.

```bash
# Deploy single instance
./deploy.sh
```

**Architecture**:
- 1x Sync Server instance
- 1x Redis cache
- 1x Nginx reverse proxy (with SSL)
- Resource usage: ~512MB RAM, 0.5 CPU

### 2. Scaled Deployment (High Availability)

**Use Case**: High-traffic production deployment with horizontal scaling.

```bash
# Deploy with horizontal scaling (3 instances + HAProxy)
./deploy.sh --scale
```

**Architecture**:
- 3x Sync Server instances
- 1x Redis cluster
- 1x HAProxy load balancer
- Resource usage: ~1.5GB RAM, 1.5 CPU
- Statistics dashboard: http://your-server:8404/stats

## Pre-Deployment Setup

### 1. Configure Environment

```bash
# Copy example environment file
cp .env.example .env.production

# Edit production configuration
nano .env.production
```

**Important settings in `.env.production**:
```bash
# Change this to a strong, random secret
JWT_SECRET=your-super-secure-jwt-secret-minimum-32-characters

# Adjust resource limits if needed
RATE_LIMIT_MAX_REQUESTS=100
```

### 2. Setup SSL Certificates

#### Option A: Let's Encrypt (Recommended)
```bash
# Install certbot
sudo apt update && sudo apt install certbot

# Generate certificates
sudo certbot certonly --standalone -d sync.codeovertcp.com

# Copy certificates to SSL directory
sudo cp /etc/letsencrypt/live/sync.codeovertcp.com/fullchain.pem ./ssl/sync.codeovertcp.com.crt
sudo cp /etc/letsencrypt/live/sync.codeovertcp.com/privkey.pem ./ssl/sync.codeovertcp.com.key
sudo chmod 600 ./ssl/sync.codeovertcp.com.key
```

#### Option B: Self-Signed (Testing Only)
```bash
# Generate self-signed certificates
cd ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout sync.codeovertcp.com.key \
  -out sync.codeovertcp.com.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=sync.codeovertcp.com"
```

### 3. Create Data Directories

```bash
# Create persistent data directories
sudo mkdir -p /home/seanos1a/{sync-data,sync-logs,redis-data,nginx-logs}
sudo chown -R $USER:$USER /home/seanos1a/{sync-data,sync-logs,redis-data,nginx-logs}
```

## Deployment Commands

### Basic Deployment
```bash
# Standard deployment
./deploy.sh

# Deployment with forced recreation
./deploy.sh --recreate

# Deployment with log output
./deploy.sh --logs
```

### Scaled Deployment
```bash
# Deploy with horizontal scaling
./deploy.sh --scale

# Deploy with scaling and logs
./deploy.sh --scale --logs
```

## Post-Deployment

### 1. Verify Services

```bash
# Check service status
docker-compose -f docker-compose.production.yml ps

# Check health
curl http://localhost:3001/api/health

# Check SSL (if certificates installed)
curl -I https://sync.codeovertcp.com/api/health
```

### 2. Monitor Logs

```bash
# Follow all logs
docker-compose -f docker-compose.production.yml logs -f

# Follow specific service logs
docker-compose -f docker-compose.production.yml logs -f sync-server
docker-compose -f docker-compose.production.yml logs -f nginx
docker-compose -f docker-compose.production.yml logs -f redis
```

### 3. Service Management

```bash
# Stop services
docker-compose -f docker-compose.production.yml down

# Restart services
docker-compose -f docker-compose.production.yml restart

# Update services
git pull
docker-compose -f docker-compose.production.yml build
docker-compose -f docker-compose.production.yml up -d
```

## Scaling Guide

### Vertical Scaling (Increase Resources)

Edit `docker-compose.production.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'      # Increase from 1.0
      memory: 1G       # Increase from 512M
```

### Horizontal Scaling (Add Instances)

Use the scaled configuration:
```bash
# Deploy 3 instances with load balancing
./deploy.sh --scale
```

Or modify `docker-compose.scale.yml` to add more instances.

## Security Considerations

### 1. Firewall Configuration
```bash
# Open necessary ports
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable
```

### 2. SSL/TLS Security
- Use strong SSL certificates (Let's Encrypt recommended)
- Enable HSTS headers (already configured in Nginx)
- Regularly update certificates

### 3. Application Security
- Change the JWT secret in production
- Use strong passwords for Redis (if needed)
- Regularly update Docker images
- Monitor logs for suspicious activity

## Monitoring

### Health Checks
- **Sync Server**: `GET /api/health`
- **Load Balancer**: HTTP health checks
- **Redis**: `redis-cli ping`

### Statistics Dashboard (Scaled Mode)
- URL: `http://your-server:8404/stats`
- Shows HAProxy statistics and server health

### Log Monitoring
```bash
# Real-time log monitoring
docker-compose -f docker-compose.production.yml logs -f --tail=100

# Error monitoring
docker-compose -f docker-compose.production.yml logs sync-server | grep ERROR
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Check what's using the port
   sudo lsof -i :80
   sudo lsof -i :443
   # Stop conflicting services
   ```

2. **SSL Certificate Errors**
   ```bash
   # Verify certificate paths
   ls -la ssl/
   # Check Nginx configuration
   docker-compose -f docker-compose.production.yml exec nginx nginx -t
   ```

3. **Redis Connection Issues**
   ```bash
   # Test Redis connection
   docker-compose -f docker-compose.production.yml exec redis redis-cli ping
   ```

4. **High Memory Usage**
   ```bash
   # Check container resource usage
   docker stats
   ```

### Recovery Commands

```bash
# Complete reset (warning: removes all data)
docker-compose -f docker-compose.production.yml down -v
docker system prune -f
./deploy.sh --recreate
```

## Performance Optimization

### 1. Database Optimization
- SQLite: Use WAL mode for better concurrency
- Redis: Configure appropriate memory limits
- Monitor query performance

### 2. Caching Strategy
- Redis for session data
- Application-level caching
- CDN for static assets (if applicable)

### 3. Network Optimization
- Enable HTTP/2 (configured in Nginx)
- Use compression (configured in Nginx)
- Optimize WebSocket connections

## Backup Strategy

### Data Backup
```bash
# Backup SQLite database
cp /home/seanos1a/sync-data/database.sqlite /backup/sync-db-$(date +%Y%m%d).sqlite

# Backup Redis data
docker-compose -f docker-compose.production.yml exec redis redis-cli BGSAVE
cp /home/seanos1a/redis-data/dump.rdb /backup/redis-$(date +%Y%m%d).rdb
```

### Configuration Backup
```bash
# Backup configuration files
tar -czf /backup/sync-config-$(date +%Y%m%d).tar.gz \
  .env.production \
  nginx/ \
  ssl/ \
  docker-compose*.yml
```

## Support

For issues with:
- **Application**: Check logs and health endpoints
- **Deployment**: Review this guide and error messages
- **Infrastructure**: Monitor Docker resource usage

Remember to regularly check for updates and security patches!