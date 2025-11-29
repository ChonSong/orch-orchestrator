#!/bin/bash

# Sync Server Monitoring Script
# Monitors the health and performance of sync.codeovertcp.com

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SYNC_URL="https://sync.codeovertcp.com"
SYNC_PORT="3003"
REDIS_PORT="6380"
LOG_FILE="/var/log/sync-server-monitor.log"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[OK] $1${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}" | tee -a "$LOG_FILE"
}

# Check if sync server process is running
check_sync_process() {
    if pgrep -f "node.*server.js" > /dev/null; then
        local pid=$(pgrep -f "node.*server.js")
        success "Sync server process is running (PID: $pid)"
        return 0
    else
        error "Sync server process is not running"
        return 1
    fi
}

# Check sync server health endpoint
check_sync_health() {
    local response=$(curl -k -s -w "%{http_code}" "$SYNC_URL/api/health" 2>/dev/null)
    local http_code="${response: -3}"
    local body="${response%???}"

    if [[ "$http_code" == "200" ]]; then
        local active_conn=$(echo "$body" | grep -o '"activeConnections":[0-9]*' | cut -d: -f2)
        success "Health endpoint: OK (HTTP $http_code, Active connections: $active_conn)"
        return 0
    else
        error "Health endpoint failed (HTTP $http_code)"
        return 1
    fi
}

# Check Redis connectivity
check_redis() {
    if redis-cli -p "$REDIS_PORT" ping > /dev/null 2>&1; then
        local redis_info=$(redis-cli -p "$REDIS_PORT" info server | grep redis_version)
        local version=$(echo "$redis_info" | cut -d: -f2 | tr -d '\r')
        success "Redis is running (Version: $version)"
        return 0
    else
        error "Redis is not responding on port $REDIS_PORT"
        return 1
    fi
}

# Check Nginx configuration
check_nginx() {
    if nginx -t > /dev/null 2>&1; then
        success "Nginx configuration is valid"
        return 0
    else
        error "Nginx configuration error"
        nginx -t
        return 1
    fi
}

# Check SSL certificate
check_ssl() {
    local cert_file="/home/seanos1a/realtime-sync-server/ssl/sync.codeovertcp.com.crt"

    if [[ -f "$cert_file" ]]; then
        local expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate | cut -d= -f2)
        local expiry_timestamp=$(date -d "$expiry_date" +%s)
        local current_timestamp=$(date +%s)
        local days_until_expiry=$(( (expiry_timestamp - current_timestamp) / 86400 ))

        if [[ $days_until_expiry -gt 30 ]]; then
            success "SSL certificate is valid ($days_until_expiry days until expiry)"
            return 0
        elif [[ $days_until_expiry -gt 0 ]]; then
            warning "SSL certificate expires in $days_until_expiry days"
            return 0
        else
            error "SSL certificate has expired"
            return 1
        fi
    else
        error "SSL certificate not found at $cert_file"
        return 1
    fi
}

# Check port availability
check_ports() {
    local ports_sync=0

    if netstat -tulpn | grep ":$SYNC_PORT " > /dev/null; then
        success "Port $SYNC_PORT (Sync Server) is listening"
    else
        error "Port $SYNC_PORT (Sync Server) is not listening"
        ports_sync=1
    fi

    if netstat -tulpn | grep ":443 " > /dev/null; then
        success "Port 443 (HTTPS) is listening"
    else
        error "Port 443 (HTTPS) is not listening"
        ports_sync=1
    fi

    if netstat -tulpn | grep ":80 " > /dev/null; then
        success "Port 80 (HTTP) is listening"
    else
        error "Port 80 (HTTP) is not listening"
        ports_sync=1
    fi

    return $ports_sync
}

# Check system resources
check_system_resources() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    local memory_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    local disk_usage=$(df -h /home | tail -1 | awk '{print $5}' | sed 's/%//')

    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        warning "High CPU usage: ${cpu_usage}%"
    else
        success "CPU usage: ${cpu_usage}%"
    fi

    if (( $(echo "$memory_usage > 80" | bc -l) )); then
        warning "High memory usage: ${memory_usage}%"
    else
        success "Memory usage: ${memory_usage}%"
    fi

    if [[ $disk_usage -gt 80 ]]; then
        warning "High disk usage: ${disk_usage}%"
    else
        success "Disk usage: ${disk_usage}%"
    fi
}

# Main monitoring function
run_monitoring() {
    echo "======================================="
    echo "🔍 Sync Server Monitoring Report"
    echo "======================================="
    echo "Timestamp: $(date)"
    echo ""

    local exit_code=0

    # Run all checks
    check_sync_process || exit_code=1
    echo ""

    check_sync_health || exit_code=1
    echo ""

    check_redis || exit_code=1
    echo ""

    check_nginx || exit_code=1
    echo ""

    check_ssl || exit_code=1
    echo ""

    check_ports || exit_code=1
    echo ""

    check_system_resources
    echo ""

    echo "======================================="
    if [[ $exit_code -eq 0 ]]; then
        success "All critical checks passed!"
        info "Sync server is running normally"
    else
        error "Some checks failed. Please review the issues above."
    fi
    echo "======================================="

    return $exit_code
}

# Setup log file
setup_logging() {
    sudo mkdir -p "$(dirname "$LOG_FILE")"
    sudo touch "$LOG_FILE"
    sudo chown $USER:$USER "$LOG_FILE"
}

# Handle script arguments
case "${1:-run}" in
    "setup")
        setup_logging
        info "Monitoring setup complete"
        ;;
    "run"|"")
        run_monitoring
        ;;
    "continuous")
        setup_logging
        info "Starting continuous monitoring (every 60 seconds)"
        info "Press Ctrl+C to stop"
        while true; do
            clear
            run_monitoring
            sleep 60
        done
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  run         Run monitoring once (default)"
        echo "  setup       Set up logging"
        echo "  continuous  Run monitoring continuously every 60 seconds"
        echo "  help        Show this help message"
        ;;
    *)
        error "Unknown command: $1"
        echo "Run '$0 help' for usage information"
        exit 1
        ;;
esac