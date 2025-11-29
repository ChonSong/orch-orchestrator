#!/bin/bash
# Monitor IP changes and alert if it changes

IP_FILE="/home/seanos1a/.current_ip"
CURRENT_IP=$(curl -s -4 ifconfig.me)

if [ -f "$IP_FILE" ]; then
    STORED_IP=$(cat "$IP_FILE")
    if [ "$CURRENT_IP" != "$STORED_IP" ]; then
        echo "⚠️  WARNING: IP ADDRESS CHANGED!"
        echo "Old IP: $STORED_IP"
        echo "New IP: $CURRENT_IP"
        echo "Update Cloudflare DNS to point to: $CURRENT_IP"
        echo "$(date): IP changed from $STORED_IP to $CURRENT_IP" >> /home/seanos1a/ip-change-log.txt
    else
        echo "✓ IP unchanged: $CURRENT_IP"
    fi
else
    echo "First run - recording IP: $CURRENT_IP"
fi

echo "$CURRENT_IP" > "$IP_FILE"
