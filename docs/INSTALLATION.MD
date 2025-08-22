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

## Step 6: Build and Start Environment

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

## Step 7: Start the Environment

### Bring up all services

```bash
docker compose -f docker/docker-compose.yml up -d
```

### Check service status

```bash
docker compose -f docker/docker-compose.yml ps
docker compose -f docker/docker-compose.yml logs -f
```

## Step 8: Verify Installation

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

## Step 9: Base Image Hosting Options

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
