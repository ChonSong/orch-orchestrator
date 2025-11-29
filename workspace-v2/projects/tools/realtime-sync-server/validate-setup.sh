#!/bin/bash

# Validation Script for sync.codeovertcp.com Setup
# Checks all configuration files and prerequisites

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Validation functions
log() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

success() {
    echo -e "${GREEN}[✅] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[⚠️] $1${NC}"
}

error() {
    echo -e "${RED}[❌] $1${NC}"
}

# Track results
PASSED=0
FAILED=0
WARNINGS=0

# Test function
test_config() {
    local test_name="$1"
    local test_command="$2"
    local error_msg="$3"
    local warning_level=${4:-"error"} # "error" or "warning"

    log "Testing: $test_name"

    if eval "$test_command" &>/dev/null; then
        success "$test_name"
        ((PASSED++))
        return 0
    else
        if [[ "$warning_level" == "warning" ]]; then
            warning "$error_msg"
            ((WARNINGS++))
        else
            error "$error_msg"
            ((FAILED++))
        fi
        return 1
    fi
}

echo -e "${BLUE}"
echo "========================================"
echo "🔍 Sync Server Setup Validation"
echo "========================================"
echo -e "${NC}"

# Check project structure
test_config "Project Directory Structure" \
    "test -d /home/seanos1a/realtime-sync-server" \
    "Project directory not found"

test_config "Package.json Exists" \
    "test -f package.json" \
    "package.json not found - this is required"

test_config "Server.js Exists" \
    "test -f server.js" \
    "server.js not found - main application file missing"

# Check Docker files
test_config "Dockerfile Exists" \
    "test -f Dockerfile" \
    "Dockerfile not found - required for containerization"

test_config "Docker Compose Config Exists" \
    "test -f docker-compose.yml" \
    "docker-compose.yml not found - basic deployment config"

test_config "Production Docker Compose Exists" \
    "test -f docker-compose.production.yml" \
    "docker-compose.production.yml not found - production deployment config"

test_config "Scaled Docker Compose Exists" \
    "test -f docker-compose.scale.yml" \
    "docker-compose.scale.yml not found - scaling config"

test_config "Dockerignore Exists" \
    "test -f .dockerignore" \
    ".dockerignore not found - recommended for smaller images"

# Check configuration files
test_config "Nginx Config Directory" \
    "test -d nginx" \
    "nginx configuration directory not found"

test_config "Nginx Main Config" \
    "test -f nginx/nginx.conf" \
    "nginx.conf not found - main reverse proxy config"

test_config "Nginx Site Config" \
    "test -f nginx/conf.d/sync.codeovertcp.com.conf" \
    "Site configuration not found - required for reverse proxy"

test_config "HAProxy Config" \
    "test -f haproxy/haproxy.cfg" \
    "haproxy.cfg not found - required for load balancing in scaled mode"

test_config "Redis Config" \
    "test -f redis/redis.conf" \
    "redis.conf not found - production Redis configuration"

# Check SSL setup
test_config "SSL Directory" \
    "test -d ssl" \
    "SSL directory not found - required for HTTPS" "warning"

test_config "SSL Certificate" \
    "test -f ssl/sync.codeovertcp.com.crt" \
    "SSL certificate not found - HTTPS will not work" "warning"

test_config "SSL Private Key" \
    "test -f ssl/sync.codeovertcp.com.key" \
    "SSL private key not found - HTTPS will not work" "warning"

# Check environment configuration
test_config "Environment Example" \
    "test -f .env.example" \
    ".env.example not found - reference configuration missing"

test_config "Production Environment" \
    "test -f .env.production" \
    ".env.production not found - production environment configuration missing"

# Check deployment scripts
test_config "Deployment Script" \
    "test -f deploy.sh" \
    "deploy.sh not found - automated deployment script missing"

test_config "Deployment Script Executable" \
    "test -x deploy.sh" \
    "deploy.sh is not executable - run: chmod +x deploy.sh"

# Check documentation
test_config "Quick Deployment Guide" \
    "test -f QUICK_DEPLOYMENT.md" \
    "QUICK_DEPLOYMENT.md not found - deployment documentation missing"

test_config "Docker Installation Guide" \
    "test -f INSTALL_DOCKER.md" \
    "INSTALL_DOCKER.md not found - Docker setup documentation missing"

# Validate configuration syntax (basic checks)
log "Validating configuration syntax..."

test_config "Docker Compose Syntax (Basic)" \
    "grep -q 'version:' docker-compose.yml" \
    "docker-compose.yml may have syntax errors"

test_config "Production Compose Syntax" \
    "grep -q 'version:' docker-compose.production.yml" \
    "docker-compose.production.yml may have syntax errors"

test_config "Scaled Compose Syntax" \
    "grep -q 'version:' docker-compose.scale.yml" \
    "docker-compose.scale.yml may have syntax errors"

test_config "Nginx Config Syntax" \
    "grep -q 'events {' nginx/nginx.conf" \
    "nginx.conf may have syntax errors"

test_config "HAProxy Config Syntax" \
    "grep -q 'global' haproxy/haproxy.cfg" \
    "haproxy.cfg may have syntax errors"

# Check Node.js configuration
log "Validating Node.js configuration..."

test_config "Node.js Dependencies in package.json" \
    "grep -q 'express' package.json" \
    "Express dependency not found in package.json"

test_config "Socket.IO Dependency" \
    "grep -q 'socket.io' package.json" \
    "Socket.IO dependency not found - required for real-time sync"

test_config "Start Script" \
    "grep -q '\"start\"' package.json" \
    "Start script not found in package.json"

# Security checks
log "Performing security checks..."

test_config "Non-root User in Dockerfile" \
    "grep -q 'nodejs' Dockerfile" \
    "Dockerfile should use non-root user for security" "warning"

test_config "Multi-stage Build" \
    "grep -q 'AS base' Dockerfile" \
    "Dockerfile should use multi-stage build for optimization" "warning"

# Check environment variables
log "Checking environment configuration..."

if [[ -f .env.production ]]; then
    test_config "JWT Secret Configured" \
        "grep -q 'JWT_SECRET=' .env.production && ! grep -q 'JWT_SECRET=your-super-secret-jwt-key-change-in-production' .env.production" \
        "JWT_SECRET should be changed from default value in production" "warning"

    test_config "Production Node Environment" \
        "grep -q 'NODE_ENV=production' .env.production" \
        "NODE_ENV should be set to production"

    test_config "Redis URL Configured" \
        "grep -q 'REDIS_URL=redis://' .env.production" \
        "REDIS_URL not properly configured"
fi

echo -e "\n${BLUE}========================================"
echo "📊 Validation Results Summary"
echo "========================================${NC}"

echo -e "${GREEN}✅ Passed: $PASSED${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"

if [[ $FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}🎉 All critical tests passed!${NC}"

    if [[ $WARNINGS -eq 0 ]]; then
        echo -e "${GREEN}🚀 Perfect! You're ready for deployment.${NC}"
    else
        echo -e "${YELLOW}⚠️  Address the warnings above for optimal deployment.${NC}"
    fi

    echo -e "\n${BLUE}Next steps:${NC}"
    echo "1. Install Docker: ./INSTALL_DOCKER.md"
    echo "2. Configure SSL certificates: ssl/README.md"
    echo "3. Deploy: ./deploy.sh"
    echo "4. For scaled deployment: ./deploy.sh --scale"

else
    echo -e "\n${RED}🚨 Critical issues found. Please fix the failed tests above before deploying.${NC}"
    exit 1
fi

echo -e "\n${BLUE}========================================"
echo "✨ Validation Complete"
echo "========================================${NC}"