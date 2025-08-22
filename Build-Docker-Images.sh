#!/bin/bash

# Development Docker Environment - Start Script
# This script ensures the project is up-to-date with git and starts all services

set -e

echo "🚀 Starting Development Docker Environment"
echo "=========================================="

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

# Check if we're in the right directory
COMPOSE_FILE=""
if [[ -f "docker/docker-compose.yml" ]]; then
    COMPOSE_FILE="docker/docker-compose.yml"
else
    print_error "Please run this script from the project root directory"
    print_error "Expected to find: docker/docker-compose.yml"
    print_error ""
    print_error "Current directory: $(pwd)"
    print_error "Files in current directory:"
    ls -la | head -10
    print_error ""
    print_error "Please run this script from the project root directory where docker/docker-compose.yml is located"
    exit 1
fi

print_success "Found docker-compose file: $COMPOSE_FILE"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if user is in docker group
if ! groups | grep -q docker; then
    print_warning "User is not in docker group. Adding user to docker group..."
    sudo usermod -aG docker $USER
    print_warning "User added to docker group. Please log out and log back in, then run this script again."
    exit 0
fi

# Check Docker daemon status
print_status "Checking Docker daemon status..."
if ! docker info &> /dev/null; then
    print_warning "Docker daemon is not running. Starting Docker..."
    sudo systemctl start docker
    sleep 2
fi

# Git operations - always pull latest and handle conflicts
print_status "Checking git status and pulling latest changes..."

# Check if there are uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    print_warning "Local changes detected. Stashing them to pull latest..."
    git stash push -m "Auto-stashed by Build-Docker-Images.sh $(date)"
fi

# Fetch latest from remote
print_status "Fetching latest changes from remote..."
git fetch origin

# Check if we're behind remote
if [[ $(git rev-list HEAD..origin/main --count) -gt 0 ]]; then
    print_status "Local branch is behind remote. Updating..."
    
    # Reset to match remote exactly (this will overwrite any local changes)
    print_warning "Resetting local branch to match remote (this will overwrite local changes)..."
    git reset --hard origin/main
    
    print_success "Local branch updated to match remote"
else
    print_success "Local branch is up to date with remote"
fi

# Clean up any untracked files (optional, but keeps things clean)
print_status "Cleaning up untracked files..."
git clean -fd

print_success "Git repository is now clean and up-to-date"

# Build images if they don't exist or if forced rebuild
print_status "Checking Docker images..."

# Ask user which images to build
echo ""
echo "Which images would you like to build?"
echo "1) Minimal image only (bare shell with VIM - fastest)"
echo "2) Development image only (full tools - Cursor, OpenCode, Claude CLIs)"
echo "3) Both images (recommended for first time setup)"
echo "4) Traefik server"
echo "5) DNS server (placeholder)"
echo "6) Skip building (use existing images)"
echo "7) Exit"
echo ""

read -p "Enter your choice (1-7): " build_choice

case $build_choice in
    1)
        print_status "Building minimal image only..."
        if [[ "$(docker images -q dev-minimal:latest 2> /dev/null)" == "" ]]; then
            docker build -t dev-minimal:latest -f docker/base-image/Dockerfile.minimal docker/base-image
            print_success "Minimal image built successfully"
        else
            print_success "Minimal image already exists"
        fi
        ;;
    2)
        print_status "Building development image only..."
        if [[ "$(docker images -q dev-base:latest 2> /dev/null)" == "" ]]; then
            docker build -t dev-base:latest docker/base-image
            print_success "Development image built successfully"
        else
            print_success "Development image already exists"
        fi
        ;;
    3)
        print_status "Building both images..."
        # Build minimal image
        if [[ "$(docker images -q dev-minimal:latest 2> /dev/null)" == "" ]]; then
            print_status "Building minimal image (bare shell with VIM)..."
            docker build -t dev-minimal:latest -f docker/base-image/Dockerfile.minimal docker/base-image
            print_success "Minimal image built successfully"
        else
            print_success "Minimal image already exists"
        fi
        
        # Build development image
        if [[ "$(docker images -q dev-base:latest 2> /dev/null)" == "" ]]; then
            print_status "Building development base image (full tools)..."
            docker build -t dev-base:latest docker/base-image
            print_success "Development base image built successfully"
        else
            print_success "Development base image already exists"
        fi
        ;;
    4)
        print_status "Configuring Traefik (using official image)..."
        
        # Prompt for domain and email configuration
        print_status "Configuring Traefik domain and email..."
        
        # Check if domain is already configured (check multiple files)
        if grep -q "alistairhenderson\.info" docker/docker-compose.yml || grep -q "alistairhenderson\.info" docker/dns/dnsmasq.conf || grep -q "YOUR_DOMAIN\.com" docker/docker-compose.yml; then
            echo ""
            read -p "Enter your domain name (e.g., example.com): " user_domain
            if [[ -n "$user_domain" ]]; then
                # Update domain in docker-compose.yml
                sed -i "s/alistairhenderson\.info/$user_domain/g" docker/docker-compose.yml
                sed -i "s/YOUR_DOMAIN\.com/$user_domain/g" docker/docker-compose.yml
                
                # Update domain in dnsmasq.conf
                sed -i "s/alistairhenderson\.info/$user_domain/g" docker/dns/dnsmasq.conf
                
                print_success "Domain updated to: $user_domain"
            else
                print_warning "No domain provided, using default"
            fi
        else
            print_success "Domain already configured"
        fi
        
        # Prompt for email and update Traefik config
        print_status "Configuring Traefik email address..."
        if grep -q "your-email@example.com" docker/traefik/traefik.yml; then
            echo ""
            read -p "Enter your email address for Let's Encrypt SSL certificates: " user_email
            if [[ -n "$user_email" ]]; then
                sed -i "s/your-email@example.com/$user_email/g" docker/traefik/traefik.yml
                print_success "Traefik email updated to: $user_email"
            else
                print_warning "No email provided, using default placeholder"
            fi
        else
            print_success "Traefik email already configured"
        fi
        
        print_success "Traefik configuration updated - using official image from docker-compose.yml"
        ;;
    5)
        print_status "DNS server is a placeholder - no build needed"
        ;;
    6)
        print_status "Skipping image builds - using existing images"
        ;;
    7)
        print_status "Exiting..."
        exit 0
        ;;
    *)
        print_error "Invalid choice. Defaulting to building both images..."
        # Default to building both
        if [[ "$(docker images -q dev-minimal:latest 2> /dev/null)" == "" ]]; then
            docker build -t dev-minimal:latest -f docker/base-image/Dockerfile.minimal docker/base-image
        fi
        if [[ "$(docker images -q dev-base:latest 2> /dev/null)" == "" ]]; then
            docker build -t dev-base:latest docker/base-image
        fi
        ;;
esac

# Always check for playwright image (required for full functionality)
if [[ "$(docker images -q dev-playwright:latest 2> /dev/null)" == "" ]]; then
    print_status "Building Playwright image (required for browser automation)..."
    docker build -t dev-playwright:latest docker/playwright-image
    print_success "Playwright image built successfully"
else
    print_success "Playwright image already exists"
fi

# Start services
print_status "Starting all services..."
docker compose -f "$COMPOSE_FILE" up -d

# Wait a moment for services to start
sleep 3

# Check service status
print_status "Checking service status..."
docker compose -f "$COMPOSE_FILE" ps

print_success "All services started successfully!"
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
