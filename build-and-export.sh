#!/bin/bash

# Build and Export STF Image for easy transfer
# Usage: ./build-and-export.sh [build|export|import|help]

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  STF Build & Export Tool${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Configuration
IMAGE_NAME="stf-devicefarm"
IMAGE_TAG="latest"
EXPORT_FILE="stf-devicefarm.tar.gz"
BUILD_CONTEXT="."

# Function to build image
build_image() {
    print_header "Building STF Image"
    
    print_status "Building Docker image: $IMAGE_NAME:$IMAGE_TAG"
    
    # Check if Dockerfile exists
    if [[ ! -f "Dockerfile" ]]; then
        print_error "Dockerfile not found in current directory"
        exit 1
    fi
    
    # Build image
    docker build -t $IMAGE_NAME:$IMAGE_TAG $BUILD_CONTEXT
    
    if [[ $? -eq 0 ]]; then
        print_status "Image built successfully!"
        print_status "Image: $IMAGE_NAME:$IMAGE_TAG"
        
        # Show image info
        docker images | grep $IMAGE_NAME
    else
        print_error "Failed to build image"
        exit 1
    fi
}

# Function to export image
export_image() {
    print_header "Exporting STF Image"
    
    # Check if image exists
    if ! docker images | grep -q "$IMAGE_NAME.*$IMAGE_TAG"; then
        print_error "Image $IMAGE_NAME:$IMAGE_TAG not found. Build it first."
        exit 1
    fi
    
    print_status "Exporting image to: $EXPORT_FILE"
    
    # Export image
    docker save $IMAGE_NAME:$IMAGE_TAG | gzip > $EXPORT_FILE
    
    if [[ $? -eq 0 ]]; then
        print_status "Image exported successfully!"
        print_status "File: $EXPORT_FILE"
        
        # Show file size
        ls -lh $EXPORT_FILE
    else
        print_error "Failed to export image"
        exit 1
    fi
}

# Function to import image
import_image() {
    print_header "Importing STF Image"
    
    # Check if export file exists
    if [[ ! -f "$EXPORT_FILE" ]]; then
        print_error "Export file not found: $EXPORT_FILE"
        print_status "Available export files:"
        ls -la *.tar.gz 2>/dev/null || echo "No .tar.gz files found"
        exit 1
    fi
    
    print_status "Importing image from: $EXPORT_FILE"
    
    # Import image
    gunzip -c $EXPORT_FILE | docker load
    
    if [[ $? -eq 0 ]]; then
        print_status "Image imported successfully!"
        
        # Show imported image
        docker images | grep $IMAGE_NAME
    else
        print_error "Failed to import image"
        exit 1
    fi
}

# Function to show help
show_help() {
    echo -e "${BLUE}STF Build & Export Tool${NC}"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "COMMANDS:"
    echo "  build   - Build STF Docker image"
    echo "  export  - Export built image to file"
    echo "  import  - Import image from file"
    echo "  all     - Build and export in one step"
    echo "  help    - Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 build     - Build image only"
    echo "  $0 export    - Export image to file"
    echo "  $0 import    - Import image from file"
    echo "  $0 all       - Build and export"
    echo ""
    echo "TRANSFER TO NEW MACHINE:"
    echo "  1. Run: $0 all"
    echo "  2. Copy stf-devicefarm.tar.gz to new machine"
    echo "  3. On new machine: $0 import"
    echo "  4. Use stf-manager.sh to start services"
}

# Function to build and export
build_and_export() {
    print_header "Build and Export"
    
    build_image
    echo ""
    export_image
    
    print_status "Build and export completed!"
    print_status "You can now transfer $EXPORT_FILE to another machine"
}

# Main function
main() {
    local command="$1"
    
    case "$command" in
        "build")
            build_image
            ;;
        "export")
            export_image
            ;;
        "import")
            import_image
            ;;
        "all")
            build_and_export
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        "")
            print_error "No command specified. Use 'help' for usage information."
            exit 1
            ;;
        *)
            print_error "Unknown command: $command. Use 'help' for usage information."
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
