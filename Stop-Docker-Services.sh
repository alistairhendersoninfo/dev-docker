#!/bin/bash

# Stop Docker Services Script
# This script stops all running Docker services and cleans up

set -e

echo "🛑 Stopping Docker Services"
echo "============================"

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
    exit 1
fi

print_success "Found docker-compose file: $COMPOSE_FILE"

# Stop all services
print_status "Stopping all Docker services..."
docker compose -f "$COMPOSE_FILE" down

# Remove any stopped containers
print_status "Removing stopped containers..."
docker container prune -f

# Remove any unused networks
print_status "Removing unused networks..."
docker network prune -f

# Remove any unused volumes (optional - uncomment if you want to remove data)
# print_status "Removing unused volumes..."
# docker volume prune -f

print_success "All Docker services stopped and cleaned up!"
echo ""
echo "📋 To start services again, run: ./Build-Docker-Images.sh"
echo "🗑️  To remove all images: docker system prune -a"
echo "🧹 To remove everything including volumes: docker system prune -a --volumes"
