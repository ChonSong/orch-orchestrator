# How to Reserve Your Current IP as Static in GCP

## Current Status:
- Instance: instance-20251113-20251119-092153
- Zone: us-central1-c
- Current IP: 35.208.114.195
- Type: EPHEMERAL (will change if VM stops)

## Steps to Make IP Static (via Console):

1. Go to: https://console.cloud.google.com/networking/addresses/list?project=website-478102

2. Click "RESERVE EXTERNAL STATIC ADDRESS"

3. Fill in:
   - Name: code-server-static-ip
   - IP version: IPv4
   - Type: Regional
   - Region: us-central1
   - Attached to: instance-20251113-20251119-092153

4. Click "RESERVE"

## OR Promote Current Ephemeral IP:

1. Go to: https://console.cloud.google.com/compute/instances?project=website-478102

2. Click on your instance: instance-20251113-20251119-092153

3. Click "EDIT" at the top

4. Scroll to "Network interfaces" section

5. Under "External IPv4 address", click the dropdown

6. Select "CREATE IP ADDRESS"

7. Name it: code-server-static-ip

8. Click "RESERVE"

9. Click "SAVE" at the bottom

## Cost:
- Static IP while attached to running VM: FREE
- Static IP not attached or VM stopped: ~$0.01/hour (~$7.30/month)

## After Making It Static:
Your IP (35.208.114.195) will NEVER change, even if you:
- Stop and start the VM
- Reboot the VM  
- Power cycle

## Verify Static IP:
Run: ~/check-ip-changes.sh
