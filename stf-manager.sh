#!/bin/bash

# STF Manager - Flexible deployment for localhost and LAN
# Usage: ./stf-manager.sh [localhost|lan|auto] [start|stop|restart|status]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LOCALHOST_COMPOSE="docker-compose-localhost.yaml"
LAN_COMPOSE="docker-compose-prod.yaml"
NETWORK_NAME="stf-network"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  STF Manager - $1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to detect network mode
detect_network_mode() {
    local ip=$(hostname -I | awk '{print $1}')
    if [[ "$ip" == "127.0.0.1" ]] || [[ "$ip" == "localhost" ]]; then
        echo "localhost"
    else
        echo "lan"
    fi
}

# Function to get IP address
get_ip_address() {
    if [[ "$1" == "localhost" ]]; then
        echo "localhost"
    else
        # Get the first non-loopback IP
        hostname -I | awk '{print $1}' | head -1
    fi
}

# Function to create network if not exists
create_network() {
    if ! docker network ls | grep -q "$NETWORK_NAME"; then
        print_status "Creating Docker network: $NETWORK_NAME"
        docker network create "$NETWORK_NAME"
    else
        print_status "Network $NETWORK_NAME already exists"
    fi
}

# Function to stop all STF containers
stop_stf() {
    print_status "Stopping all STF containers..."
    docker-compose -f "$LOCALHOST_COMPOSE" down 2>/dev/null || true
    docker-compose -f "$LAN_COMPOSE" down 2>/dev/null || true
    
    # Stop individual containers if they exist
    docker stop stf-app stf-auth stf-api stf-websocket stf-provider stf-nginx 2>/dev/null || true
    docker stop stf-storage-apk stf-storage-image stf-storage-temp 2>/dev/null || true
    docker stop stf-triproxy-app stf-triproxy-dev 2>/dev/null || true
    docker stop adb rethinkdb 2>/dev/null || true
    
    print_status "All STF containers stopped"
}

# Function to start STF with specified mode
start_stf() {
    local mode="$1"
    local compose_file=""
    
    case "$mode" in
        "localhost")
            compose_file="$LOCALHOST_COMPOSE"
            print_header "Starting STF in LOCALHOST mode"
            # Copy localhost nginx config
            if [[ -f "nginx-localhost.conf" ]]; then
                print_status "Using nginx-localhost.conf"
            else
                print_warning "nginx-localhost.conf not found, using default nginx.conf"
            fi
            ;;
        "lan")
            compose_file="$LAN_COMPOSE"
            print_header "Starting STF in LAN mode"
            # Copy LAN nginx config
            if [[ -f "nginx.conf" ]]; then
                print_status "Using nginx.conf for LAN mode"
            else
                print_warning "nginx.conf not found"
            fi
            ;;
        *)
            print_error "Invalid mode: $mode. Use 'localhost' or 'lan'"
            exit 1
            ;;
    esac
    
    if [[ ! -f "$compose_file" ]]; then
        print_error "Compose file not found: $compose_file"
        exit 1
    fi
    
    # Create network
    create_network
    
    # Stop existing containers
    stop_stf
    
    # Start services
    print_status "Starting STF services with $compose_file..."
    docker-compose -f "$compose_file" up -d
    
    # Wait for services to be ready
    print_status "Waiting for services to be ready..."
    sleep 10
    
    # Check status
    check_status
}

