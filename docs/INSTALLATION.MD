# Development Docker Environment Installation Guide

This guide will help you set up a complete development environment using Docker containers with Traefik reverse proxy, DNS resolution, and SSH access to development containers.

## Architecture Overview

- **Base Image**: Ubuntu 22.04 with development tools (Git, Python, Node.js, Cursor CLI, OpenCode CLI, etc.)
- **Playwright Image**: Extends base image with browser automation tools  
- **Traefik**: Reverse proxy with automatic SSL certificates via Let's Encrypt
- **DNSmasq**: Local DNS server for `*.local.alistairhenderson.info` domains
- **SSH Access**: Key-based authentication to all containers

## Prerequisites

- Ubuntu 22.04 or 24.04 server
- Root or sudo access
- Domain name (e.g., `alistairhenderson.info`) with AWS Route53 access
- Ports 80, 443, and SSH (22) open on firewall

## Step 1: Server Preparation

### Update and upgrade the system

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git
```

### Create a dedicated user for development

```bash
sudo useradd -m -s /bin/bash developer
sudo usermod -aG sudo developer
sudo passwd developer

# Allow developer to use sudo without password
echo "developer ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/developer
```

### Switch to the developer user

```bash
su - developer
```

## Step 2: Install Docker

### Install Docker Engine

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Add user to docker group

```bash
sudo usermod -aG docker $USER
newgrp docker
```

**Note**: This setup uses standard Docker mode (not rootless) for better compatibility with development tools and port binding. The user is added to the `docker` group to run Docker commands without `sudo`.

**Security Note**: You can optionally restrict Docker socket permissions:

```bash
sudo chmod 666 /var/run/docker.sock
```

### Verify Docker installation

```bash
docker --version
docker compose version
```

### Enable Docker on boot

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

## Step 3: Generate SSH Keys

### Generate SSH key pair (if you don't have one)

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

### Copy public key to authorized_keys for host access

```bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### Copy private key to your local machine

```bash
# From your LOCAL machine, copy the private key from server
scp developer@YOUR_SERVER_IP:~/.ssh/id_rsa ~/.ssh/server_key

# Set correct permissions on local machine (Linux/macOS)
chmod 600 ~/.ssh/server_key

# Add to SSH config for easy access (ON YOUR LOCAL MACHINE)
echo "Host dev-server" >> ~/.ssh/config
echo "    HostName YOUR_SERVER_IP" >> ~/.ssh/config
echo "    User developer" >> ~/.ssh/config
echo "    IdentityFile ~/.ssh/server_key" >> ~/.ssh/config
```

### Convert key for Windows clients (PuTTY, SecureCRT)

**For PuTTY:**

```bash
# On your LOCAL machine, convert the key
puttygen ~/.ssh/server_key -o server_key.ppk

# Or if you have OpenSSH tools on Windows:
ssh-keygen -p -f ~/.ssh/server_key -m pem
```

**For SecureCRT:**

```bash
# SecureCRT can use OpenSSH format directly
# Just copy the ~/.ssh/server_key file to Windows
```

**Note**: The SSH config section above is for Linux/macOS users. Windows users will configure their SSH clients separately.

## Step 4: Clone and Configure the Repository

### Clone the repository

```bash
# Replace with your actual repository URL
git clone https://github.com/alistairhendersoninfo/dev-docker.git dev-docker
cd dev-docker

### Set correct permissions on SSL certificate file

```bash
chmod 600 docker/traefik/acme.json
```

### Configure AWS credentials for Route53 DNS challenge

```bash
mkdir -p ~/.aws
cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
EOF

cat > ~/.aws/config << EOF
[default]
region = eu-west-2
output = json
EOF

chmod 600 ~/.aws/credentials
chmod 600 ~/.aws/config
```

## Step 5: Configure DNS

### Update your DNS provider (Route53) with wildcard record

Create an A record in Route53:

- **Name**: `*.local.YOUR_DOMAIN`
- **Value**: Your server's public IP address
- **TTL**: 300 seconds

**Note**: Replace `YOUR_DOMAIN` with your actual domain name. The script will prompt you for this during setup.

### Verify DNS propagation

```bash
nslookup test.local.YOUR_DOMAIN
```

## Step 6: Install Host DNS Server

### Fix hostname resolution

First, ensure the hostname is properly configured in `/etc/hosts` to avoid sudo warnings:

```bash
# Check current hostname
hostname

