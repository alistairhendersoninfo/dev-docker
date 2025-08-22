#!/bin/bash

# Launch Docker Services Script
# Launches containers from pre-built base images

set -e

echo "🚀 Launch Docker Services"
echo "========================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
COMPOSE_FILE="docker/docker-compose.yml"
LOCAL_CONFIG_DIR="$HOME/.dev-docker"
SETTINGS_FILE="$LOCAL_CONFIG_DIR/settings.json"

# Check prerequisites
check_prerequisites() {
    # Check if we're in the right directory
    if [[ ! -f "$COMPOSE_FILE" ]]; then
        print_error "Please run this script from the project root directory"
        print_error "Expected to find: $COMPOSE_FILE"
        exit 1
    fi
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker daemon status
    if ! docker info &> /dev/null; then
        print_warning "Docker daemon is not running. Starting Docker..."
        sudo systemctl start docker
        sleep 2
    fi
    
    # Create local config if it doesn't exist
    if [[ ! -d "$LOCAL_CONFIG_DIR" ]]; then
        mkdir -p "$LOCAL_CONFIG_DIR"
    fi
}

# Check for existing singleton services
check_singleton_services() {
    local existing_traefik=$(docker ps -q -f name=traefik)
    local existing_dns=$(docker ps -q -f name=dns)
    
    if [[ -n "$existing_traefik" || -n "$existing_dns" ]]; then
        echo ""
        print_warning "Existing DNS or Traefik containers found:"
        
        if [[ -n "$existing_traefik" ]]; then
            echo "  - Traefik container: $(docker ps --format 'table {{.Names}}\t{{.Status}}' -f name=traefik | tail -n +2)"
        fi
        
        if [[ -n "$existing_dns" ]]; then
            echo "  - DNS container: $(docker ps --format 'table {{.Names}}\t{{.Status}}' -f name=dns | tail -n +2)"
        fi
        
        echo ""
        echo "Only one DNS and one Traefik container can run at a time."
        echo "What would you like to do?"
        echo "1) Stop existing containers and continue"
        echo "2) Exit (leave existing containers running)"
        echo ""
        
        read -p "Enter your choice (1-2): " singleton_choice
        
        case $singleton_choice in
            1)
                if [[ -n "$existing_traefik" ]]; then
                    print_status "Stopping existing Traefik container..."
                    docker stop traefik && docker rm traefik
                fi
                if [[ -n "$existing_dns" ]]; then
                    print_status "Stopping existing DNS container..."
                    docker stop dns && docker rm dns
                fi
                print_success "Existing containers stopped"
                ;;
            2)
                print_status "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid choice. Exiting..."
                exit 1
                ;;
        esac
    fi
}

# Configure services
configure_services() {
    local needs_config=false
    
    # Check if domain configuration is needed
    if grep -q "alistairhenderson\.info" "$COMPOSE_FILE" || grep -q "YOUR_DOMAIN\.com" "$COMPOSE_FILE"; then
        needs_config=true
    fi
    
    # Check if email configuration is needed
    if grep -q "your-email@example.com" docker/traefik/traefik.yml; then
        needs_config=true
    fi
    
    if [[ "$needs_config" == "true" ]]; then
        print_status "Configuration needed..."
        echo ""
        
        # Configure domain
        if grep -q "alistairhenderson\.info" "$COMPOSE_FILE" || grep -q "YOUR_DOMAIN\.com" "$COMPOSE_FILE"; then
            read -p "Enter your domain name (e.g., local.alistairhenderson.info): " user_domain
            if [[ -n "$user_domain" ]]; then
                sed -i "s/alistairhenderson\.info/$user_domain/g" "$COMPOSE_FILE"
                sed -i "s/YOUR_DOMAIN\.com/$user_domain/g" "$COMPOSE_FILE"
                
                if [[ -f "docker/dns/dnsmasq.conf" ]]; then
                    sed -i "s/alistairhenderson\.info/$user_domain/g" docker/dns/dnsmasq.conf
                fi
                
                print_success "Domain updated to: $user_domain"
                
                # Save to settings
                if command -v jq &> /dev/null && [[ -f "$SETTINGS_FILE" ]]; then
                    jq ".domain = \"$user_domain\"" "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
                fi
            fi
        fi
        
        # Configure email
        if grep -q "your-email@example.com" docker/traefik/traefik.yml; then
            read -p "Enter your email address for Let's Encrypt SSL certificates: " user_email
            if [[ -n "$user_email" ]]; then
                sed -i "s/your-email@example.com/$user_email/g" docker/traefik/traefik.yml
                print_success "Traefik email updated to: $user_email"
                
                # Save to settings
                if command -v jq &> /dev/null && [[ -f "$SETTINGS_FILE" ]]; then
                    jq ".email = \"$user_email\"" "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
                fi
            fi
        fi
    else
        print_success "Services already configured"
    fi
}

# Check required images
check_required_images() {
    print_status "Checking required images..."
    
    local missing_images=()
    
    # Check for base image (required by most services)
    if [[ "$(docker images -q dev-base:latest 2> /dev/null)" == "" ]]; then
        missing_images+=("dev-base:latest")
    fi
    
    if [[ ${#missing_images[@]} -gt 0 ]]; then
        print_warning "Missing required images:"
        for img in "${missing_images[@]}"; do
            echo "  - $img"
        done
        echo ""
        print_error "Please run Build-Docker-Images.sh first to build required images."
        exit 1
    fi
    
    print_success "All required images are available"
}

# Launch services
launch_services() {
    print_status "Starting all services..."
    
    # Start services
    docker compose -f "$COMPOSE_FILE" up -d
    
    # Wait for services to start
    sleep 3
    
    # Check service status
    print_status "Checking service status..."
    docker compose -f "$COMPOSE_FILE" ps
    
    print_success "All services started successfully!"
    
    # Show connection information
    echo ""
    echo "🌐 Services are now running:"
    echo "   - DNS: 172.20.0.2"
    echo "   - Traefik: http://localhost (ports 80, 443)"
    echo "   - Base Image: 172.20.0.5"
    echo "   - Project1: 172.20.0.10 (SSH: localhost:2221)"
    echo "   - Project2: 172.20.0.11 (SSH: localhost:2222)"
    echo "   - Playwright: 172.20.0.12 (SSH: localhost:2223)"
    echo ""
    echo "🔑 SSH Access:"
    echo "   ssh developer@localhost -p 2221  # Project1"
    echo "   ssh developer@localhost -p 2222  # Project2"
    echo "   ssh developer@localhost -p 2223  # Playwright"
    echo ""
    echo "📊 View logs: docker compose -f \"$COMPOSE_FILE\" logs -f"
    echo "🛑 Stop services: docker compose -f \"$COMPOSE_FILE\" down"
}

# Main function
main() {
    # Check prerequisites
    check_prerequisites
    
    # Check for existing singleton services
    check_singleton_services
    
    # Configure services
    configure_services
    
    # Check required images
    check_required_images
    
    # Launch services
    launch_services
}

# Run main function
main "$@"
