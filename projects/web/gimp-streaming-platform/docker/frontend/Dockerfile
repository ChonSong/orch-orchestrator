# Frontend Application Dockerfile
# Production build for React applications

FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Set labels
LABEL maintainer="GIMP Streaming Platform <platform@gimp-streaming.com>"
LABEL description="Frontend application served by Nginx"
LABEL version="1.0.0"

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Install additional Nginx modules
RUN apk add --no-cache \
    curl \
    bash

# Copy custom Nginx configuration
COPY config/nginx/frontend.conf /etc/nginx/conf.d/default.conf

# Copy built application from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Create Nginx cache directory
RUN mkdir -p /var/cache/nginx && \
    chown -R nginx:nginx /var/cache/nginx

# Create healthcheck script
RUN cat > /app/healthcheck.sh << 'EOF'
#!/bin/sh
set -e

# Check if Nginx is responding
if curl -f http://localhost:${PORT:-80}/health > /dev/null 2>&1 || \
   curl -f http://localhost:${PORT:-80}/ > /dev/null 2>&1; then
    exit 0
else
    exit 1
fi
EOF

RUN chmod +x /app/healthcheck.sh

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /app/healthcheck.sh

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]