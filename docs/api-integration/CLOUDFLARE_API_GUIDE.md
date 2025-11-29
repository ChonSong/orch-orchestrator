# Cloudflare API Administration Guide

This guide covers what you can do with your Cloudflare API key that has the following permissions:
- **All zones** - Zone:Edit, DNS:Edit, SSL and Certificates:Edit, Firewall Services:Edit, Cache Purge:Purge, Page Rules:Edit, Workers Routes:Edit
- **Analytics:Read**

## Setup

First, set up your environment variables:

```bash
export CF_API_KEY="your-cloudflare-api-key"
export CF_EMAIL="your-email@example.com"
# Or use the newer token format
export CF_TOKEN="your-bearer-token"
```

## Required Zone ID

For most operations, you'll need your zone ID:

```bash
# Get zone ID for your domain
curl -X GET "https://api.cloudflare.com/client/v4/zones?name=yourdomain.com" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json"

# Set zone ID as environment variable
export ZONE_ID="your-zone-id"
```

## Available Operations

### 1. DNS Management (DNS:Edit)

#### Add A Record (Subdomain)
```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
      "type": "A",
      "name": "app",
      "content": "1.2.3.4",
      "ttl": 3600,
      "proxied": true
     }'
```

#### List All DNS Records
```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json"
```

#### Update DNS Record
```bash
# First get the record ID
RECORD_ID="dns-record-id"

curl -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
      "type": "A",
      "name": "app",
      "content": "1.2.3.5",
      "ttl": 3600,
      "proxied": true
     }'
```

#### Delete DNS Record
```bash
curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "Authorization: Bearer $CF_TOKEN"
```

### 2. SSL Configuration (SSL and Certificates:Edit)

#### Set SSL Mode to Full (Strict)
```bash
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/ssl" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"value": "strict"}'
```

#### Available SSL Modes:
- `off` - No SSL
- `flexible` - SSL only between browser and Cloudflare
- `full` - SSL end-to-end, but allows self-signed certificates
- `strict` - SSL end-to-end with valid certificates required

#### Get Current SSL Settings
```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/ssl" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json"
```

### 3. Cache Management (Cache Purge:Purge)

#### Purge Entire Cache
```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}'
```

#### Purge Specific Files
```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
       "files": [
         "https://yourdomain.com/styles.css",
         "https://yourdomain.com/app.js"
       ]
     }'
```

#### Purge by Prefix
```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
       "prefixes": [
         "https://yourdomain.com/images/",
         "https://yourdomain.com/api/"
       ]
     }'
```

### 4. Firewall Management (Firewall Services:Edit)

#### Set Security Level
```bash
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/security_level" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"value": "medium"}'
```

#### Security Level Options:
- `off` - Security disabled
- `essentially_off` - Minimal security
- `low` - Low protection
- `medium` - Medium protection (recommended)
- `high` - High protection
- `under_attack` - Maximum protection during attacks

#### Enable/Disable Challenge Passage
```bash
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/challenge_ttl" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"value": 1800}'
```

#### Create Firewall Rule
```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/firewall/rules" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
       "description": "Block suspicious IP",
       "action": "block",
       "filter": {
         "expression": "(ip.src eq 192.168.1.1)",
         "paused": false
       }
     }'
```

### 5. Page Rules (Page Rules:Edit)

#### Create Page Rule
```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/pagerules" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
       "targets": [
         {
           "target": "url",
           "constraint": {
             "operator": "matches",
             "value": "yourdomain.com/blog/*"
           }
         }
       ],
       "actions": [
         {
           "id": "cache_level",
           "value": "cache_everything"
         }
       ],
       "status": "active"
     }'
```

#### List Page Rules
```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/pagerules" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json"
```

### 6. Workers Management (Workers Routes:Edit)

#### Deploy Worker Route
```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/workers/routes" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
       "pattern": "yourdomain.com/api/*",
       "script": "my-api-worker"
     }'
```

#### List Worker Routes
```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/workers/routes" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json"
```

### 7. Analytics (Analytics:Read)

#### Get Dashboard Analytics (Last 24 Hours)
```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/analytics/dashboard?since=-1440" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json"
```

#### Get Colocation Analytics
```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/analytics/colocation?since=-1440" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json"
```

### 8. Zone Management (Zone:Edit)

#### Get Zone Details
```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json"
```

#### Update Zone Settings
```bash
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
       "paused": false,
       "type": "full"
     }'
```

## Common Workflows

### Emergency Security Response
```bash
# 1. Set to under attack mode
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/settings/security_level" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"value": "under_attack"}'

# 2. Clear cache to ensure rules apply immediately
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}'
```

### New Subdomain Setup
```bash
# 1. Add DNS record
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
      "type": "A",
      "name": "newapp",
      "content": "1.2.3.4",
      "ttl": 3600,
      "proxied": true
     }'

# 2. Create page rule for caching
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/pagerules" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
       "targets": [
         {
           "target": "url",
           "constraint": {
             "operator": "matches",
             "value": "newapp.yourdomain.com/*"
           }
         }
       ],
       "actions": [
         {
           "id": "cache_level",
           "value": "cache_everything"
         },
         {
           "id": "browser_cache_ttl",
           "value": 86400
         }
       ],
       "status": "active"
     }'
```

## Error Handling

All Cloudflare API responses include a `success` field. Always check:

```bash
response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json")

echo $response | jq '.success'
# Check for errors
echo $response | jq '.errors'
```

## Security Notes

- Never commit your API key to version control
- Use environment variables instead of hardcoding keys
- Regularly rotate your API keys
- Use the minimum required permissions for each API key
- Consider using Cloudflare API tokens instead of global API keys

## Rate Limits

Cloudflare API has rate limits:
- ~1,200 requests per 5 minutes per account
- ~4 requests per second per account
- Burst limit of ~20 requests

For bulk operations, consider using Cloudflare's bulk endpoints or slow down your requests.