# Function to check STF status
check_status() {
    print_header "STF Status Check"
    
    echo -e "\n${BLUE}Container Status:${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(stf|rethinkdb|adb)" || echo "No STF containers running"
    
    echo -e "\n${BLUE}Network Connectivity:${NC}"
    local ip=$(get_ip_address "$1")
    echo "Access URL: http://$ip:8081/"
    echo "Database: http://$ip:8080/"
    echo "API: http://$ip:3700/"
    
    echo -e "\n${BLUE}Service Health:${NC}"
    
    # Check database
    if docker ps | grep -q "rethinkdb"; then
        echo -e "${GREEN}✓${NC} Database: Running"
    else
        echo -e "${RED}✗${NC} Database: Not running"
    fi
    
    # Check auth service
    if docker ps | grep -q "stf-auth"; then
        echo -e "${GREEN}✓${NC} Auth Service: Running"
    else
        echo -e "${RED}✗${NC} Auth Service: Not running"
    fi
    
    # Check app service
    if docker ps | grep -q "stf-app"; then
        echo -e "${GREEN}✓${NC} App Service: Running"
    else
        echo -e "${RED}✗${NC} App Service: Not running"
    fi
    
    # Check websocket service
    if docker ps | grep -q "stf-websocket"; then
        echo -e "${GREEN}✓${NC} WebSocket Service: Running"
    else
        echo -e "${RED}✗${NC} WebSocket Service: Not running"
    fi
    
    # Check provider service
    if docker ps | grep -q "stf-provider"; then
        echo -e "${GREEN}✓${NC} Provider Service: Running"
    else
        echo -e "${RED}✗${NC} Provider Service: Not running"
    fi
    
    # Check nginx
    if docker ps | grep -q "stf-nginx"; then
        echo -e "${GREEN}✓${NC} Nginx Proxy: Running"
    else
        echo -e "${RED}✗${NC} Nginx Proxy: Not running"
    fi
    
    echo -e "\n${BLUE}Quick Test:${NC}"
    local ip=$(get_ip_address "$1")
    if curl -s -o /dev/null -w "%{http_code}" "http://$ip:8081/" | grep -q "302\|200"; then
        echo -e "${GREEN}✓${NC} Web interface accessible"
    else
        echo -e "${RED}✗${NC} Web interface not accessible"
    fi
}

# Function to show logs
show_logs() {
    local service="$1"
    if [[ -z "$service" ]]; then
        print_status "Showing logs for all STF services..."
        docker-compose -f "$LOCALHOST_COMPOSE" logs --tail=20 2>/dev/null || docker-compose -f "$LAN_COMPOSE" logs --tail=20
    else
        print_status "Showing logs for $service..."
        docker logs --tail=20 "$service" 2>/dev/null || print_error "Service $service not found"
    fi
}

# Function to restart services
restart_stf() {
    local mode="$1"
    print_header "Restarting STF"
    
    stop_stf
    sleep 2
    start_stf "$mode"
}

# Function to show help
show_help() {
    echo -e "${BLUE}STF Manager - Flexible deployment tool${NC}"
    echo ""
    echo "Usage: $0 [MODE] [COMMAND]"
    echo ""
    echo "MODES:"
    echo "  localhost  - Deploy for localhost access"
    echo "  lan        - Deploy for LAN access"
    echo "  auto       - Auto-detect mode based on network"
    echo ""
    echo "COMMANDS:"
    echo "  start      - Start STF services"
    echo "  stop       - Stop all STF services"
    echo "  restart    - Restart STF services"
    echo "  status     - Show status of all services"
    echo "  logs       - Show logs (optional: service name)"
    echo "  help       - Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 localhost start    - Start STF for localhost"
    echo "  $0 lan start          - Start STF for LAN"
    echo "  $0 auto start         - Auto-detect and start"
    echo "  $0 status             - Show current status"
    echo "  $0 logs stf-app       - Show app service logs"
}

# Main script logic
main() {
    local mode="$1"
    local command="$2"
    local service="$3"
    
    # Handle help command
    if [[ "$1" == "help" ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_help
        exit 0
    fi
    
    # Handle status command without mode
    if [[ "$1" == "status" ]]; then
        # Auto-detect mode for status
        local detected_mode=$(detect_network_mode)
        print_status "Auto-detected mode: $detected_mode"
        check_status "$detected_mode"
        exit 0
    fi
    
    # Handle logs command without mode
    if [[ "$1" == "logs" ]]; then
        show_logs "$2"
        exit 0
    fi
    
    # Auto-detect mode if not specified
    if [[ "$mode" == "auto" ]]; then
        mode=$(detect_network_mode)
        print_status "Auto-detected mode: $mode"
    fi
    
    case "$command" in
        "start")
            start_stf "$mode"
            ;;
        "stop")
            print_header "Stopping STF"
            stop_stf
            ;;
        "restart")
            restart_stf "$mode"
            ;;
        "status")
            check_status "$mode"
            ;;
        "logs")
            show_logs "$service"
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

# Run main function with all arguments
main "$@"
