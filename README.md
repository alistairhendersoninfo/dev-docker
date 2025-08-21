# Development Docker Environment

A production-ready development environment using Docker containers with automatic SSL certificates, DNS resolution, and SSH access.

## 📁 Project Structure

```
dev-docker/
├── docs/                    # Documentation and guides
│   ├── README.md           # Main project documentation
│   ├── INSTALLATION.MD     # Detailed setup instructions
│   ├── DEV-TOOLS.md        # Development tools reference
│   ├── TMUX-GUIDE.md       # Terminal multiplexer guide
│   ├── ROADMAP.md          # Development roadmap
│   ├── TODO.md             # Development tasks
│   └── README-create-project.md # Project creation guide
├── docker/                  # Docker configuration
│   ├── docker-compose.yml  # Main service definitions
│   ├── base-image/         # Base development environment
│   ├── playwright-image/   # Browser automation tools
│   ├── traefik/            # Reverse proxy configuration
│   └── dns/                # DNS server configuration
├── scripts/                 # Automation scripts
│   ├── create-project.sh   # Project creation script
│   ├── create-project-interactive.sh  # Interactive project creator
│   ├── setup.sh            # Initial setup script
│   └── examples.sh         # Usage examples
├── templates/               # Template files
│   └── project-template.yml # Docker service template
├── tools/                   # Development tools
│   ├── Makefile            # Common commands
│   └── software-config.json # Software package configuration
└── .gitignore              # Git ignore rules
```

## 🚀 Quick Start

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

### 4. Build and Run
```bash
make -f tools/Makefile build-base
docker compose -f docker/docker-compose.yml up -d
```

### 5. Access
```bash
# SSH to containers
make -f tools/Makefile ssh-project1
make -f tools/Makefile ssh-project2
make -f tools/Makefile ssh-playwright

# Visit in browser
https://project1-local.alistairhenderson.info
https://project2-local.alistairhenderson.info
https://playwright-local.alistairhenderson.info
```

## 📚 Documentation

- **[Main Documentation](docs/README.md)** - Complete project overview and setup
- **[Installation Guide](docs/INSTALLATION.MD)** - Step-by-step setup instructions
- **[Development Tools](docs/DEV-TOOLS.md)** - Available tools and packages
- **[TMUX Guide](docs/TMUX-GUIDE.md)** - Terminal multiplexer usage
- **[Project Roadmap](docs/ROADMAP.md)** - Development plans and progress
- **[Project Creator Guide](docs/README-create-project.md)** - How to create new projects

## 🛠️ Scripts

- **[Project Creator](scripts/create-project-interactive.sh)** - Interactive project setup
- **[Setup Script](scripts/setup.sh)** - Initial environment setup
- **[Examples](scripts/examples.sh)** - Usage examples and patterns

## 🐳 Docker Commands

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
```

## 🔧 Configuration

- **Docker Compose**: `docker/docker-compose.yml`
- **Base Image**: `docker/base-image/Dockerfile`
- **Traefik**: `docker/traefik/traefik.yml`
- **DNS**: `docker/dns/dnsmasq.conf`
- **Software**: `tools/software-config.json`

## 🌟 Features

- 🐳 **Base Development Image**: Ubuntu 22.04 with Git, Python, Node.js, Cursor CLI, OpenCode CLI
- 🎭 **Playwright Image**: Browser automation tools
- 🔒 **Automatic SSL**: Let's Encrypt certificates via Traefik
- 🌐 **Local DNS**: DNSmasq for `*.local.alistairhenderson.info` domains
- 🔑 **SSH Access**: Key-based authentication to all containers
- 🚀 **Easy Scaling**: Add new projects with simple scripts

## 📖 Next Steps

1. Read the [main documentation](docs/README.md) for complete details
2. Follow the [installation guide](docs/INSTALLATION.MD) for setup
3. Use the [interactive project creator](scripts/create-project-interactive.sh) to add new projects
4. Check the [roadmap](docs/ROADMAP.md) for upcoming features

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](docs/LICENSE) file for details.
