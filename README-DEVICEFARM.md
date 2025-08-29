# STF DeviceFarm Configuration

## Overview
This project has been configured to use the `stf-devicefarm` Docker image instead of the original `devicefarmer/stf` image.

## Changes Made

### Docker Compose Files
The following Docker Compose files have been updated to use `stf-devicefarm:latest`:

1. `docker-compose-prod.yaml` - Production configuration with microservices
2. `docker-compose.yaml` - Simple local configuration
3. `docker-compose.yamlo` - Alternative configuration

### Services Updated
All STF services now use the `stf-devicefarm:latest` image:
- stf-app
- stf-auth
- stf-storage-apk
- stf-storage-image
- stf-storage-temp
- stf-websocket
- stf-api
- stf-provider
- stf-triproxy-app
- stf-triproxy-dev

## Usage

### Production Setup
```bash
# Create external network
docker network create stf-network

# Start all services
docker compose -f docker-compose-prod.yaml up -d
```

### Local Setup
```bash
# Start with local configuration
docker compose up -d
```

## Configuration Files

### nginx.conf
The nginx configuration remains unchanged and will work with the new image.

### Environment Variables
The following environment variables are supported:
- `SECRET` - Session secret for authentication
- `STF_ADMIN_EMAIL` - Admin email address
- `STF_ADMIN_NAME` - Admin name
- `TZ` - Timezone (default: America/Los_Angeles)

## Building the Image

If you need to build the `stf-devicefarm` image locally:

```bash
# Build the image
docker build -t stf-devicefarm:latest .

# Or build with specific tag
docker build -t stf-devicefarm:v1.0.0 .
```

## Ports

The following ports are exposed:
- 80/443 - Nginx (HTTP/HTTPS)
- 7105 - STF App
- 7120 - STF Auth
- 3300 - STF Storage APK
- 3400 - STF Storage Image
- 3500 - STF Storage Temp
- 3600 - STF WebSocket
- 3700 - STF API
- 15000-15100 - STF Provider (device ports)

## Health Checks

The production configuration includes health checks for critical services:
- stf-app
- stf-auth
- stf-api
- stf-websocket

## Troubleshooting

1. **Image not found**: Ensure the `stf-devicefarm` image is built or available
2. **Network issues**: Verify the `stf-network` exists
3. **Port conflicts**: Check if required ports are available
4. **Database connection**: Ensure RethinkDB is running and accessible

## Migration from devicefarmer/stf

To migrate from the original `devicefarmer/stf` image:

1. Stop existing containers
2. Update Docker Compose files (already done)
3. Pull or build the new image
4. Start services with new configuration

```bash
# Stop existing services
docker compose down

# Start with new image
docker compose -f docker-compose-prod.yaml up -d
``` 