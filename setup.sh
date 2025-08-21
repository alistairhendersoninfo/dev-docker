#!/bin/bash

# Development Docker Environment Setup Script
# This script helps with initial configuration

set -e

echo "🚀 Setting up Development Docker Environment"
echo "============================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "❌ This script should not be run as root. Please run as a regular user with sudo access."
   exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Run: curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
    exit 1
fi

# Check if user is in docker group
if ! groups | grep -q docker; then
    echo "⚠️  User is not in docker group. Adding user to docker group..."
    sudo usermod -aG docker $USER
    echo "✅ User added to docker group. Please log out and log back in, then run this script again."
    exit 0
fi

# Check if SSH key exists
if [[ ! -f ~/.ssh/id_rsa ]]; then
    echo "🔑 SSH key not found. Generating new SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo "✅ SSH key generated."
fi

# Check if authorized_keys exists
if [[ ! -f ~/.ssh/authorized_keys ]]; then
    echo "📝 Creating authorized_keys file..."
    touch ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
fi

# Add public key to authorized_keys if not already there
if ! grep -q "$(cat ~/.ssh/id_rsa.pub)" ~/.ssh/authorized_keys; then
    echo "🔐 Adding public key to authorized_keys..."
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
fi

# Set correct permissions on SSL certificate file
if [[ -f traefik/acme.json ]]; then
    echo "🔒 Setting permissions on acme.json..."
    chmod 600 traefik/acme.json
fi

# Check if AWS credentials exist
if [[ ! -f ~/.aws/credentials ]]; then
    echo "⚠️  AWS credentials not found."
    echo "   Please create ~/.aws/credentials with your Route53 access keys:"
    echo "   [default]"
    echo "   aws_access_key_id = YOUR_ACCESS_KEY"
    echo "   aws_secret_access_key = YOUR_SECRET_KEY"
    echo ""
    echo "   Then run: chmod 600 ~/.aws/credentials"
fi

# Check if Traefik email is configured
if grep -q "your-email@example.com" traefik/traefik.yml; then
    echo "⚠️  Please update the email address in traefik/traefik.yml"
    echo "   Replace 'your-email@example.com' with your actual email"
fi

echo ""
echo "✅ Basic setup complete!"
echo ""
echo "Next steps:"
echo "1. Configure AWS credentials for Route53 DNS challenge"
echo "2. Update email in traefik/traefik.yml"
echo "3. Add DNS wildcard record: *.local.alistairhenderson.info → your server IP"
echo "4. Build base images: make build-base"
echo "5. Start services: docker compose up -d"
echo ""
echo "For detailed instructions, see INSTALLATION.MD"
