#!/bin/bash

# Examples of using the create-project.sh script
# This file shows various ways to create different types of project containers

echo "=== Project Container Creator Examples ==="
echo ""

echo "1. Create a simple web project:"
echo "   ./create-project.sh mywebsite web"
echo ""

echo "2. Create an API service with custom port:"
echo "   ./create-project.sh myapi api 3000:3000"
echo ""

echo "3. Create a web project with custom ports and domain:"
echo "   ./create-project.sh myapp web 80:8080,443:8443 myapp.local"
echo ""

echo "4. Create a database service:"
echo "   ./create-project.sh mydb database 5432:5432"
echo ""

echo "5. Create a Redis service:"
echo "   ./create-project.sh myredis redis 6379:6379"
echo ""

echo "6. Create an SSH-only container:"
echo "   ./create-project.sh myssh ssh 22:2225"
echo ""

echo "=== Service Types Available ==="
echo "web      - Web server (ports 80, 443) with Traefik support"
echo "api      - API service (port 3000) with Traefik support"
echo "database - Database service (port 5432)"
echo "redis    - Redis service (port 6379)"
echo "ssh      - SSH-only container (port 22)"
echo ""

echo "=== What Happens ==="
echo "✓ Automatically finds next available IP address"
echo "✓ Automatically finds next available external ports"
echo "✓ Adds service to docker-compose.yml"
echo "✓ Configures Traefik labels for web services"
echo "✓ Sets up proper networking and dependencies"
echo ""

echo "=== After Creation ==="
echo "1. Start the new service: docker-compose up myproject"
echo "2. Start all services: docker-compose up"
echo "3. View logs: docker-compose logs myproject"
echo "4. Stop service: docker-compose stop myproject"
echo ""

echo "=== Tips ==="
echo "• Use descriptive project names (e.g., 'client-website' not 'web1')"
echo "• Custom ports are optional - defaults work for most cases"
echo "• Domains are only needed for web services with Traefik"
echo "• Each project gets its own isolated container"
echo "• All projects share the same base image (efficient!)"
