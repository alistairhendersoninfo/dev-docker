# Claude AI Instructions - Development Docker Project

## CRITICAL RULES - NEVER VIOLATE THESE

1. **NEVER try to run scripts or commands on this remote server**
2. **NEVER attempt to test Docker builds or containers**
3. **NEVER try to start services or check their status**
4. **This is a REMOTE SERVER - you cannot execute code here**

## What You CAN Do

- Read files and analyze code
- Make code changes and edits
- Search through the codebase
- Create new files
- Use git commands (add, commit, push)
- Provide information and explanations
- **Connect to remote terminal via interactive session** (see TERMINAL-CONNECTION-GUIDE.md)
- **Observe remote server activity** through terminal connection (read-only)

## What You CANNOT Do

- Run terminal commands (except git)
- Execute scripts **directly on remote server**
- Build Docker images **directly on remote server**
- Start/stop services **directly on remote server**
- Test functionality **directly on remote server**
- Access running containers **directly**

**Note**: You can observe all remote server activity through interactive terminal connection, but cannot execute commands directly.

## Project Structure

```
dev-docker/
├── start.sh                    # Main startup script (runs from project root)
├── docker/
│   ├── docker-compose.yml      # Main compose file
│   ├── base-image/             # Development base image
│   ├── traefik/                # Traefik reverse proxy
│   ├── playwright-image/       # Playwright testing image
│   └── dns/                    # DNS server (placeholder)
├── docs/                       # Documentation
└── scripts/                    # Utility scripts
```

## Key Files to Know

- **start.sh**: Main script - runs from project root, looks for docker/docker-compose.yml
- **docker/traefik/Dockerfile**: Traefik server image - COPY paths are relative to traefik directory
- **docker/base-image/Dockerfile**: Development base image with all tools
- **docker/base-image/Dockerfile.minimal**: Minimal image (VIM only)

## Common Issues to Avoid

1. **Path confusion**: Scripts run from project root, Docker builds from subdirectories
2. **File locations**: docker-compose.yml is in docker/ subdirectory, not root
3. **COPY paths**: In Dockerfiles, paths are relative to the Dockerfile's directory
4. **Git conflicts**: Always handle with git reset --hard origin/main when needed

## When Making Changes

1. **Read the file first** to understand current state
2. **Make minimal, targeted changes** - don't rewrite entire files
3. **Test your understanding** by asking questions before making changes
4. **Commit and push changes** when done
5. **Document any new functionality** in appropriate README files

## Git Workflow

```bash
# After making changes
git add .
git commit -m "Description of changes made"
git push origin main
```

## Remember

- You are helping with a REMOTE INSTALLATION
- The user will test everything on their end
- Focus on code quality and correctness
- Provide clear explanations of what you changed
- Don't assume you can test anything locally
