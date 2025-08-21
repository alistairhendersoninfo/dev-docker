# Development Docker Environment

A production-ready development environment using Docker containers with automatic SSL certificates, DNS resolution, and SSH access.

## Features

- 🐳 **Base Development Image**: Ubuntu 22.04 with Git, Python, Node.js, Cursor CLI, OpenCode CLI, and development tools
- 🎭 **Playwright Image**: Browser automation tools extending the base image
- 🔒 **Automatic SSL**: Let's Encrypt certificates via Traefik with Route53 DNS challenge
- 🌐 **Local DNS**: DNSmasq for `*.local.alistairhenderson.info` domains
- 🔑 **SSH Access**: Key-based authentication to all development containers
- 🚀 **Easy Scaling**: Add new projects with simple service definitions

## Quick Start

### 1. Prerequisites

- Ubuntu 22.04/24.04 server
- Domain with AWS Route53 access
- Ports 80, 443 open

### 2. Install Docker

```bash
curl -fsSL https://get.docker.com -o scripts/get-docker.sh
sudo sh scripts/get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
```

### 3. Clone and Setup

```bash
git clone https://github.com/alistairhendersoninfo/dev-docker.git dev-docker
cd dev-docker
./scripts/setup.sh
```

### 4. Configure

- Add AWS credentials to `~/.aws/credentials`
- Update email in `traefik/traefik.yml`
- Add DNS wildcard: `*.local.alistairhenderson.info` → your server IP

### 5. Build and Run

```bash
make -f tools/Makefile build-base
docker compose -f docker/docker-compose.yml up -d
```

### 6. Access

```bash
# SSH to containers
make ssh-project1
make ssh-project2
make ssh-playwright

# Visit in browser
https://project1-local.alistairhenderson.info
https://project2-local.alistairhenderson.info
https://playwright-local.alistairhenderson.info
```

## Architecture

```
Internet → Traefik (80/443) → Development Containers
                ↓
            DNSmasq (53)
                ↓
        *.local.alistairhenderson.info
```

- **Traefik**: Reverse proxy with automatic SSL
- **DNSmasq**: Local DNS resolution
- **Base Image**: Ubuntu with development tools
- **Playwright Image**: Browser automation tools
- **Project Containers**: Individual development environments

## Adding New Projects

### Method 1: Copy Service Block

```yaml
myproject:
  image: dev-base:latest
  container_name: myproject
  hostname: myproject.docker
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.myproject.rule=Host(`myproject-local.alistairhenderson.info`)"
    - "traefik.http.routers.myproject.entrypoints=websecure"
    - "traefik.http.routers.myproject.tls=true"
    - "traefik.http.routers.myproject.tls.certresolver=letsencrypt"
  ports:
    - "2224:22"
  networks:
    devnet:
      ipv4_address: 172.20.0.13
  dns:
    - 172.20.0.2
  depends_on:
    - base-image
```

### Method 2: Use Template

```bash
# Copy template and update
cp docker-compose.yml docker-compose.yml.backup
# Edit docker-compose.yml to add new service
docker compose up -d
```

## Base Image Hosting

### Option A: GitHub Container Registry (Free)

```bash
make push-ghcr
# Update docker-compose.yml to use ghcr.io/USERNAME/dev-base:latest
```

### Option B: Local Registry

```bash
make setup-local-registry
make push-local
# Update docker-compose.yml to use localhost:5000/dev-base:latest
```

## Commands

```bash
# Basic operations
make -f tools/Makefile up          # Start all services
make -f tools/Makefile down        # Stop all services
make -f tools/Makefile logs        # View logs
make -f tools/Makefile build-base  # Build base images

# SSH access
make -f tools/Makefile ssh-project1    # SSH to project1
make -f tools/Makefile ssh-project2    # SSH to project2
make -f tools/Makefile ssh-playwright  # SSH to playwright

# Registry operations
make -f tools/Makefile push-ghcr       # Push to GitHub Container Registry
make -f tools/Makefile push-local      # Push to local registry
```

## Configuration Files

- `docker/docker-compose.yml` - Service definitions and networking
- `docker/base-image/Dockerfile` - Base development environment
- `docker/playwright-image/Dockerfile` - Browser automation tools
- `docker/traefik/traefik.yml` - Reverse proxy configuration
- `docker/dns/dnsmasq.conf` - Local DNS server configuration
- `tools/Makefile` - Common commands and shortcuts

## Development Tools Included

### Base Image (Essential Tools)

- **Git**: Version control
- **Python 3**: Python development with basic tools
- **Node.js & npm**: JavaScript/Node.js development basics
- **Cursor CLI**: Cursor editor command line tools
- **OpenCode CLI**: OpenCode development tools
- **Vim & Neovim**: Text editors
- **SSH Server**: Secure shell access

#### Visual & Terminal Experience

- **tmux**: Terminal multiplexer with tiling layout
- **Zsh**: Advanced shell with Oh My Zsh
- **Starship**: Beautiful cross-shell prompt
- **Modern CLI Tools**: bat, exa, fd, ripgrep, procs, bottom

#### Network & System Tools

- **Network Tools**: net-tools, ping, traceroute, nmap, tcpdump
- **System Monitoring**: htop, iotop, iostat, lsof, strace
- **File Operations**: tree, fzf, zoxide

#### Database Tools

- **CLI Tools**: Prisma, TypeORM, Sequelize, Knex
- **Database GUI**: @dbgate/cli (open source alternative to DBeaver)

#### Data Processing

- **JSON**: jq, yq
- **XML**: xmltodict, yq
- **YAML**: yq

### Playwright Image (extends base)

- **Playwright**: Browser automation
- **Chromium**: Headless browser
- **Claude CLI**: AI assistant
- **All base tools**: Inherited from base image

### Additional Tools (Reference)

See [DEV-TOOLS.md](DEV-TOOLS.md) for comprehensive list of tools you can add when building specific technology stacks.

## Security

- SSH key-based authentication (no passwords)
- Automatic SSL certificates via Let's Encrypt
- Isolated Docker networks
- Read-only SSH key mounting
- No root access in development containers

## Troubleshooting

See [INSTALLATION.MD](INSTALLATION.MD) for detailed troubleshooting steps.

Common issues:
- **SSL Issues**: Check AWS credentials and DNS propagation
- **SSH Issues**: Verify key permissions and container SSH service
- **DNS Issues**: Check dnsmasq logs and container DNS configuration

## Support

1. Check the troubleshooting section in INSTALLATION.MD
2. Review Docker and Traefik logs
3. Verify network connectivity and DNS resolution
4. Check GitHub issues or create a new one

## License

