#!/bin/bash

# Test Discord webhook for AutoAdmin
# Usage: ./test-discord-webhook.sh YOUR_WEBHOOK_URL

if [ -z "$1" ]; then
    echo "🔗 Discord Webhook Test Script"
    echo "Usage: $0 YOUR_DISCORD_WEBHOOK_URL"
    echo ""
    echo "Example:"
    echo "$0 https://discord.com/api/webhooks/1234567890/abcdef..."
    echo ""
    echo "Or set DISCORD_WEBHOOK environment variable:"
    echo "export DISCORD_WEBHOOK='your_url_here'"
    echo "$0"
    exit 1
fi

WEBHOOK_URL="$1"
if [ -n "$DISCORD_WEBHOOK" ] && [ -z "$1" ]; then
    WEBHOOK_URL="$DISCORD_WEBHOOK"
fi

echo "🧪 Testing Discord webhook..."
echo "URL: ${WEBHOOK_URL:0:50}..."

# Create test message
TEST_DATA=$(cat <<EOF
{
    "content": "🤖 **AutoAdmin Test Notification**\\n\\n✅ Webhook is working!\\n\\n**Test Details:**\\n• Timestamp: $(date)\\n• Server: $(hostname)\\n• Status: SUCCESS\\n\\nYou'll receive AutoAdmin health reports here every 6 hours.",
    "username": "AutoAdmin Test",
    "avatar_url": "https://raw.githubusercontent.com/anthropics/claude-code/main/docs/images/claude-logo.png",
    "embeds": [
        {
            "title": "📊 System Test",
            "description": "Discord notifications are configured correctly",
            "color": 65280,
            "fields": [
                {
                    "name": "Next AutoAdmin Run",
                    "value": "$(systemctl list-timers autoadmin.timer --no-legend | awk '{print $1, $2, $3, $4}' | head -1)",
                    "inline": true
                },
                {
                    "name": "Server Uptime",
                    "value": "$(uptime -p)",
                    "inline": true
                }
            ],
            "footer": {
                "text": "AutoAdmin • Automated Server Maintenance"
            }
        }
    ]
}
EOF
)

# Send test message
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "Content-Type: application/json" \
    -H "User-Agent: AutoAdmin/1.0" \
    -X POST \
    -d "$TEST_DATA" \
    "$WEBHOOK_URL")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" -eq 204 ]; then
    echo "✅ SUCCESS! Discord webhook is working"
    echo "📱 Check your Discord channel for the test message"
    echo ""
    echo "🎉 Your AutoAdmin Discord notifications are ready!"
else
    echo "❌ FAILED! HTTP $HTTP_CODE"
    echo "Response: $RESPONSE_BODY"
    echo ""
    echo "🔍 Troubleshooting:"
    echo "• Verify webhook URL is correct"
    echo "• Check webhook wasn't deleted in Discord"
    echo "• Ensure you have internet connection"
    echo "• Try running: curl -I '$WEBHOOK_URL'"
fi