# Update /etc/hosts to include the correct hostname mapping
# Replace 'dev-docker' with your actual hostname if different
echo "127.0.0.1 localhost
127.0.1.1 $(hostname)
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters" | sudo tee /etc/hosts
```

### Install dnsmasq on the host server

Install dnsmasq directly on the host server (not in a container) to provide DNS resolution for external clients:

```bash
sudo apt update
sudo apt install -y dnsmasq dnsutils
```

### Configure dnsmasq

Create the basic dnsmasq configuration file:

```bash
sudo tee /etc/dnsmasq.conf > /dev/null << EOF
# Basic DNS configuration
port=53
domain-needed
bogus-priv
strict-order

# Listen on all interfaces for external clients
listen-address=0.0.0.0
bind-interfaces

# Upstream DNS servers
server=8.8.8.8
server=8.8.4.4

# Configuration file for additional DNS entries
conf-dir=/etc/dnsmasq.d/,*.conf
EOF
```

### Add DNS entries for container services

Create DNS entries for all container services that point to the host IP address:

```bash
# Automatically detect the host IP address
HOST_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')
echo "Detected host IP: $HOST_IP"

# Verify the detected IP is correct
echo "Please verify this is your correct host IP address:"
ip a | grep -E "inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | grep -v "127.0.0.1" | head -5

# If the auto-detected IP is wrong, manually set it:
# HOST_IP="YOUR_ACTUAL_IP_ADDRESS"

sudo tee /etc/dnsmasq.d/container-services.conf > /dev/null << EOF
# Container service DNS entries (pointing to host IP for external access)
address=/dns.alistairhenderson.info/$HOST_IP
address=/traefik.alistairhenderson.info/$HOST_IP
address=/nginx.alistairhenderson.info/$HOST_IP
address=/base-image.alistairhenderson.info/$HOST_IP
address=/playwright.alistairhenderson.info/$HOST_IP
address=/n8n.alistairhenderson.info/$HOST_IP
address=/postgres.alistairhenderson.info/$HOST_IP
address=/api.alistairhenderson.info/$HOST_IP

# Local development domains (for container-to-container communication)
address=/.local.alistairhenderson.info/172.20.0.3
EOF

echo "DNS entries created with host IP: $HOST_IP"
```

**Note**: The script automatically detects your host IP address using the default route. If the detected IP is incorrect, you can manually set the `HOST_IP` variable before running the configuration commands.

### Restart dnsmasq to load new configuration

```bash
sudo systemctl restart dnsmasq
```

### Start and enable dnsmasq

Enable and start the dnsmasq service:

```bash
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq
```

Verify it's running:

```bash
sudo systemctl status dnsmasq
```

### Handle systemd-resolved conflicts

Disable systemd-resolved's DNS binding to avoid port conflicts:

```bash
# Stop systemd-resolved from binding to port 53
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

# Create a new resolv.conf
sudo rm /etc/resolv.conf
sudo tee /etc/resolv.conf > /dev/null << EOF
nameserver 127.0.0.1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# Make it immutable to prevent overwrites
sudo chattr +i /etc/resolv.conf
```

### Configure firewall for DNS

Install and configure firewall for DNS access:

```bash
# Install firewall if not already installed
sudo apt install -y ufw

# Allow DNS queries from external clients
sudo ufw allow 53/udp
sudo ufw allow 53/tcp

# Allow SSH access to development containers
sudo ufw allow 2221:2299/tcp
```

### Test DNS resolution

```bash
# Test basic DNS functionality
nslookup google.com 127.0.0.1

# Container-specific DNS entries will be added when you run the Launch script
# After launching containers, you can test with:
# nslookup project1-local.YOUR_DOMAIN 127.0.0.1
```

### Client DNS Configuration

To use this DNS server from external clients:

**Option A: Network-wide (Router/DHCP)**
- Set your router's DNS server to `YOUR_SERVER_IP`
- All network clients will automatically use the development DNS

**Option B: Individual client configuration**
```bash
# Linux/macOS - Add to /etc/resolv.conf (temporarily)
nameserver YOUR_SERVER_IP
nameserver 8.8.8.8

# Windows - Add to network adapter DNS settings
# Primary DNS: YOUR_SERVER_IP
# Secondary DNS: 8.8.8.8
```

**Option C: SSH Config (recommended for development)**
```bash
# Add to ~/.ssh/config on your local machine
Host *.local.YOUR_DOMAIN
    User developer
    IdentityFile ~/.ssh/dev_docker
    
