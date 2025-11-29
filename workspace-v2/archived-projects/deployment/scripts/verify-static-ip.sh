#!/bin/bash

echo "Checking IP configuration..."
echo ""

CURRENT_IP=$(curl -s -4 ifconfig.me)
IP_TYPE=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/type)

echo "Current IP: $CURRENT_IP"
echo "IP Type: $IP_TYPE"
echo ""

if [ "$IP_TYPE" = "ONE_TO_ONE_NAT" ]; then
    echo "⚠️  IP is still EPHEMERAL"
    echo "   Follow the guide to convert it to static"
    echo "   Link: https://console.cloud.google.com/compute/instances?project=website-478102"
else
    echo "✓ IP appears to be configured (Type: $IP_TYPE)"
fi

echo ""
echo "To check if truly static, look for your IP here:"
echo "https://console.cloud.google.com/networking/addresses/list?project=website-478102"
echo ""
echo "If it shows 'Type: Static' and 'In use by: instance-20251113-20251119-092153', you're all set!"
