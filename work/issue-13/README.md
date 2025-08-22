# Issue #13: Create n8n Automation Server Container

## Overview

This issue implements an n8n automation server container for workflow automation in the dev-docker environment. The n8n server will handle container deployment automation, DNS management, and integration with the existing infrastructure.

## Implementation Status

### ✅ Completed
- [x] Created n8n Dockerfile with proper dependencies
- [x] Created docker-compose configuration with PostgreSQL backend
- [x] Set up persistent volumes for workflows and data
- [x] Created basic container deployment workflow template
- [x] Added n8n to Build-Docker-Images.sh menu (option 6)
- [x] Created database initialization scripts
- [x] Configured Traefik integration for web interface

### 🔄 In Progress
- [ ] Configure DNS entry for n8n web interface access
- [ ] Test n8n workflow execution and API endpoints
- [ ] Create additional workflow templates

### 📋 Pending
- [ ] Set up webhook endpoints for container deployment triggers
- [ ] Create comprehensive documentation and setup guides

## Architecture

### Components
1. **n8n Server**: Main automation engine
2. **PostgreSQL Database**: Workflow and execution data storage
3. **Traefik Integration**: Reverse proxy and SSL termination
4. **Docker Socket Access**: Container management capabilities
5. **SSH Key Access**: Remote server management

### Network Configuration
- **Web Interface**: `http://n8n-local.alistairhenderson.info:5678`
- **Webhook Endpoints**: `http://n8n-local.alistairhenderson.info:5678/webhook/*`
- **Database**: Internal PostgreSQL on n8n-network
- **Traefik**: Connected to traefik-network

## Files Created

### Docker Configuration
- `docker/n8n/Dockerfile` - n8n container definition
- `docker/n8n/docker-compose.yml` - Complete service stack
- `docker/n8n/init-db/01-init-n8n.sql` - Database schema

### Workflows
- `docker/n8n/workflows/container-deployment-workflow.json` - Basic deployment automation

### Build Integration
- Updated `Build-Docker-Images.sh` with n8n option (6)

## Phase 2: High Availability Planning

### Planned HA Features
- **n8n Clustering**: Multiple n8n instances with load balancing
- **Database HA**: PostgreSQL replication and failover
- **Monitoring**: Comprehensive health checks and alerting
- **Backup & Recovery**: Automated backup and disaster recovery
- **Chaos Testing**: Tools for testing HA resilience

### HA Architecture Components
- Load balancer (HAProxy or Nginx)
- Multiple n8n worker nodes
- PostgreSQL primary/replica setup
- Shared storage for workflows
- Monitoring stack (Prometheus, Grafana)
- Backup automation (pg_dump, volume snapshots)

## Usage

### Building the Image
```bash
./Build-Docker-Images.sh 6  # Build n8n automation server
```

### Starting the Service
```bash
cd docker/n8n
docker-compose up -d
```

### Accessing the Interface
- Web UI: `http://n8n-local.alistairhenderson.info:5678`
- API: `http://n8n-local.alistairhenderson.info:5678/api/v1/`

## Integration Points

### Container Management
- Docker API access via mounted socket
- Container deployment workflows
- DNS entry management
- Traefik configuration updates

### Infrastructure Integration
- Host DNS server updates
- Container DNS server management
- SSH access to remote servers
- PostgreSQL database connectivity

## Security Considerations

- Docker socket access (requires careful permission management)
- SSH key access (read-only mount)
- Database credentials (environment variables)
- Webhook endpoint security
- Network isolation between services

## Next Steps

1. Complete DNS configuration
2. Test basic workflows
3. Create additional workflow templates
4. Document API endpoints
5. Plan Phase 2 HA implementation