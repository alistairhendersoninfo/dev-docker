#!/bin/bash

# Project Container Creator Script
# Creates new project containers with automatic port management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PORTS_FILE=".used-ports.json"
BASE_IMAGE="dev-base:latest"
TRAEFIK_NETWORK="devnet"
TRAEFIK_IP_RANGE="172.20.0"

# Default ports for different service types
declare -A DEFAULT_PORTS
DEFAULT_PORTS["web"]="80:80,443:443"
DEFAULT_PORTS["api"]="3000:3000"
DEFAULT_PORTS["database"]="5432:5432"
DEFAULT_PORTS["redis"]="6379:6379"
DEFAULT_PORTS["ssh"]="22:22"

# Default Traefik labels for web services
declare -A TRAEFIK_LABELS
TRAEFIK_LABELS["web"]="true"
TRAEFIK_LABELS["api"]="true"
TRAEFIK_LABELS["database"]="false"
TRAEFIK_LABELS["redis"]="false"
TRAEFIK_LABELS["ssh"]="false"

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
    echo -e "${BLUE}  Project Container Creator${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check if port is available
check_port_available() {
    local port=$1
    if netstat -tuln | grep -q ":$port "; then
        return 1
    fi
    return 0
}

# Function to find next available port
find_next_available_port() {
    local base_port=$1
    local port=$base_port
    local max_attempts=100
    
    for ((i=0; i<max_attempts; i++)); do
        if check_port_available $port; then
            echo $port
            return 0
        fi
        port=$((port + 1))
    done
    
    print_error "Could not find available port starting from $base_port"
    exit 1
}

# Function to get next available IP
get_next_available_ip() {
    local base_ip="172.20.0"
    local start_ip=20
    local max_ip=254
    
    # Read existing IPs from docker-compose
    local used_ips=()
    if [ -f "docker-compose.yml" ]; then
        used_ips=($(grep -o "ipv4_address: $base_ip\.[0-9]*" docker-compose.yml | cut -d: -f2 | tr -d ' '))
    fi
    
    # Find next available IP
    for ((ip=start_ip; ip<=max_ip; ip++)); do
        local current_ip="$base_ip.$ip"
        local ip_found=false
        for used_ip in "${used_ips[@]}"; do
            if [ "$used_ip" = "$current_ip" ]; then
                ip_found=true
                break
            fi
        done
        if [ "$ip_found" = false ]; then
            echo $current_ip
            return 0
        fi
    done
    
    print_error "No available IP addresses in range $base_ip.$start_ip-$max_ip"
    exit 1
}

# Function to create docker-compose service
create_service() {
    local project_name=$1
    local service_type=$2
    local custom_ports=$3
    local domain=$4
    
    local next_ip=$(get_next_available_ip)
    local service_config=""
    
    # Base service configuration
    service_config="  $project_name:
    image: $BASE_IMAGE
    container_name: $project_name
    hostname: $project_name.docker
    networks:
      $TRAEFIK_NETWORK:
        ipv4_address: $next_ip
    dns:
      - 172.20.0.2
    depends_on:
      - base-image"
    
    # Add port mappings
    if [ -n "$custom_ports" ]; then
        local port_mappings=""
        IFS=',' read -ra PORTS <<< "$custom_ports"
        for port_pair in "${PORTS[@]}"; do
            IFS=':' read -ra PORT <<< "$port_pair"
            local internal_port=${PORT[0]}
            local external_port=${PORT[1]}
            local available_port=$(find_next_available_port $external_port)
            port_mappings="$port_mappings      - \"$available_port:$internal_port\"\n"
        done
        service_config="$service_config\n    ports:\n$port_mappings"
    fi
    
    # Add Traefik labels for web services
    if [ "${TRAEFIK_LABELS[$service_type]}" = "true" ] && [ -n "$domain" ]; then
        service_config="$service_config
    labels:
      - \"traefik.enable=true\"
      - \"traefik.http.routers.$project_name.rule=Host(\`$domain\`)\"
      - \"traefik.http.routers.$project_name.entrypoints=websecure\"
      - \"traefik.http.routers.$project_name.tls=true\"
      - \"traefik.http.routers.$project_name.tls.certresolver=letsencrypt\""
    fi
    
    echo "$service_config"
}

