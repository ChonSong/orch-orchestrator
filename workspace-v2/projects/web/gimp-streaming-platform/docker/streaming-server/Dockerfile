# Streaming Server Container
# Handles WebRTC and VNC streaming for GIMP sessions

FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Production stage
FROM node:18-alpine

# Set labels
LABEL maintainer="GIMP Streaming Platform <platform@gimp-streaming.com>"
LABEL description="WebRTC and VNC streaming server"
LABEL version="1.0.0"

# Set environment variables
ENV NODE_ENV=production
ENV PORT=8080
ENV VNC_HOST=localhost
ENV VNC_PORT=5901
ENV WEBRTC_STUN_SERVER=stun:stun.l.google.com:19302
ENV WEBRTC_TURN_SERVER=
ENV WEBRTC_TURN_USERNAME=
ENV WEBRTC_TURN_PASSWORD=
ENV REDIS_URL=redis://redis:6379
ENV LOG_LEVEL=info

# Install system dependencies
RUN apk add --no-cache \
    # VNC client libraries
    tigervnc-viewer \
    # Graphics libraries
    ffmpeg \
    imagemagick \
    # System utilities
    curl \
    bash \
    # Network tools
    netcat-openbsd \
    # Development utilities
    git

# Create app user
RUN addgroup -g 1001 -S streaming && \
    adduser -S streaming -u 1001

# Set working directory
WORKDIR /app

# Copy app from builder
COPY --from=builder --chown=streaming:streaming /app/node_modules ./node_modules
COPY --chown=streaming:streaming . .

# Create necessary directories
RUN mkdir -p /app/logs /app/temp /app/recordings && \
    chown -R streaming:streaming /app

# Install healthcheck dependencies
RUN npm install -g wait-on

# Create healthcheck script
RUN cat > /app/healthcheck.sh << 'EOF'
#!/bin/sh
set -e

# Check if the server is responding
if curl -f http://localhost:${PORT:-8080}/health > /dev/null 2>&1; then
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

echo "Starting GIMP Streaming Server..."
echo "Environment: $NODE_ENV"
echo "Port: $PORT"
echo "VNC Host: $VNC_HOST:$VNC_PORT"

# Wait for Redis to be available
if [ -n "$REDIS_URL" ]; then
    echo "Waiting for Redis at $REDIS_URL..."
    wait-on tcp:$(echo $REDIS_URL | sed 's/.*://'):6379 || echo "Redis connection timeout"
fi

# Create log directory
mkdir -p /app/logs

# Start the streaming server
exec node server.js
EOF

RUN chmod +x /app/start.sh

# Switch to app user
USER streaming

# Expose ports
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /app/healthcheck.sh

# Start the application
CMD ["/app/start.sh"]