# STF DeviceFarm Configuration Changes Summary

## Overview
This document summarizes the changes made to convert the STF project from using `devicefarmer/stf` image to `stf-devicefarm` image.

## Files Modified

### 1. Docker Compose Files
- **`docker-compose-prod.yaml`**: Updated all STF services to use `stf-devicefarm:latest`
- **`docker-compose.yaml`**: Updated STF service to use `stf-devicefarm:latest`
- **`docker-compose.yamlo`**: Updated STF service to use `stf-devicefarm:latest`

### 2. Services Updated
All the following services now use `stf-devicefarm:latest`:
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

## Files Created

### 1. Dockerfile-devicefarm
- New Dockerfile specifically for building the `stf-devicefarm` image
- Based on the original Dockerfile with customizations for DeviceFarm
- Includes version tracking and DeviceFarm-specific configurations

### 2. Build Scripts
- **`build-devicefarm.sh`**: Script to build the `stf-devicefarm` image
- **`start-devicefarm.sh`**: Script to start the complete STF DeviceFarm environment

### 3. Configuration Files
- **`README-DEVICEFARM.md`**: Comprehensive documentation for the DeviceFarm setup
- **`env.example`**: Environment variables template
- **`CHANGES-SUMMARY.md`**: This summary file

## Configuration Details

### Image Name Change
- **Before**: `devicefarmer/stf:latest`
- **After**: `stf-devicefarm:latest`

### Network Configuration
- External network `stf-network` is required
- All services communicate through this network

### Port Mappings
- 80/443: Nginx (HTTP/HTTPS)
- 3100: STF App
- 3200: STF Auth
- 3300: STF Storage APK
- 3400: STF Storage Image
- 3500: STF Storage Temp
- 3600: STF WebSocket
- 3700: STF API
- 15000-15100: STF Provider (device ports)

## Usage Instructions

### Building the Image
```bash
./build-devicefarm.sh
```

### Starting the Services
```bash
./start-devicefarm.sh
```

### Manual Start
```bash
# Create network
docker network create stf-network

# Start services
docker-compose -f docker-compose-prod.yaml up -d
```

## Environment Variables
Key environment variables that can be configured:
- `SECRET`: Session secret for authentication
- `STF_ADMIN_EMAIL`: Admin email address
- `STF_ADMIN_NAME`: Admin name
- `TZ`: Timezone (default: America/Los_Angeles)
- `PUBLIC_IP`: Public IP address for device connections

## Health Checks
The production configuration includes health checks for:
- stf-app
- stf-auth
- stf-api
- stf-websocket

## Migration Steps
1. Stop existing containers using `devicefarmer/stf`
2. Build the new `stf-devicefarm` image
3. Create the `stf-network` if it doesn't exist
4. Start services with the new configuration

## Troubleshooting
- Ensure Docker is running
- Verify the `stf-devicefarm` image is built
- Check that the `stf-network` exists
- Monitor service logs for any issues
- Verify all required ports are available

## Next Steps
1. Build the `stf-devicefarm` image using the provided script
2. Test the configuration with a small deployment
3. Monitor the services for any issues
4. Update any custom configurations as needed 