# Function to add service to docker-compose.yml
add_service_to_compose() {
    local project_name=$1
    local service_config=$2
    
    # Find the last service in docker-compose.yml
    local last_service_line=$(grep -n "^  [a-zA-Z]" docker-compose.yml | tail -1 | cut -d: -f1)
    
    if [ -z "$last_service_line" ]; then
        print_error "Could not find services in docker-compose.yml"
        exit 1
    fi
    
    # Insert the new service before the last service
    local insert_line=$((last_service_line - 1))
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Copy content up to insert point
    head -n $insert_line docker-compose.yml > "$temp_file"
    
    # Add new service
    echo "$service_config" >> "$temp_file"
    
    # Add empty line for spacing
    echo "" >> "$temp_file"
    
    # Copy remaining content
    tail -n +$insert_line docker-compose.yml >> "$temp_file"
    
    # Replace original file
    mv "$temp_file" docker-compose.yml
    
    print_status "Added service '$project_name' to docker-compose.yml"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <project_name> <service_type> [custom_ports] [domain]"
    echo ""
    echo "Arguments:"
    echo "  project_name    Name of the project/container"
    echo "  service_type    Type of service (web, api, database, redis, ssh)"
    echo "  custom_ports    Custom port mappings (optional, format: internal:external,internal:external)"
    echo "  domain          Domain for Traefik (optional, for web services)"
    echo ""
    echo "Examples:"
    echo "  $0 myproject web"
    echo "  $0 myapi api 3000:3000"
    echo "  $0 myweb web 80:8080,443:8443 myproject.local"
    echo "  $0 mydb database 5432:5432"
    echo ""
    echo "Service Types and Default Ports:"
    for service_type in "${!DEFAULT_PORTS[@]}"; do
        echo "  $service_type: ${DEFAULT_PORTS[$service_type]}"
    done
}

# Function to validate service type
validate_service_type() {
    local service_type=$1
    local valid_service_types=("${!DEFAULT_PORTS[@]}")
    local service_type_valid=false
    for valid_type in "${valid_service_types[@]}"; do
        if [ "$valid_type" = "$service_type" ]; then
            service_type_valid=true
            break
        fi
    done
    
    if [ "$service_type_valid" = false ]; then
        print_error "Invalid service type: $service_type"
        echo "Valid service types: ${!DEFAULT_PORTS[*]}"
        exit 1
    fi
}

# Function to check prerequisites
check_prerequisites() {
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found in current directory"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v netstat &> /dev/null; then
        print_warning "netstat not found, port checking will be limited"
    fi
}

# Main script
main() {
    print_header
    
    # Check arguments
    if [ $# -lt 2 ]; then
        show_usage
        exit 1
    fi
    
    local project_name=$1
    local service_type=$2
    local custom_ports=${3:-""}
    local domain=${4:-""}
    
    # Validate service type
    validate_service_type "$service_type"
    
    # Check prerequisites
    check_prerequisites
    
    print_status "Creating project: $project_name"
    print_status "Service type: $service_type"
    
    # Use default ports if none specified
    if [ -z "$custom_ports" ]; then
        custom_ports="${DEFAULT_PORTS[$service_type]}"
        print_status "Using default ports: $custom_ports"
    fi
    
    # Create service configuration
    local service_config=$(create_service "$project_name" "$service_type" "$custom_ports" "$domain")
    
    # Add to docker-compose.yml
    add_service_to_compose "$project_name" "$service_config"
    
    print_status "Project '$project_name' created successfully!"
    print_status "To start the service, run: docker-compose up $project_name"
    print_status "To start all services: docker-compose up"
    
    if [ "${TRAEFIK_LABELS[$service_type]}" = "true" ] && [ -n "$domain" ]; then
        print_status "Web service configured with Traefik at: https://$domain"
    fi
}

# Run main function with all arguments
main "$@"
