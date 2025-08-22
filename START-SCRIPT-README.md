# Start Script README

## Overview

The `start.sh` script is the main entry point for the Development Docker Environment. It ensures your local environment is always up-to-date with the remote git repository and handles all the setup automatically.

## What It Does

### 1. Git Management (Always Up-to-Date)
- **Automatically pulls** latest changes from git
- **Handles conflicts** by stashing local changes and resetting to remote
- **Never allows** local git changes to persist
- **Ensures clean** repository state before starting services

### 2. Docker Image Building
- **Minimal Image** (`dev-minimal:latest`): Bare shell with VIM only
- **Development Image** (`dev-base:latest`): Full development tools (Cursor, OpenCode, Claude CLIs)
- **Playwright Image** (`dev-playwright:latest`): Browser automation tools
- **Smart building**: Only rebuilds if images don't exist

### 3. Service Management
- Starts all Docker Compose services
- Checks service status
- Provides connection information

## Usage

### Basic Usage
```bash
# From project root directory
./start.sh
```

### What Happens When You Run It
1. **Checks prerequisites** (Docker, user permissions)
2. **Git operations**:
   - Stashes any local changes
   - Pulls latest from remote
   - Resets local to match remote exactly
   - Cleans untracked files
3. **Builds Docker images** (if needed)
4. **Starts all services**
5. **Shows connection info**

## Image Types

### Minimal Image (`dev-minimal:latest`)
- **Purpose**: Lightweight shell access
- **Contents**: Ubuntu + SSH + VIM + basic tools
- **Use case**: Quick debugging, minimal resource usage
- **Build command**: `docker build -t dev-minimal:latest -f docker/base-image/Dockerfile.minimal docker/base-image`

### Development Image (`dev-base:latest`)
- **Purpose**: Full development environment
- **Contents**: All tools from minimal + Cursor CLI, OpenCode CLI, Claude CLI, AI debugging tools
- **Use case**: Daily development work
- **Build command**: `docker build -t dev-base:latest docker/base-image`

### Playwright Image (`dev-playwright:latest`)
- **Purpose**: Browser automation and testing
- **Contents**: Development image + browser automation tools
- **Use case**: Testing, web scraping, browser automation
- **Build command**: `docker build -t dev-playwright:latest docker/playwright-image`

## Git Behavior

### Local Changes Are Never Preserved
- **Why**: Ensures consistent environment across team members
- **How**: Script automatically stashes and discards local changes
- **Result**: Your local environment always matches the remote repository

### Conflict Resolution
```bash
# If you have local changes:
git status --porcelain  # Shows uncommitted changes
./start.sh              # Script handles everything automatically
```

## Troubleshooting

### Permission Issues
```bash
# If you get permission errors:
sudo chmod +x start.sh
```

### Docker Issues
```bash
# If Docker isn't running:
sudo systemctl start docker

# If you're not in docker group:
sudo usermod -aG docker $USER
newgrp docker
```

### Git Issues
```bash
# If git operations fail:
git remote -v                    # Check remote configuration
git fetch origin                 # Manual fetch
git reset --hard origin/main     # Manual reset
```

## Manual Commands (if needed)

### Build Images Manually
```bash
# Minimal image
docker build -t dev-minimal:latest -f docker/base-image/Dockerfile.minimal docker/base-image

# Development image
docker build -t dev-base:latest docker/base-image

# Playwright image
docker build -t dev-playwright:latest docker/playwright-image
```

### Start Services Manually
```bash
docker compose -f docker/docker-compose.yml up -d
```

### Stop Services
```bash
docker compose -f docker/docker-compose.yml down
```

## Best Practices

1. **Always use `./start.sh`** instead of manual commands
2. **Don't make local git changes** - they'll be overwritten
3. **Run from project root** directory
4. **Check output** for any warnings or errors
5. **Use minimal image** for quick operations
6. **Use development image** for daily work

## File Locations

- **Start script**: `./start.sh` (project root)
- **Minimal Dockerfile**: `docker/base-image/Dockerfile.minimal`
- **Development Dockerfile**: `docker/base-image/Dockerfile`
- **Playwright Dockerfile**: `docker/playwright-image/Dockerfile`
- **Docker Compose**: `docker/docker-compose.yml`

## Why This Approach?

- **Consistency**: Everyone gets the same environment
- **Simplicity**: One command to start everything
- **Reliability**: Handles conflicts automatically
- **Flexibility**: Multiple image types for different needs
- **Maintenance**: Easy to update and manage
