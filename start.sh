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
elif [[ -f "docker-compose.yml" ]]; then
    COMPOSE_FILE="docker-compose.yml"
else
    print_error "Please run this script from the project root directory"
    print_error "Expected to find either:"
    print_error "  - docker/docker-compose.yml (current structure)"
    print_error "  - docker-compose.yml (alternative structure)"
    print_error ""
    print_error "Current directory: $(pwd)"
    print_error "Files in current directory:"
    ls -la | head -10
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
    git stash push -m "Auto-stashed by start.sh $(date)"
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

# Check if minimal image exists
if [[ "$(docker images -q dev-minimal:latest 2> /dev/null)" == "" ]]; then
    print_status "Building minimal image (bare shell with VIM)..."
    docker build -t dev-minimal:latest -f docker/base-image/Dockerfile.minimal docker/base-image
    print_success "Minimal image built successfully"
else
    print_success "Minimal image already exists"
fi

# Check if dev-base image exists
if [[ "$(docker images -q dev-base:latest 2> /dev/null)" == "" ]]; then
    print_status "Building development base image (full tools)..."
    docker build -t dev-base:latest docker/base-image
    print_success "Development base image built successfully"
else
    print_success "Development base image already exists"
fi

# Check if playwright image exists
if [[ "$(docker images -q dev-playwright:latest 2> /dev/null)" == "" ]]; then
    print_status "Building Playwright image..."
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
