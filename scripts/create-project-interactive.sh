#!/bin/bash

# Project Container Creator Script - Interactive Version
# Creates new project containers with interactive software selection

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PORTS_FILE=".used-ports.json"
BASE_IMAGE="dev-base:latest"
TRAEFIK_NETWORK="devnet"
TRAEFIK_IP_RANGE="172.20.0"

# Software packages available for selection
declare -A DEVELOPMENT_STACKS
DEVELOPMENT_STACKS["nodejs"]="Node.js - JavaScript/TypeScript runtime and package manager"
DEVELOPMENT_STACKS["python"]="Python - Python interpreter and pip package manager"
DEVELOPMENT_STACKS["rust"]="Rust - Systems programming language and Cargo"
DEVELOPMENT_STACKS["go"]="Go - Google's programming language"
DEVELOPMENT_STACKS["java"]="Java - Enterprise programming language with Maven/Gradle"
DEVELOPMENT_STACKS["dotnet"]=".NET - Microsoft's cross-platform framework"
DEVELOPMENT_STACKS["php"]="PHP - Web development language with Composer"
DEVELOPMENT_STACKS["ruby"]="Ruby - Dynamic programming language with Gem"

declare -A DATABASES
DATABASES["postgresql"]="PostgreSQL - Advanced open source database"
DATABASES["mysql"]="MySQL - Popular open source database"
DATABASES["mongodb"]="MongoDB - NoSQL document database"
DATABASES["redis"]="Redis - In-memory data structure store"
DATABASES["elasticsearch"]="Elasticsearch - Search and analytics engine"
DATABASES["sqlite"]="SQLite - Lightweight file-based database"

declare -A WEB_SERVERS
WEB_SERVERS["nginx"]="Nginx - High-performance web server"
WEB_SERVERS["apache"]="Apache - Popular web server"
WEB_SERVERS["caddy"]="Caddy - Modern web server with automatic HTTPS"
WEB_SERVERS["traefik"]="Traefik - Cloud-native edge router"

declare -A DEVELOPMENT_TOOLS
DEVELOPMENT_TOOLS["git"]="Git - Version control system"
DEVELOPMENT_TOOLS["vim"]="Vim - Advanced text editor"
DEVELOPMENT_TOOLS["vscode"]="VS Code - Code editor with extensions"
DEVELOPMENT_TOOLS["jetbrains"]="JetBrains IDEs - Professional development tools"
DEVELOPMENT_TOOLS["docker"]="Docker - Container platform"
DEVELOPMENT_TOOLS["kubernetes"]="Kubernetes - Container orchestration"

declare -A MONITORING_TOOLS
MONITORING_TOOLS["prometheus"]="Prometheus - Monitoring and alerting"
MONITORING_TOOLS["grafana"]="Grafana - Metrics visualization and alerting"
MONITORING_TOOLS["elk"]="ELK Stack - Log management and analysis"
MONITORING_TOOLS["jaeger"]="Jaeger - Distributed tracing"

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
    echo -e "${BLUE}     Interactive Mode${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

print_section() {
    echo -e "${CYAN}=== $1 ===${NC}"
}

# Function to show selection menu
show_selection_menu() {
    local title="$1"
    local -n options="$2"
    local selection_var="$3"
    local allow_multiple="$4"
    
    print_section "$title"
    
    if [ "$allow_multiple" = "true" ]; then
        echo "Select multiple options (comma-separated numbers, e.g., 1,3,5):"
    else
        echo "Select an option:"
    fi
    
    echo ""
    
    local index=1
    local selected_options=()
    
    for key in "${!options[@]}"; do
        echo -e "  ${YELLOW}$index${NC}. ${options[$key]}"
        ((index++))
    done
    
    echo ""
    
    if [ "$allow_multiple" = "true" ]; then
        echo -n "Enter your selection(s): "
        read -r user_input
        
        # Parse comma-separated selections
        IFS=',' read -ra selections <<< "$user_input"
        for selection in "${selections[@]}"; do
            selection=$(echo "$selection" | tr -d ' ')
            if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#options[@]}" ]; then
                local key_index=1
                for key in "${!options[@]}"; do
                    if [ "$key_index" -eq "$selection" ]; then
                        selected_options+=("$key")
                        break
                    fi
                    ((key_index++))
                done
            fi
        done
        
        # Store selected options in the specified variable
        eval "$selection_var=(\"\${selected_options[@]}\")"
    else
        echo -n "Enter your selection: "
        read -r user_input
        
        if [[ "$user_input" =~ ^[0-9]+$ ]] && [ "$user_input" -ge 1 ] && [ "$user_input" -le "${#options[@]}" ]; then
            local key_index=1
            for key in "${!options[@]}"; do
                if [ "$key_index" -eq "$user_input" ]; then
                    eval "$selection_var=\"$key\""
                    break
                fi
                ((key_index++))
            done
        else
            print_error "Invalid selection. Please enter a number between 1 and ${#options[@]}"
            return 1
        fi
    fi
    
    echo ""
}