# Usage examples:
# ssh project1-local.YOUR_DOMAIN -p 2221
# ssh project2-local.YOUR_DOMAIN -p 2222
# ssh playwright-local.YOUR_DOMAIN -p 2223
```

## Step 7: Build and Start Environment

### Use the automated build script (Recommended)

The easiest way to build and start everything is to use the provided build script:

```bash
./Build-Docker-Images.sh
```

This script will:
- Pull latest changes from Git
- Prompt you for your domain name and email
- Build the Docker images you choose
- Start all services automatically

### Manual build process (Alternative)

If you prefer to build manually:

```bash
# Build the base development image
docker build -t dev-base:latest docker/base-image

# Build the Playwright image  
docker build -t dev-playwright:latest docker/playwright-image

# Build the Traefik server
docker build -t dev-traefik:latest docker/traefik
```

## Step 8: Start the Environment

### Bring up all services

```bash
docker compose -f docker/docker-compose.yml up -d
```

### Check service status

```bash
docker compose -f docker/docker-compose.yml ps
docker compose -f docker/docker-compose.yml logs -f
```

## Step 9: Verify Installation

### Check Traefik dashboard

Visit: `http://YOUR_SERVER_IP:8080` (if enabled)

### Test SSH access to containers

```bash
# Test project1
ssh developer@localhost -p 2221

# Test project2  
ssh developer@localhost -p 2222

# Test playwright
ssh developer@localhost -p 2223
```

### Test domain resolution

```bash
# From inside a container
nslookup project1-local.YOUR_DOMAIN.com
nslookup project2-local.YOUR_DOMAIN.com
```

## Step 10: Base Image Hosting Options

### Option A: GitHub Container Registry (Free, Recommended)

#### Login to GHCR

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

#### Push images

```bash
make push-ghcr
```

#### Update docker-compose.yml to use GHCR images

```yaml
project1:
  image: ghcr.io/USERNAME/dev-base:latest
  # ... rest of config
```

### Option B: Local Registry Container

#### Start local registry

```bash
make setup-local-registry
```

#### Push images to local registry

```bash
make push-local
```

#### Update docker-compose.yml to use local registry

```yaml
project1:
  image: localhost:5000/dev-base:latest
  # ... rest of config
```

## Adding New Projects

### Method 1: Copy existing service

1. Copy a service block in `docker-compose.yml`
2. Update the service name, container name, hostname, and port
3. Update the Traefik labels with your domain
4. Run `docker compose up -d`

### Method 2: Use environment variables

Create a `.env` file with project-specific variables:

```bash
PROJECT_NAME=myproject
PROJECT_PORT=2224
PROJECT_IP=172.20.0.13
```

## Troubleshooting

### Common Issues

#### SSL Certificate Issues

- Check AWS credentials and Route53 permissions
- Verify DNS propagation with `nslookup`
- Check Traefik logs: `docker compose logs traefik`

#### SSH Connection Issues

- Verify SSH key permissions: `chmod 600 ~/.ssh/id_rsa`
- Check container SSH service: `docker exec -it project1 ps aux | grep sshd`
- Test from host: `ssh -v developer@localhost -p 2221`

#### DNS Resolution Issues

- Check dnsmasq logs: `docker compose logs dnsmasq`
- Verify container DNS configuration
- Test from inside container: `nslookup google.com`

### Useful Commands

```bash
# View all running containers
docker ps

# View logs for specific service
docker compose logs -f traefik

# Restart specific service
docker compose restart project1

# Rebuild and restart
docker compose down
docker compose up -d --build

# Access container shell
docker exec -it project1 bash

# View network configuration
docker network inspect dev-docker_devnet
```

## Security Considerations

- SSH keys are mounted read-only into containers
- Traefik uses Let's Encrypt for automatic SSL certificates
- All services run in isolated Docker networks
- No root access required for development containers
- Consider using UFW firewall rules for additional security

## Maintenance

### Regular Updates

```bash
# Update base images
docker compose down
docker build -t dev-base:latest base-image
docker build -t dev-playwright:latest playwright-image
docker compose up -d

# Update system packages in base image
# Edit Dockerfile and rebuild
```

### Backup

```bash
# Export base images
docker save dev-base:latest > dev-base.tar
docker save dev-playwright:latest > dev-playwright.tar

# Backup configuration
tar -czf config-backup.tar.gz docker/docker-compose.yml docker/traefik/ docker/dns/
```

## Support

For issues or questions:

1. Check the troubleshooting section above
2. Review Docker and Traefik logs
3. Verify network connectivity and DNS resolution
4. Check GitHub issues or create a new one

---

**Note**: This setup provides a production-ready development environment. For production use, consider additional security measures such as network segmentation, monitoring, and backup strategies.
