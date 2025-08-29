#!/bin/bash

# Quick Migration Script for STF
# Usage: ./quick-migration.sh [export|import|setup]

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
    echo -e "${BLUE}  STF Quick Migration${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to export from old machine
export_from_old() {
    print_header "Exporting from Old Machine"
    
    print_status "Step 1: Export current image..."
    ./build-and-export.sh export
    
    print_status "Step 2: Check export file..."
    ls -lh stf-devicefarm.tar.gz
    
    print_status "Step 3: Copy files to new machine..."
    echo "Copy these files to new machine:"
    echo "  - stf-devicefarm.tar.gz"
    echo "  - docker-compose-localhost.yaml"
    echo "  - docker-compose-prod.yaml"
    echo "  - nginx.conf"
    echo "  - nginx-localhost.conf"
    echo "  - stf-manager.sh"
    echo "  - test-flexible.sh"
    echo "  - build-and-export.sh"
    echo "  - setup-new-machine.sh"
    echo "  - MIGRATION-GUIDE.md"
    echo "  - README-FLEXIBLE.md"
    
    print_status "Export completed! Transfer files to new machine."
}

# Function to import on new machine
import_on_new() {
    print_header "Importing on New Machine"
    
    print_status "Step 1: Check if image file exists..."
    if [[ ! -f "stf-devicefarm.tar.gz" ]]; then
        print_error "stf-devicefarm.tar.gz not found!"
        print_error "Please copy the file from old machine first."
        exit 1
    fi
    
    print_status "Step 2: Import image..."
    ./build-and-export.sh import
    
    print_status "Step 3: Setup new machine..."
    ./setup-new-machine.sh
    
    print_status "Import completed! You can now start STF."
}

# Function to setup new machine
setup_new() {
    print_header "Setting up New Machine"
    
    print_status "Running setup script..."
    ./setup-new-machine.sh
    
    print_status "Setup completed!"
    echo ""
    echo "Next steps:"
    echo "  1. Start STF: ./stf-manager.sh localhost start"
    echo "  2. Test: ./test-flexible.sh localhost"
    echo "  3. Access: http://localhost:8081/"
}

# Function to show help
show_help() {
    echo -e "${BLUE}STF Quick Migration Tool${NC}"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "COMMANDS:"
    echo "  export  - Export from old machine"
    echo "  import  - Import on new machine"
    echo "  setup   - Setup new machine"
    echo "  help    - Show this help"
    echo ""
    echo "QUICK MIGRATION PROCESS:"
    echo ""
    echo "ON OLD MACHINE:"
    echo "  1. ./quick-migration.sh export"
    echo "  2. Copy files to new machine"
    echo ""
    echo "ON NEW MACHINE:"
    echo "  1. ./quick-migration.sh import"
    echo "  2. ./stf-manager.sh localhost start"
    echo ""
    echo "OR USE SETUP SCRIPT:"
    echo "  ./quick-migration.sh setup"
}

# Main function
main() {
    local command="$1"
    
    case "$command" in
        "export")
            export_from_old
            ;;
        "import")
            import_on_new
            ;;
        "setup")
            setup_new
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
