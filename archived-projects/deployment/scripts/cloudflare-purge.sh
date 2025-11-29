# Cloudflare Cache Purge Script

# To purge Cloudflare cache for eza.codeovertcp.com, run:

# 1. Get your zone ID:
curl -X GET "https://api.cloudflare.com/client/v4/zones?name=codeovertcp.com" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json"

# 2. Purge everything for the zone:
curl -X POST "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'

# 3. Alternative: Purge specific URL:
curl -X POST "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"files":["https://eza.codeovertcp.com/"]}'
