# Supported Software and Versions

This document provides a comprehensive overview of all software packages, tools, and versions supported by the Development Docker Environment.

## 📋 Table of Contents

- [Development Stacks](#development-stacks)
- [Databases](#databases)
- [Web Servers](#web-servers)
- [Development Tools](#development-tools)
- [Monitoring Tools](#monitoring-tools)
- [CLI Tools](#cli-tools)
- [Legacy Tools](#legacy-tools)
- [Package Managers](#package-managers)
- [Version Management](#version-management)
- [Legacy Support](#legacy-support)
- [Installation Methods](#installation-methods)

## 🚀 Development Stacks

### Node.js
**Description**: JavaScript/TypeScript runtime and package manager

**Versions Supported**:
- **Latest**: 21.x (default)
- **LTS**: 20.x
- **Current**: 21.x
- **Legacy**: 6.x through 20.x

**Specific Versions**:
- 21: 21.0.0
- 20: 20.10.0
- 19: 19.9.0
- 18: 18.19.0
- 17: 17.9.1
- 16: 16.20.2
- 15: 15.14.0
- 14: 14.21.3
- 13: 13.14.0
- 12: 12.22.12
- 11: 11.15.0
- 10: 10.24.1
- 9: 9.11.2
- 8: 8.17.0
- 7: 7.10.1
- 6: 6.17.1

**Installation Methods**:
- Ubuntu: APT with NodeSource repository
- Alpine: APK packages
- Manual: Direct download and setup

**Post-Install**:
- npm upgrade to latest
- yarn installation

---

### Python
**Description**: Python interpreter and pip package manager

**Versions Supported**:
- **Latest**: 3.12 (default)
- **Stable**: 3.11
- **Legacy**: 3.0 through 3.11

**Specific Versions**:
- 3.12: 3.12.0
- 3.11: 3.11.0
- 3.10: 3.10.0
- 3.9: 3.9.18
- 3.8: 3.8.18
- 3.7: 3.7.17
- 3.6: 3.6.15
- 3.5: 3.5.10
- 3.4: 3.4.10
- 3.3: 3.3.7
- 3.2: 3.2.6
- 3.1: 3.1.5
- 3.0: 3.0.1

**Installation Methods**:
- Ubuntu: APT packages
- Alpine: APK packages
- Manual: Source compilation

**Post-Install**:
- pip upgrade
- virtualenv installation

---

### PHP
**Description**: Web development language with Composer

**Versions Supported**:
- **Latest**: 8.3 (default)
- **Stable**: 8.2
- **Legacy**: 7.0 through 8.2

**Specific Versions**:
- 8.3: 8.3.0
- 8.2: 8.2.0
- 8.1: 8.1.0
- 8.0: 8.0.0
- 7.4: 7.4.0
- 7.3: 7.3.0
- 7.2: 7.2.0
- 7.1: 7.1.0
- 7.0: 7.0.0

**Installation Methods**:
- Ubuntu: APT with Ondřej Surý PPA
- Alpine: APK packages
- Manual: Source compilation

**Extensions Included**:
- CLI, FPM, MySQL, XML, cURL, mbstring, zip
- Composer package manager

---

### Rust
**Description**: Systems programming language and Cargo

**Versions Supported**:
- **Latest**: stable (default)
- **Stable**: stable
- **Nightly**: nightly

**Installation Methods**:
- Universal: rustup installer

**Post-Install**:
- cargo-edit
- cargo-watch

---

### Go
**Description**: Google's programming language

**Versions Supported**:
- **Latest**: 1.22 (default)
- **Stable**: 1.21
- **Legacy**: 1.10 through 1.21

**Specific Versions**:
- 1.22: 1.22.0
- 1.21: 1.21.5
- 1.20: 1.20.12
- 1.19: 1.19.13
- 1.18: 1.18.10
- 1.17: 1.17.13
- 1.16: 1.16.15
- 1.15: 1.15.15
- 1.14: 1.14.15
- 1.13: 1.13.15
- 1.12: 1.12.17
- 1.11: 1.11.13
- 1.10: 1.10.8

**Installation Methods**:
- Ubuntu: APT packages
- Alpine: APK packages
- Manual: Binary distribution

---

### Java
**Description**: Enterprise programming language with Maven/Gradle

**Versions Supported**:
- **Latest**: 21 (default)
- **LTS**: 17
- **Legacy**: 8 through 20

**Specific Versions**:
- 21: 21.0.1
- 20: 20.0.2
- 19: 19.0.2
- 18: 18.0.2
- 17: 17.0.8
- 16: 16.0.2
- 15: 15.0.2
- 14: 14.0.2
- 13: 13.0.2
- 12: 12.0.2
- 11: 11.0.20
- 10: 10.0.2
- 9: 9.0.4
- 8: 1.8.0_392

**Installation Methods**:
- Ubuntu: APT with OpenJDK PPA
- Alpine: APK packages

**Build Tools**:
- Maven
- Gradle

---

### .NET
**Description**: Microsoft's cross-platform framework

**Versions Supported**:
- **Latest**: 8.0 (default)
- **LTS**: 8.0
- **Legacy**: 6.0

**Installation Methods**:
- Ubuntu: APT with Microsoft repository
- Alpine: APK packages

---

### Ruby
**Description**: Dynamic programming language with Gem

**Versions Supported**:
- **Latest**: 3.2 (default)
- **Stable**: 3.2
- **Legacy**: 2.7

**Installation Methods**:
- Ubuntu: APT packages
- Alpine: APK packages

**Package Manager**: Bundler

---

## 🗄️ Databases

### PostgreSQL
**Description**: Advanced open source database

**Versions Supported**:
- **Latest**: 16 (default)
- **Stable**: 15
- **LTS**: 14
- **Legacy**: 10 through 15

**Specific Versions**:
- 16: 16.0
- 15: 15.4
- 14: 14.11
- 13: 13.14
- 12: 12.18
- 11: 11.23
- 10: 10.23

**Default Port**: 5432

**Installation Methods**:
- Ubuntu: APT with PostgreSQL repository
- Alpine: APK packages
- Manual: Source compilation

---

### MySQL
**Description**: Popular open source database

**Versions Supported**:
- **Latest**: 8.0 (default)
- **Stable**: 8.0
- **LTS**: 5.7
- **Legacy**: 5.6

**Specific Versions**:
- 8.0: 8.0.35
- 5.7: 5.7.44
- 5.6: 5.6.51

**Default Port**: 3306

**Installation Methods**:
- Ubuntu: APT with MySQL repository
- Alpine: APK packages
- Manual: Binary distribution

---

### MongoDB
**Description**: NoSQL document database

**Versions Supported**:
- **Latest**: 6.0 (default)
- **Stable**: 6.0
- **Legacy**: 5.0

**Default Port**: 27017

**Installation Methods**:
- Ubuntu: APT with MongoDB repository
- Alpine: APK packages

---

### Redis
**Description**: In-memory data structure store

**Versions Supported**:
- **Latest**: 7.2 (default)
- **Stable**: 7.2
- **LTS**: 6.2

**Default Port**: 6379

**Installation Methods**:
- Ubuntu: APT packages
- Alpine: APK packages

---

### Elasticsearch
**Description**: Search and analytics engine

**Versions Supported**:
- **Latest**: 8.11 (default)
- **Stable**: 8.11
- **LTS**: 7.17

**Default Port**: 9200

**Installation Methods**:
- Ubuntu: APT with Elastic repository
- Alpine: APK packages

---

### SQLite
**Description**: Lightweight file-based database

**Versions Supported**:
- **Latest**: 3.44 (default)
- **Stable**: 3.44
- **Legacy**: 3.39

**Installation Methods**:
- Ubuntu: APT packages
- Alpine: APK packages

---

## 🌐 Web Servers

### Nginx
**Description**: High-performance web server

**Versions Supported**:
- **Latest**: 1.24 (default)
- **Stable**: 1.24
- **LTS**: 1.22

**Default Port**: 80

**Installation Methods**:
- Ubuntu: APT packages
- Alpine: APK packages

---

### Apache
**Description**: Popular web server

**Versions Supported**:
- **Latest**: 2.4 (default)
- **Stable**: 2.4
- **LTS**: 2.4

**Default Port**: 80

**Installation Methods**:
- Ubuntu: APT packages
- Alpine: APK packages

---

### Caddy
**Description**: Modern web server with automatic HTTPS

**Versions Supported**:
- **Latest**: 2.7 (default)
- **Stable**: 2.7
- **Beta**: 2.8

**Default Port**: 80

**Installation Methods**:
- Universal: Cloudsmith repository

---

### Traefik
**Description**: Cloud-native edge router

**Versions Supported**:
- **Latest**: 3.0 (default)
- **Stable**: 3.0
- **Beta**: 3.1

**Default Port**: 80

**Installation Methods**:
- Universal: Binary download

---

## 🛠️ Development Tools

### Git
**Description**: Version control system

**Versions Supported**:
- **Latest**: 2.42 (default)
- **Stable**: 2.42
- **LTS**: 2.41

**Installation Methods**:
- Ubuntu: APT packages
- Alpine: APK packages

**Post-Install**:
- Default branch: main
- Pull strategy: merge

---

### Vim
**Description**: Advanced text editor

**Versions Supported**:
- **Latest**: 9.0 (default)
- **Stable**: 9.0
- **Legacy**: 8.2

**Installation Methods**:
- Ubuntu: APT packages
- Alpine: APK packages

---

### VS Code
**Description**: Code editor with extensions

**Versions Supported**:
- **Latest**: 1.85 (default)
- **Stable**: 1.85
- **Insider**: 1.86

**Installation Methods**:
- Ubuntu: APT with Microsoft repository
- Alpine: APK packages

---

### JetBrains IDEs
**Description**: Professional development tools

**Versions Supported**:
- **Latest**: 2023.3 (default)
- **Stable**: 2023.3
- **EAP**: 2024.1

**Available IDEs**:
- IntelliJ IDEA Community
- PyCharm Community
- WebStorm

**Installation Methods**:
- Universal: Snap packages
- Manual: Toolbox App

---

### Docker
**Description**: Container platform

**Versions Supported**:
- **Latest**: 24.0 (default)
- **Stable**: 24.0
- **Edge**: 25.0

**Installation Methods**:
- Ubuntu: APT with Docker repository
- Alpine: APK packages

**Post-Install**:
- Add user to docker group
- Enable Docker service

---

### Kubernetes
**Description**: Container orchestration

**Versions Supported**:
- **Latest**: 1.28 (default)
- **Stable**: 1.28
- **LTS**: 1.27

**Installation Methods**:
- Ubuntu: APT with Kubernetes repository
- Alpine: APK packages

---

## 📊 Monitoring Tools

### Prometheus
**Description**: Monitoring and alerting

**Versions Supported**:
- **Latest**: 2.47 (default)
- **Stable**: 2.47
- **Beta**: 2.48

**Default Port**: 9090

**Installation Methods**:
- Universal: Binary download

---

### Grafana
**Description**: Metrics visualization and alerting

**Versions Supported**:
- **Latest**: 10.2 (default)
- **Stable**: 10.2
- **Beta**: 10.3

**Default Port**: 3000

**Installation Methods**:
- Ubuntu: APT with Grafana repository
- Alpine: APK packages

---

### ELK Stack
**Description**: Log management and analysis

**Components**:
- **Elasticsearch**: 8.11
- **Logstash**: 8.11
- **Kibana**: 8.11

**Default Ports**:
- Elasticsearch: 9200
- Logstash: 5044
- Kibana: 5601

**Installation Methods**:
- Ubuntu: APT with Elastic repository
- Alpine: APK packages

---

### Jaeger
**Description**: Distributed tracing

**Versions Supported**:
- **Latest**: 1.53 (default)
- **Stable**: 1.53
- **Beta**: 1.54

**Default Port**: 16686

**Installation Methods**:
- Universal: Docker image

---

## 🔧 CLI Tools

### Cursor CLI
**Description**: AI-powered code editor CLI

**Versions Supported**:
- **Latest**: 0.1.0 (default)
- **Stable**: 0.1.0

**Installation Methods**:
- Universal: Install script

---

### OpenCode CLI
**Description**: AI-powered development assistant

**Versions Supported**:
- **Latest**: 1.0.0 (default)
- **Stable**: 1.0.0

**Installation Methods**:
- Universal: Install script
- NPM: opencode-ai package

---

## 🔄 Legacy Tools

### PHPBrew
**Description**: PHP version manager for multiple PHP versions

**Versions Supported**:
- **Latest**: 1.27.0 (default)

**Installation Methods**:
- Universal: GitHub release download

---

### pyenv
**Description**: Python version manager for multiple Python versions

**Versions Supported**:
- **Latest**: 2.3.25 (default)

**Installation Methods**:
- Universal: pyenv-installer script

---

### NVM
**Description**: Node.js version manager for multiple Node.js versions

**Versions Supported**:
- **Latest**: 0.39.0 (default)

**Installation Methods**:
- Universal: GitHub install script

---

### rbenv
**Description**: Ruby version manager for multiple Ruby versions

**Versions Supported**:
- **Latest**: 1.2.0 (default)

**Installation Methods**:
- Universal: rbenv-installer script

---

## 📦 Package Managers

### npm
**Description**: Node Package Manager

**Versions Supported**:
- **Latest**: 10.2 (default)
- **Stable**: 10.2
- **LTS**: 9.8

**Installation Methods**:
- Universal: Install script

---

### pip
**Description**: Python Package Installer

**Versions Supported**:
- **Latest**: 23.3 (default)
- **Stable**: 23.3
- **Legacy**: 22.3

**Installation Methods**:
- Universal: get-pip.py script

---

### Cargo
**Description**: Rust package manager

**Versions Supported**:
- **Latest**: 1.75 (default)
- **Stable**: 1.75
- **Nightly**: 1.76

**Installation Methods**:
- Universal: rustup installer

---

## 🔄 Version Management

### PHP Version Switching
**Recommended Tool**: phpbrew
**Alternative Tools**: phpenv, update-alternatives

**Features**:
- Multiple PHP versions on same system
- Easy switching between versions
- Extension management per version

---

### Python Version Switching
**Recommended Tool**: pyenv
**Alternative Tools**: conda, update-alternatives

**Features**:
- Multiple Python versions on same system
- Virtual environment management
- Global and local version control

---

### Node.js Version Switching
**Recommended Tool**: nvm
**Alternative Tools**: n, fnm

**Features**:
- Multiple Node.js versions on same system
- Easy switching between versions
- Global package management per version

---

### PostgreSQL Version Switching
**Recommended Tool**: pg_switch
**Alternative Tools**: update-alternatives

**Features**:
- Multiple PostgreSQL versions on same system
- Data directory management
- Service management per version

---

### MySQL Version Switching
**Recommended Tool**: mysql_switch
**Alternative Tools**: update-alternatives

**Features**:
- Multiple MySQL versions on same system
- Configuration management
- Service management per version

---

## 🏛️ Legacy Support

### PHP Legacy Features
- **7.0**: Basic OOP and modern PHP features
- **7.1**: Improved performance over 7.0
- **7.2**: Better type hints and performance
- **7.3**: Flexible heredoc syntax
- **7.4**: Typed properties and arrow functions

### Python Legacy Features
- **3.6**: f-strings and type annotations
- **3.7**: Data classes and postponed evaluation
- **3.8**: Assignment expressions and positional-only args
- **3.9**: Generic types and dict union operators
- **3.10**: Pattern matching and union types

### PostgreSQL Legacy Features
- **10**: Logical replication and declarative partitioning
- **11**: Improved partitioning and parallel query
- **12**: Generated columns and improved performance
- **13**: Incremental sort and parallel vacuum
- **14**: Logical replication improvements

---

## 📥 Installation Methods

### APT (Ubuntu/Debian)
- **Repository Management**: Official and third-party repositories
- **Key Management**: GPG key verification
- **Package Installation**: Standard apt packages

### APK (Alpine)
- **Package Installation**: Lightweight package manager
- **Repository Management**: Official Alpine repositories

### Manual Installation
- **Source Compilation**: From source code
- **Binary Distribution**: Pre-compiled binaries
- **Script Installation**: Automated install scripts

### Universal Methods
- **Docker Images**: Container-based installation
- **Snap Packages**: Universal package format
- **Script Installers**: Language-specific installers

---

## 🔍 Usage Examples

### Installing Specific PHP Version
```bash
# Using phpbrew
phpbrew install 7.4
phpbrew use 7.4

# Using APT (Ubuntu)
sudo apt install php7.4 php7.4-cli php7.4-fpm
```

### Installing Specific Python Version
```bash
# Using pyenv
pyenv install 3.8.18
pyenv global 3.8.18

# Using APT (Ubuntu)
sudo apt install python3.8 python3.8-pip
```

### Installing Specific Node.js Version
```bash
# Using nvm
nvm install 16.20.2
nvm use 16.20.2

# Using APT (Ubuntu)
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install nodejs
```

### Installing Specific PostgreSQL Version
```bash
# Using APT (Ubuntu)
sudo apt install postgresql-13 postgresql-13-contrib

# Using source
curl -fsSL https://www.postgresql.org/ftp/source/v13/postgresql-13.tar.gz | tar -xzf -
```

---

## 📚 Additional Resources

- **Official Documentation**: Refer to individual tool documentation
- **Version Compatibility**: Check compatibility matrices for your use case
- **Migration Guides**: Use when upgrading between major versions
- **Community Support**: Stack Overflow, GitHub Issues, Official Forums

---

## 🔄 Updates and Maintenance

- **Update Frequency**: Monthly
- **Version Support**: Major versions only (e.g., 13.x not 13.11.x)
- **Security Updates**: Critical security patches included
- **Deprecation Policy**: 6-month notice for version removal

---

*Last Updated: 2024-08-21*  
*Version: 1.1.0*  
*Maintainer: Project Container Creator*
