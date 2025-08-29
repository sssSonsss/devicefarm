#!/bin/bash

# Test script for STF flexible deployment
# Tests both localhost and LAN modes

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
    echo -e "${BLUE}  STF Flexible Test - $1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Test localhost mode
test_localhost() {
    print_header "Testing Localhost Mode"
    
    print_status "Starting localhost mode..."
    ./stf-manager.sh localhost start
    
    sleep 5
    
    print_status "Testing localhost URLs..."
    
    # Test main URL
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8081/" | grep -q "302\|200"; then
        echo -e "${GREEN}✓${NC} Main URL: http://localhost:8081/"
    else
        echo -e "${RED}✗${NC} Main URL: http://localhost:8081/"
    fi
    
    # Test auth URL
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8081/auth/mock/" | grep -q "200"; then
        echo -e "${GREEN}✓${NC} Auth URL: http://localhost:8081/auth/mock/"
    else
        echo -e "${RED}✗${NC} Auth URL: http://localhost:8081/auth/mock/"
    fi
    
    # Test database URL
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/" | grep -q "200"; then
        echo -e "${GREEN}✓${NC} Database URL: http://localhost:8080/"
    else
        echo -e "${RED}✗${NC} Database URL: http://localhost:8080/"
    fi
    
    # Test API URL
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:3700/" | grep -q "200\|404"; then
        echo -e "${GREEN}✓${NC} API URL: http://localhost:3700/"
    else
        echo -e "${RED}✗${NC} API URL: http://localhost:3700/"
    fi
}

# Test LAN mode
test_lan() {
    print_header "Testing LAN Mode"
    
    print_status "Starting LAN mode..."
    ./stf-manager.sh lan start
    
    sleep 5
    
    # Get LAN IP
    local lan_ip=$(hostname -I | awk '{print $1}' | head -1)
    
    print_status "Testing LAN URLs (IP: $lan_ip)..."
    
    # Test main URL
    if curl -s -o /dev/null -w "%{http_code}" "http://$lan_ip:8081/" | grep -q "302\|200"; then
        echo -e "${GREEN}✓${NC} Main URL: http://$lan_ip:8081/"
    else
        echo -e "${RED}✗${NC} Main URL: http://$lan_ip:8081/"
    fi
    
    # Test auth URL
    if curl -s -o /dev/null -w "%{http_code}" "http://$lan_ip:8081/auth/mock/" | grep -q "200"; then
        echo -e "${GREEN}✓${NC} Auth URL: http://$lan_ip:8081/auth/mock/"
    else
        echo -e "${RED}✗${NC} Auth URL: http://$lan_ip:8081/auth/mock/"
    fi
    
    # Test database URL
    if curl -s -o /dev/null -w "%{http_code}" "http://$lan_ip:8080/" | grep -q "200"; then
        echo -e "${GREEN}✓${NC} Database URL: http://$lan_ip:8080/"
    else
        echo -e "${RED}✗${NC} Database URL: http://$lan_ip:8080/"
    fi
    
    # Test API URL
    if curl -s -o /dev/null -w "%{http_code}" "http://$lan_ip:3700/" | grep -q "200\|404"; then
        echo -e "${GREEN}✓${NC} API URL: http://$lan_ip:3700/"
    else
        echo -e "${RED}✗${NC} API URL: http://$lan_ip:3700/"
    fi
}

# Test auto-detect
test_auto() {
    print_header "Testing Auto-Detect Mode"
    
    print_status "Starting auto-detect mode..."
    ./stf-manager.sh auto start
    
    sleep 5
    
    print_status "Auto-detect completed. Check status:"
    ./stf-manager.sh status
}

# Main test function
main() {
    local test_type="$1"
    
    case "$test_type" in
        "localhost")
            test_localhost
            ;;
        "lan")
            test_lan
            ;;
        "auto")
            test_auto
            ;;
        "all")
            test_localhost
            echo ""
            test_lan
            echo ""
            test_auto
            ;;
        *)
            echo "Usage: $0 [localhost|lan|auto|all]"
            echo ""
            echo "Test types:"
            echo "  localhost - Test localhost mode only"
            echo "  lan       - Test LAN mode only"
            echo "  auto      - Test auto-detect mode only"
            echo "  all       - Test all modes"
            exit 1
            ;;
    esac
    
    print_header "Test Completed"
    print_status "All tests finished!"
}

# Run main function
main "$@"