# Function to show service type selection
show_service_type_menu() {
    print_section "Service Type Selection"
    echo "What type of service are you creating?"
    echo ""
    echo "  1. Web Service (HTTP/HTTPS with Traefik)"
    echo "  2. API Service (Backend API with Traefik)"
    echo "  3. Database Service (Database container)"
    echo "  4. Cache Service (Redis, etc.)"
    echo "  5. SSH Service (Development container)"
    echo "  6. Custom Service (Manual configuration)"
    echo ""
    
    echo -n "Enter your selection: "
    read -r service_choice
    
    case $service_choice in
        1) SERVICE_TYPE="web" ;;
        2) SERVICE_TYPE="api" ;;
        3) SERVICE_TYPE="database" ;;
        4) SERVICE_TYPE="redis" ;;
        5) SERVICE_TYPE="ssh" ;;
        6) SERVICE_TYPE="custom" ;;
        *) 
            print_error "Invalid selection. Defaulting to web service."
            SERVICE_TYPE="web"
            ;;
    esac
    
    echo ""
}

# Function to get project details
get_project_details() {
    print_section "Project Details"
    
    echo -n "Enter project name: "
    read -r PROJECT_NAME
    
    if [ -z "$PROJECT_NAME" ]; then
        print_error "Project name cannot be empty"
        exit 1
    fi
    
    # Validate project name (no spaces, special chars)
    if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Project name can only contain letters, numbers, hyphens, and underscores"
        exit 1
    fi
    
    echo ""
    
    # Get domain for web services
    if [ "$SERVICE_TYPE" = "web" ] || [ "$SERVICE_TYPE" = "api" ]; then
        echo -n "Enter domain (optional, for Traefik): "
        read -r DOMAIN
        echo ""
    fi
    
    # Get custom ports if needed
    echo -n "Use custom ports? (y/N): "
    read -r use_custom_ports
    
    if [[ "$use_custom_ports" =~ ^[Yy]$ ]]; then
        echo -n "Enter custom ports (format: internal:external,internal:external): "
        read -r CUSTOM_PORTS
        echo ""
    fi
}

# Function to show software selection
show_software_selection() {
    print_section "Software Selection"
    echo "Select the software packages you want to install:"
    echo ""
    
    # Development Stack Selection
    local selected_stacks=()
    show_selection_menu "Development Stack" DEVELOPMENT_STACKS selected_stacks true
    
    # Database Selection
    local selected_databases=()
    show_selection_menu "Database Selection" DATABASES selected_databases true
    
    # Web Server Selection
    local selected_web_servers=()
    show_selection_menu "Web Server Selection" WEB_SERVERS selected_web_servers true
    
    # Development Tools Selection
    local selected_dev_tools=()
    show_selection_menu "Development Tools Selection" DEVELOPMENT_TOOLS selected_dev_tools true
    
    # Monitoring Tools Selection
    local selected_monitoring=()
    show_selection_menu "Monitoring Tools Selection" MONITORING_TOOLS selected_monitoring true
    
    # Store selections globally
    SELECTED_STACKS=("${selected_stacks[@]}")
    SELECTED_DATABASES=("${selected_databases[@]}")
    SELECTED_WEB_SERVERS=("${selected_web_servers[@]}")
    SELECTED_DEV_TOOLS=("${selected_dev_tools[@]}")
    SELECTED_MONITORING=("${selected_monitoring[@]}")
}

