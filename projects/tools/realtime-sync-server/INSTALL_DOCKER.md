# Docker Installation Guide

This guide helps you install Docker and Docker Compose on your Linux server for deploying sync.codeovertcp.com.

## Ubuntu/Debian Installation

### 1. Update System Packages
```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
```

### 2. Add Docker's GPG Key
```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

### 3. Set Up Docker Repository
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 4. Install Docker Engine
```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### 5. Start and Enable Docker
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### 6. Add User to Docker Group (Optional)
```bash
# This allows you to run docker without sudo
sudo usermod -aG docker $USER

# Apply group membership (logout and login, or run:)
newgrp docker
```

## CentOS/RHEL/Rocky Linux Installation

### 1. Install Required Packages
```bash
sudo yum install -y yum-utils
```

### 2. Add Docker Repository
```bash
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

### 3. Install Docker Engine
```bash
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### 4. Start and Enable Docker
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### 5. Add User to Docker Group (Optional)
```bash
sudo usermod -aG docker $USER
newgrp docker
```

## Verify Installation

```bash
# Test Docker installation
docker --version

# Test Docker Compose installation
docker compose version

# Test Docker with hello-world
docker run hello-world
```

You should see output similar to:
```
Docker version 24.0.7, build afdd53b
Docker Compose version v2.21.0
Hello from Docker!
...
```

## Docker Compose Commands

Note: The modern syntax uses `docker compose` (space) instead of `docker-compose` (hyphen).

```bash
# Both commands work the same (use whichever your system supports):
docker compose up -d
# or
docker-compose up -d
```

## Troubleshooting

### Permission Denied Error
If you get a permission error:
```bash
# Option 1: Use sudo
sudo docker ps

# Option 2: Add user to docker group (recommended)
sudo usermod -aG docker $USER
newgrp docker
```

### Docker Service Not Running
```bash
# Check Docker status
sudo systemctl status docker

# Start Docker
sudo systemctl start docker

# Enable Docker on boot
sudo systemctl enable docker
```

### Port Already in Use
```bash
# Check what's using port 80/443
sudo lsof -i :80
sudo lsof -i :443

# Stop conflicting services (e.g., Apache)
sudo systemctl stop apache2
sudo systemctl disable apache2
```

## Security Considerations

### 1. Keep Docker Updated
```bash
# Update Docker packages
sudo apt update && sudo apt upgrade -y docker-ce docker-ce-cli containerd.io
```

### 2. Use Docker Security Best Practices
- Run containers as non-root users (configured in our Dockerfile)
- Use specific image tags instead of `latest`
- Regularly scan images for vulnerabilities
- Limit container resources

### 3. Firewall Configuration
```bash
# Open necessary ports
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable
```

## Next Steps

After installing Docker:

1. **Proceed with Deployment**: Follow the [QUICK_DEPLOYMENT.md](./QUICK_DEPLOYMENT.md) guide
2. **Test Configuration**: Validate your Docker Compose files
3. **Monitor Resources**: Use `docker stats` to monitor resource usage
4. **Backup Data**: Set up regular backups for persistent data

## Alternative Installation Methods

### Docker Desktop (Development)
For local development, you can use Docker Desktop:
- Download from [docker.com](https://www.docker.com/products/docker-desktop/)
- Includes Docker Compose
- Good for development/testing

### Snap Package (Ubuntu)
```bash
# Install via Snap (not recommended for production)
sudo snap install docker

# Enable and start
sudo snap start docker
```

### Manual Installation
For advanced users or specific requirements, refer to [Docker's official documentation](https://docs.docker.com/engine/install/).

---

**Important**: Always test your Docker installation in a development environment before deploying to production.