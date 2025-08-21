# Project Container Creator Script

A powerful bash script for automatically creating and managing multiple Docker project containers with intelligent port management, IP allocation, and Traefik integration.

## 🚀 Features

### **Automatic Resource Management**

- ✅ **Port Allocation**: Automatically finds next available external ports
- ✅ **IP Assignment**: Dynamically assigns IP addresses in your network range
- ✅ **Conflict Detection**: Prevents port and IP conflicts
- ✅ **Service Dependencies**: Automatically configures service dependencies

### **Service Type Support**

- 🌐 **Web Services**: HTTP/HTTPS with automatic Traefik configuration
- 🔌 **API Services**: Backend services with custom port support
- 🗄️ **Database Services**: Database containers with proper port mapping
- 🔴 **Redis Services**: Cache services with standard Redis ports
- 🔑 **SSH Services**: SSH-only containers for development access

### **Smart Configuration**

- 🔧 **Docker Compose Integration**: Automatically adds services to compose file
- 🌐 **Traefik Labels**: Web services get automatic HTTPS with Let's Encrypt
- 🌍 **Network Setup**: Proper IP assignment and DNS configuration
- 📁 **File Management**: Intelligent insertion into existing compose files

## 📋 Prerequisites

- Docker and Docker Compose installed
- `netstat` command available (for port checking)
- Existing `docker-compose.yml` file in the current directory
- `dev-base:latest` Docker image built

## 🛠️ Installation

1. **Download the script**:
   ```bash
   wget https://raw.githubusercontent.com/yourusername/dev-docker/main/create-project.sh
   ```

2. **Make it executable**:
   ```bash
   chmod +x create-project.sh
   ```

3. **Verify installation**:
   ```bash
   ./create-project.sh --help
   ```

## 📖 Usage

### **Basic Syntax**

```bash
./create-project.sh <project_name> <service_type> [custom_ports] [domain]
```

### **Parameters**

- **`project_name`**: Name of your project/container (required)
- **`service_type`**: Type of service (web, api, database, redis, ssh)
- **`custom_ports`**: Custom port mappings (optional, format: internal:external,internal:external)
- **`domain`**: Domain for Traefik (optional, for web services)

### **Examples**


#### **Create a Simple Web Project**

```bash
./create-project.sh mywebsite web
```
- Creates a web service with ports 80:80 and 443:443
- Automatically configures Traefik labels
- Assigns next available IP address

#### **Create an API Service**

```bash
./create-project.sh myapi api 3000:3000
```
- Creates an API service on port 3000
- Configures Traefik for API access
- Uses default API configuration

#### **Create a Web Project with Custom Ports and Domain**

```bash
./create-project.sh myapp web 80:8080,443:8443 myapp.local
```
- Maps internal ports 80/443 to external ports 8080/8443
- Configures Traefik with custom domain
- Sets up HTTPS with Let's Encrypt

#### **Create a Database Service**

```bash
./create-project.sh mydb database 5432:5432
```
- Creates a PostgreSQL-compatible service
- Maps port 5432 to next available external port
- No Traefik configuration (internal service)

#### **Create an SSH-Only Container**

```bash
./create-project.sh myssh ssh 22:2225
```
- Creates SSH-only development container
- Maps SSH port to external port 2225
- Perfect for development environments

## 🔧 Configuration

### **Default Port Mappings**

```bash
web:      80:80, 443:443
api:      3000:3000
database: 5432:5432
redis:    6379:6379
ssh:      22:22
```

### **Network Configuration**

- **Network Name**: `devnet`
- **IP Range**: `172.20.0.20` to `172.20.0.254`
- **DNS**: `172.20.0.2` (dnsmasq service)
- **Base Image**: `dev-base:latest`

### **Traefik Integration**

Web and API services automatically get:
- HTTPS with Let's Encrypt certificates
- Automatic domain routing
- Load balancing support
- Health checks

## 📁 File Structure

```
dev-docker/
├── create-project.sh          # Main script
├── examples.sh               # Usage examples
├── docker-compose.yml        # Main compose file
├── base-image/               # Base image Dockerfile
│   ├── Dockerfile
│   ├── tmux.conf
│   └── zshrc
└── README-create-project.md  # This file
```

## 🚀 Workflow

### **1. Create New Project**

```bash
./create-project.sh myproject web
```

### **2. Start the Service**

```bash
docker-compose up myproject
```

### **3. Access Your Service**

- **Web**: https://myproject.local (if domain configured)
- **SSH**: `ssh -p <port> developer@localhost`
- **Direct Port**: http://localhost:<external_port>

### **4. Manage Services**

```bash
# View logs
docker-compose logs myproject

# Stop service
docker-compose stop myproject

# Restart service
docker-compose restart myproject

# Remove service
docker-compose rm myproject
```

## 🔍 Troubleshooting

### **Common Issues**


#### **Port Already in Use**

```bash
Error: Port 8080 is already in use
```
**Solution**: The script automatically finds the next available port

#### **IP Address Conflict**

```bash
Error: No available IP addresses in range
```
**Solution**: Check your docker-compose.yml for unused IPs or extend the range

#### **Service Creation Fails**

```bash
Error: Could not find services in docker-compose.yml
```
**Solution**: Ensure docker-compose.yml exists and has at least one service

### **Debug Mode**

Add `set -x` at the top of the script for verbose output:
```bash
#!/bin/bash
set -x  # Add this line for debugging
```

## 🎯 Best Practices

### **Naming Conventions**

- ✅ **Good**: `client-website`, `api-backend`, `dev-database`
- ❌ **Bad**: `web1`, `test`, `new`

### **Port Management**

- Use default ports when possible
- Custom ports are useful for development/testing
- Avoid common ports (22, 80, 443, 3306, 5432)

### **Service Organization**

- Group related services together
- Use descriptive names for easy identification
- Document custom configurations

## 🔮 Future Enhancements

### **Planned Features**

- [ ] **Software Selection Menu**: Interactive menu for choosing development tools
- [ ] **Volume Management**: Automatic volume creation and mounting
- [ ] **Environment Variables**: Template-based environment configuration
- [ ] **Backup/Restore**: Service backup and restoration capabilities
- [ ] **Monitoring**: Built-in health checks and monitoring
- [ ] **Scaling**: Automatic service scaling based on load

### **Software Packages Menu**

The script will include an interactive menu for selecting:
- **Development Tools**: Git, Vim, VS Code, etc.
- **Programming Languages**: Node.js, Python, Rust, Go, etc.
- **Databases**: PostgreSQL, MySQL, MongoDB, Redis, etc.
- **Web Servers**: Nginx, Apache, Caddy, etc.
- **Monitoring**: Prometheus, Grafana, etc.

## 🤝 Contributing

### **How to Contribute**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### **Development Setup**

```bash
git clone https://github.com/yourusername/dev-docker.git
cd dev-docker
chmod +x create-project.sh
./create-project.sh test web
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Docker community for containerization tools
- Traefik team for reverse proxy and load balancer
- Bash scripting community for best practices
- Contributors and users of this project

## 📞 Support

### **Getting Help**

- **Issues**: Create an issue on GitHub
- **Discussions**: Use GitHub Discussions
- **Documentation**: Check this README and examples

### **Community**

- **GitHub**: [Project Repository](https://github.com/yourusername/dev-docker)
- **Discussions**: [Community Forum](https://github.com/yourusername/dev-docker/discussions)
- **Wiki**: [Project Wiki](https://github.com/yourusername/dev-docker/wiki)

---

**Happy Containerizing! 🐳✨**
