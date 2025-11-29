#!/bin/bash

# Script to create a new wildcard subdomain
# Usage: ./add-wildcard-subdomain.sh subdomain-name [content]

if [ $# -eq 0 ]; then
    echo "Usage: $0 <subdomain-name> [html-content]"
    echo "Example: $0 myapp '<h1>My App</h1><p>Welcome to my application!</p>'"
    exit 1
fi

SUBDOMAIN=$1
DOMAIN_PATH="/var/www/html/${SUBDOMAIN}.codeovertcp.com"
CONTENT=${2:-"<html><body><h1>${SUBDOMAIN}.codeovertcp.com</h1><p>This subdomain is now active!</p></body></html>"}

echo "Creating subdomain: ${SUBDOMAIN}.codeovertcp.com"

# Create directory
sudo mkdir -p "$DOMAIN_PATH"

# Create index.html with content
echo "$CONTENT" | sudo tee "$DOMAIN_PATH/index.html" > /dev/null

# Set proper permissions
sudo chown -R www-data:www-data "$DOMAIN_PATH"
sudo chmod -R 755 "$DOMAIN_PATH"

echo "✅ Created: $DOMAIN_PATH"
echo "🌐 Access: https://${SUBDOMAIN}.codeovertcp.com"
echo "🧪 Test: curl -k -H \"Host: ${SUBDOMAIN}.codeovertcp.com\" https://127.0.0.1/ --resolve ${SUBDOMAIN}.codeovertcp.com:443:127.0.0.1"