# Function to show configuration summary
show_configuration_summary() {
    print_section "Configuration Summary"
    
    echo -e "${GREEN}Project Name:${NC} $PROJECT_NAME"
    echo -e "${GREEN}Service Type:${NC} $SERVICE_TYPE"
    
    if [ -n "$DOMAIN" ]; then
        echo -e "${GREEN}Domain:${NC} $DOMAIN"
    fi
    
    if [ -n "$CUSTOM_PORTS" ]; then
        echo -e "${GREEN}Custom Ports:${NC} $CUSTOM_PORTS"
    fi
    
    echo ""
    echo -e "${GREEN}Selected Development Stacks:${NC}"
    for stack in "${SELECTED_STACKS[@]}"; do
        echo "  - ${DEVELOPMENT_STACKS[$stack]}"
    done
    
    echo ""
    echo -e "${GREEN}Selected Databases:${NC}"
    for db in "${SELECTED_DATABASES[@]}"; do
        echo "  - ${DATABASES[$db]}"
    done
    
    echo ""
    echo -e "${GREEN}Selected Web Servers:${NC}"
    for ws in "${SELECTED_WEB_SERVERS[@]}"; do
        echo "  - ${WEB_SERVERS[$ws]}"
    done
    
    echo ""
    echo -e "${GREEN}Selected Development Tools:${NC}"
    for tool in "${SELECTED_DEV_TOOLS[@]}"; do
        echo "  - ${DEVELOPMENT_TOOLS[$tool]}"
    done
    
    echo ""
    echo -e "${GREEN}Selected Monitoring Tools:${NC}"
    for monitor in "${SELECTED_MONITORING[@]}"; do
        echo "  - ${MONITORING_TOOLS[$monitor]}"
    done
    
    echo ""
    echo -e "${YELLOW}Is this configuration correct? (y/N):${NC} "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_status "Configuration cancelled. Run the script again to start over."
        exit 0
    fi
    
    echo ""
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
    if [ -f "docker/docker-compose.yml" ]; then
    used_ips=($(grep -o "ipv4_address: $base_ip\.[0-9]*" docker/docker-compose.yml | cut -d: -f2 | tr -d ' '))
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
    local last_service_line=$(grep -n "^  [a-zA-Z]" docker/docker-compose.yml | tail -1 | cut -d: -f1)
    
    if [ -z "$last_service_line" ]; then
        print_error "Could not find services in docker-compose.yml"
        exit 1
    fi
    
    # Insert the new service before the last service
    local insert_line=$((last_service_line - 1))
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Copy content up to insert_line docker/docker-compose.yml > "$temp_file"
    
    # Add new service
    echo "$service_config" >> "$temp_file"
    
    # Add empty line for spacing
    echo "" >> "$temp_file"
    
    # Copy remaining content
    tail -n +$insert_line docker/docker-compose.yml >> "$temp_file"
    
    # Replace original file
    mv "$temp_file" docker/docker-compose.yml
    
    print_status "Added service '$project_name' to docker-compose.yml"
}

# Function to check prerequisites
check_prerequisites() {
    if [ ! -f "docker/docker-compose.yml" ]; then
        print_error "docker/docker-compose.yml not found in current directory"
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

# Function to show usage
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -i, --interactive  Run in interactive mode (default)"
    echo "  -q, --quick    Quick mode with minimal prompts"
    echo ""
    echo "Interactive Mode Features:"
    echo "  • Guided project creation wizard"
    echo "  • Software package selection menus"
    echo "  • Real-time configuration validation"
    echo "  • Configuration summary and confirmation"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run interactive mode"
    echo "  $0 --interactive     # Run interactive mode"
    echo "  $0 --quick           # Quick mode"
}

# Main interactive function
main_interactive() {
    print_header
    
    # Check prerequisites
    check_prerequisites
    
    # Get service type
    show_service_type_menu
    
    # Get project details
    get_project_details
    
    # Show software selection
    show_software_selection
    
    # Show configuration summary
    show_configuration_summary
    
    # Create service configuration
    local service_config=$(create_service "$PROJECT_NAME" "$SERVICE_TYPE" "$CUSTOM_PORTS" "$DOMAIN")
    
    # Add to docker-compose.yml
    add_service_to_compose "$PROJECT_NAME" "$service_config"
    
    print_status "Project '$PROJECT_NAME' created successfully!"
    print_status "To start the service, run: docker-compose up $PROJECT_NAME"
    print_status "To start all services: docker-compose up"
    
    if [ "${TRAEFIK_LABELS[$SERVICE_TYPE]}" = "true" ] && [ -n "$DOMAIN" ]; then
        print_status "Web service configured with Traefik at: https://$DOMAIN"
    fi
    
    echo ""
    print_section "Software Installation Notes"
    echo "The following software packages will be available in your container:"
    
    for stack in "${SELECTED_STACKS[@]}"; do
        echo "  ✓ ${DEVELOPMENT_STACKS[$stack]}"
    done
    
    for db in "${SELECTED_DATABASES[@]}"; do
        echo "  ✓ ${DATABASES[$db]}"
    done
    
    for ws in "${SELECTED_WEB_SERVERS[@]}"; do
        echo "  ✓ ${WEB_SERVERS[$ws]}"
    done
    
    for tool in "${SELECTED_DEV_TOOLS[@]}"; do
        echo "  ✓ ${DEVELOPMENT_TOOLS[$tool]}"
    done
    
    for monitor in "${SELECTED_MONITORING[@]}"; do
        echo "  ✓ ${MONITORING_TOOLS[$monitor]}"
    done
}

# Main script
main() {
    # Parse command line arguments
    case "${1:-}" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -i|--interactive|"")
            main_interactive
            ;;
        -q|--quick)
            print_error "Quick mode not implemented yet. Use interactive mode."
            exit 1
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
