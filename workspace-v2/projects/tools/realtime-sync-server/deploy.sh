#!/bin/bash

# Sync Server Deployment Script
# Production deployment for sync.codeovertcp.com

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Configuration
PROJECT_DIR="/home/seanos1a/realtime-sync-server"
DOCKER_COMPOSE_FILE="docker-compose.production.yml"
SCALE_FILE="docker-compose.scale.yml"
SERVICE_NAME="sync-server"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root"
fi

# Change to project directory
cd "$PROJECT_DIR" || error "Failed to change to project directory"

# Parse command line arguments
DEPLOYMENT_TYPE="single"
SCALE=false
RECREATE=false
LOGS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --scale)
            SCALE=true
            DEPLOYMENT_TYPE="scaled"
            DOCKER_COMPOSE_FILE="$SCALE_FILE"
            shift
            ;;
        --recreate)
            RECREATE=true
            shift
            ;;
        --logs)
            LOGS=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --scale      Deploy with horizontal scaling (3 instances + HAProxy)"
            echo "  --recreate   Force recreation of containers"
            echo "  --logs       Show logs after deployment"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

log "Starting deployment of sync.codeovertcp.com (Mode: $DEPLOYMENT_TYPE)"

# Check prerequisites
log "Checking prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    error "Docker is not installed or not in PATH"
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    error "Docker Compose is not installed or not in PATH"
fi

# Check if .env.production exists
if [[ ! -f ".env.production" ]]; then
    error ".env.production file not found. Please create it from the example."
fi

# Check if SSL certificates exist
if [[ ! -f "ssl/sync.codeovertcp.com.crt" ]] || [[ ! -f "ssl/sync.codeovertcp.com.key" ]]; then
    warning "SSL certificates not found in ssl/ directory"
    warning "Please add certificates before accessing HTTPS endpoints"
fi

# Create necessary directories
log "Creating necessary directories..."
mkdir -p /home/seanos1a/{sync-data,sync-logs,redis-data,nginx-logs}

# Pull latest images
log "Pulling latest Docker images..."
docker-compose -f "$DOCKER_COMPOSE_FILE" pull

# Stop existing services
log "Stopping existing services..."
docker-compose -f "$DOCKER_COMPOSE_FILE" down

# Build application image
log "Building application image..."
docker-compose -f "$DOCKER_COMPOSE_FILE" build

# Start services
if [[ "$RECREATE" == "true" ]]; then
    log "Starting services with forced recreation..."
    docker-compose -f "$DOCKER_COMPOSE_FILE" up -d --force-recreate
else
    log "Starting services..."
    docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
fi

# Wait for services to be ready
log "Waiting for services to be ready..."
sleep 30

# Health checks
log "Performing health checks..."

# Check Redis
if docker-compose -f "$DOCKER_COMPOSE_FILE" exec -T redis redis-cli ping &> /dev/null; then
    success "Redis is healthy"
else
    error "Redis health check failed"
fi

# Check sync server
sleep 10
if curl -f http://localhost:3001/api/health &> /dev/null; then
    success "Sync server is healthy"
else
    warning "Sync server health check failed (may still be starting)"
fi

# Check Nginx/HAProxy
if curl -f http://localhost/api/health &> /dev/null; then
    success "Load balancer is healthy"
else
    warning "Load balancer health check failed (may still be starting)"
fi

# Show status
log "Service status:"
docker-compose -f "$DOCKER_COMPOSE_FILE" ps

# Show logs if requested
if [[ "$LOGS" == "true" ]]; then
    log "Showing service logs (press Ctrl+C to exit)..."
    docker-compose -f "$DOCKER_COMPOSE_FILE" logs -f
fi

# Deployment complete
success "Deployment completed successfully!"
success ""
success "Services:"
if [[ "$SCALE" == "true" ]]; then
    success "  - Load Balancer (HAProxy): http://localhost:8404/stats (statistics)"
else
    success "  - Nginx Reverse Proxy: http://localhost (HTTP)"
fi
success "  - Sync Server API: http://localhost:3001/api/health"
success "  - Redis: localhost:6379"
success ""
success "SSL certificates: $(if [[ -f "ssl/sync.codeovertcp.com.crt" ]]; then echo "✅ Configured"; else echo "❌ Missing"; fi)"
success ""
success "Next steps:"
success "1. Configure DNS for sync.codeovertcp.com to point to this server"
success "2. Set up SSL certificates (if not done already)"
success "3. Test the service at https://sync.codeovertcp.com"
success "4. Monitor logs: docker-compose -f $DOCKER_COMPOSE_FILE logs -f"