#!/bin/bash

# Build Docker Images Script
# Builds base images for the development environment

set -e

echo "🏗️  Build Docker Images"
echo "======================"

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

# Configuration directories
LOCAL_CONFIG_DIR="$HOME/.dev-docker"
IMAGES_REGISTRY="$LOCAL_CONFIG_DIR/images.json"
SETTINGS_FILE="$LOCAL_CONFIG_DIR/settings.json"

# Create local config directory if it doesn't exist
create_local_config() {
    if [[ ! -d "$LOCAL_CONFIG_DIR" ]]; then
        print_status "Creating local configuration directory..."
        mkdir -p "$LOCAL_CONFIG_DIR"
    fi
    
    # Initialize images registry if it doesn't exist
    if [[ ! -f "$IMAGES_REGISTRY" ]]; then
        print_status "Initializing images registry..."
        cat > "$IMAGES_REGISTRY" << 'EOF'
{
  "standard": {
    "minimal": {
      "name": "dev-minimal:latest",
      "description": "Ubuntu + basic tools",
      "built": false,
      "dockerfile": "docker/base-image/Dockerfile.minimal"
    },
    "development": {
      "name": "dev-base:latest",
      "description": "Full development environment",
      "built": false,
      "dockerfile": "docker/base-image/Dockerfile"
    },
    "playwright": {
      "name": "dev-playwright:latest",
      "description": "Browser automation tools",
      "built": false,
      "dockerfile": "docker/playwright-image/Dockerfile"
    },
    "traefik": {
      "name": "dev-traefik:latest",
      "description": "Reverse proxy server",
      "built": false,
      "dockerfile": "docker/traefik/Dockerfile"
    },
    "dns": {
      "name": "dev-dns:latest",
      "description": "Local DNS server",
      "built": false,
      "dockerfile": "docker/dns/Dockerfile"
    }
  },
  "custom": {}
}
EOF
    fi
    
    # Initialize settings if they don't exist
    if [[ ! -f "$SETTINGS_FILE" ]]; then
        print_status "Initializing settings..."
        cat > "$SETTINGS_FILE" << 'EOF'
{
  "domain": "",
  "email": "",
  "last_build": ""
}
EOF
    fi
}

# Check if image exists
check_image_exists() {
    local image_name=$1
    if [[ "$(docker images -q $image_name 2> /dev/null)" != "" ]]; then
        return 0
    else
        return 1
    fi
}

# Update image registry
update_image_registry() {
    local image_key=$1
    local built_status=$2
    
    # Use jq to update the registry if available, otherwise manual update
    if command -v jq &> /dev/null; then
        jq ".standard.$image_key.built = $built_status" "$IMAGES_REGISTRY" > "$IMAGES_REGISTRY.tmp" && mv "$IMAGES_REGISTRY.tmp" "$IMAGES_REGISTRY"
    else
        print_warning "jq not available, registry update skipped"
    fi
}

# Build image function
build_image() {
    local image_key=$1
    local image_name=$2
    local dockerfile_path=$3
    local description=$4
    
    print_status "Building $description..."
    
    if check_image_exists "$image_name"; then
        print_success "$description already exists"
        update_image_registry "$image_key" "true"
        return 0
    fi
    
    # Build the image
    if [[ "$dockerfile_path" == *"Dockerfile.minimal" ]]; then
        docker build -t "$image_name" -f "$dockerfile_path" docker/base-image
    elif [[ "$dockerfile_path" == *"base-image"* ]]; then
        docker build -t "$image_name" docker/base-image
    else
        docker build -t "$image_name" "$(dirname $dockerfile_path)"
    fi
    
    if [[ $? -eq 0 ]]; then
        print_success "$description built successfully"
        update_image_registry "$image_key" "true"
    else
        print_error "Failed to build $description"
        return 1
    fi
}

# Main function
main() {
    # Create local config
    create_local_config
    
    # Check if we're in the right directory
    if [[ ! -f "docker/docker-compose.yml" ]]; then
        print_error "Please run this script from the project root directory"
        exit 1
    fi
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    echo ""
    echo "Which base images would you like to build?"
    echo "1) Minimal base image (Ubuntu + basic tools)"
    echo "2) Development base image (Ubuntu + dev tools)"
    echo "3) Playwright base image (browser automation)"
    echo "4) Traefik base image (reverse proxy)"
    echo "5) DNS base image (local DNS server)"
    echo "6) All standard images"
    echo "7) Exit"
    echo ""
    
    read -p "Enter your choice (1-7): " build_choice
    
    case $build_choice in
        1)
            build_image "minimal" "dev-minimal:latest" "docker/base-image/Dockerfile.minimal" "Minimal base image"
            ;;
        2)
            build_image "development" "dev-base:latest" "docker/base-image/Dockerfile" "Development base image"
            ;;
        3)
            # Ensure base image exists first
            if ! check_image_exists "dev-base:latest"; then
                print_status "Building development base image first (required for Playwright)..."
                build_image "development" "dev-base:latest" "docker/base-image/Dockerfile" "Development base image"
            fi
            build_image "playwright" "dev-playwright:latest" "docker/playwright-image/Dockerfile" "Playwright base image"
            ;;
        4)
            build_image "traefik" "dev-traefik:latest" "docker/traefik/Dockerfile" "Traefik base image"
            ;;
        5)
            build_image "dns" "dev-dns:latest" "docker/dns/Dockerfile" "DNS base image"
            ;;
        6)
            print_status "Building all standard images..."
            build_image "minimal" "dev-minimal:latest" "docker/base-image/Dockerfile.minimal" "Minimal base image"
            build_image "development" "dev-base:latest" "docker/base-image/Dockerfile" "Development base image"
            build_image "playwright" "dev-playwright:latest" "docker/playwright-image/Dockerfile" "Playwright base image"
            build_image "traefik" "dev-traefik:latest" "docker/traefik/Dockerfile" "Traefik base image"
            build_image "dns" "dev-dns:latest" "docker/dns/Dockerfile" "DNS base image"
            print_success "All standard images built successfully!"
            ;;
        7)
            print_status "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please select 1-7."
            exit 1
            ;;
    esac
    
    echo ""
    print_success "Build process completed!"
    print_status "Use Launch-Docker-Services.sh to start containers from these images."
}

# Run main function
main "$@"