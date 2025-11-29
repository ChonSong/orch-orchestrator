# Authentication Service Dockerfile
# Handles user authentication, JWT tokens, and OAuth2 integration

FROM golang:1.21-alpine AS builder

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git ca-certificates tzdata

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download && go mod verify

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o auth-service \
    ./cmd/main.go

# Production stage
FROM alpine:latest

# Set labels
LABEL maintainer="GIMP Streaming Platform <platform@gimp-streaming.com>"
LABEL description="Authentication service with JWT and OAuth2 support"
LABEL version="1.0.0"

# Set environment variables
ENV APP_ENV=production
ENV APP_PORT=8080
ENV LOG_LEVEL=info
ENV JWT_EXPIRY=24h
ENV REFRESH_TOKEN_EXPIRY=168h

# Install runtime dependencies
RUN apk --no-cache add \
    ca-certificates \
    tzdata \
    curl \
    bash

# Create app user
RUN addgroup -g 1001 -S auth && \
    adduser -S auth -u 1001

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/auth-service .

# Copy configuration files
COPY --chown=auth:auth config/ ./config/

# Create necessary directories
RUN mkdir -p /app/logs /app/tmp && \
    chown -R auth:auth /app

# Create healthcheck script
RUN cat > /app/healthcheck.sh << 'EOF'
#!/bin/sh
set -e

# Check if the service is responding
if curl -f http://localhost:${APP_PORT:-8080}/health > /dev/null 2>&1; then
    exit 0
else
    exit 1
fi
EOF

RUN chmod +x /app/healthcheck.sh

# Create startup script
RUN cat > /app/start.sh << 'EOF'
#!/bin/sh
set -e

echo "Starting Authentication Service..."
echo "Environment: $APP_ENV"
echo "Port: $APP_PORT"
echo "Log Level: $LOG_LEVEL"

# Create log directory
mkdir -p /app/logs

# Start the authentication service
exec ./auth-service
EOF

RUN chmod +x /app/start.sh

# Switch to app user
USER auth

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /app/healthcheck.sh

# Start the application
CMD ["/app/start.sh"]