# SSL Certificate Setup

This directory should contain the SSL certificates for sync.codeovertcp.com.

## Required Files:

1. **sync.codeovertcp.com.crt** - SSL certificate file
2. **sync.codeovertcp.com.key** - Private key file

## Certificate Generation (Self-Signed for Testing):

```bash
# Generate private key
openssl genrsa -out sync.codeovertcp.com.key 2048

# Generate certificate signing request
openssl req -new -key sync.codeovertcp.com.key -out sync.codeovertcp.com.csr

# Generate self-signed certificate (valid for 365 days)
openssl x509 -req -days 365 -in sync.codeovertcp.com.csr -signkey sync.codeovertcp.com.key -out sync.codeovertcp.com.crt
```

## Production Certificates:

For production, use Let's Encrypt:

```bash
# Install certbot
sudo apt update
sudo apt install certbot

# Generate certificates
sudo certbot certonly --standalone -d sync.codeovertcp.com

# Copy certificates to this directory
sudo cp /etc/letsencrypt/live/sync.codeovertcp.com/fullchain.pem ./sync.codeovertcp.com.crt
sudo cp /etc/letsencrypt/live/sync.codeovertcp.com/privkey.pem ./sync.codeovertcp.com.key
```

## Security Notes:

- Keep the private key file secure and never expose it
- Set appropriate permissions: `chmod 600 sync.codeovertcp.com.key`
- Ensure certificates are renewed before expiration
- Consider using automated renewal with Let's Encrypt