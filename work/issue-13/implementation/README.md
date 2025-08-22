# n8n Automation Server Implementation

## Technical Implementation Details

### Docker Configuration

#### Dockerfile Features
- Based on official `n8nio/n8n:latest` image
- Development environment configuration
- Additional tools: curl, wget, git, vim, docker-cli
- Community nodes: docker, ssh, webhook-extended
- Proper user permissions and directory structure
- Health check endpoint

#### Docker Compose Stack
- **n8n Service**: Main automation server
- **PostgreSQL Service**: Database backend
- **Networks**: n8n-network (internal), traefik-network (external)
- **Volumes**: Persistent data, Docker socket, SSH keys
- **Labels**: Traefik routing configuration

### Database Schema

#### Custom Tables
```sql
-- Container deployment tracking
container_deployments (
    id UUID PRIMARY KEY,
    container_name VARCHAR(255) UNIQUE,
    image_name VARCHAR(255),
    dns_name VARCHAR(255),
    ssh_port INTEGER,
    status VARCHAR(50),
    metadata JSONB
)

-- DNS entries management
dns_entries (
    id UUID PRIMARY KEY,
    hostname VARCHAR(255) UNIQUE,
    ip_address INET,
    container_id VARCHAR(255),
    entry_type VARCHAR(50),
    active BOOLEAN
)

-- Workflow execution logs
workflow_logs (
    id UUID PRIMARY KEY,
    workflow_name VARCHAR(255),
    execution_id VARCHAR(255),
    status VARCHAR(50),
    input_data JSONB,
    output_data JSONB,
    execution_time INTEGER
)
```

### Workflow Templates

#### Container Deployment Workflow
- **Trigger**: Webhook POST to `/webhook/deploy-container`
- **Process**: Validate parameters, deploy container, update DNS
- **Response**: JSON with deployment status and details

#### Workflow Nodes
1. **Webhook Trigger**: Receives deployment requests
2. **Function Node**: Processes and validates input
3. **Execute Command**: Runs docker commands
4. **DNS Update**: Updates host DNS entries
5. **Response Node**: Returns deployment status

### Environment Variables

#### n8n Configuration
- `N8N_HOST=0.0.0.0` - Listen on all interfaces
- `N8N_PORT=5678` - Web interface port
- `WEBHOOK_URL` - External webhook URL
- `N8N_BASIC_AUTH_ACTIVE=false` - Disable auth for development

#### Database Configuration
- `DB_TYPE=postgresdb` - Use PostgreSQL
- `DB_POSTGRESDB_HOST=postgres` - Database host
- `DB_POSTGRESDB_DATABASE=n8n` - Database name
- `DB_POSTGRESDB_USER=n8n` - Database user

### Volume Mounts

#### Persistent Data
- `n8n_data:/home/node/.n8n` - n8n application data
- `postgres_data:/var/lib/postgresql/data` - Database data

#### Runtime Access
- `/var/run/docker.sock` - Docker API access
- `~/.ssh:/home/node/.ssh:ro` - SSH keys (read-only)
- `./workflows:/home/node/.n8n/workflows` - Custom workflows

### Network Configuration

#### Internal Network (n8n-network)
- n8n ↔ PostgreSQL communication
- Isolated from external access
- Bridge driver

#### External Network (traefik-network)
- Traefik ↔ n8n communication
- External web access
- Must be created externally

### Security Implementation

#### Container Security
- Non-root user execution
- Read-only SSH key mount
- Network isolation
- Resource limits (can be added)

#### API Security
- Webhook endpoint validation
- Input sanitization in workflows
- Database connection encryption
- Environment variable secrets

### Integration Points

#### Docker Integration
- Socket mount for container management
- Command execution for deployment
- Container inspection and monitoring

#### DNS Integration
- Host DNS file updates
- Container DNS server communication
- Dynamic DNS entry management

#### Traefik Integration
- Automatic service discovery
- SSL termination
- Load balancing (for HA)

## Build Process

### Image Building
```bash
# Build via script
./Build-Docker-Images.sh 6

# Direct build
cd docker/n8n
docker build -t dev-n8n:latest .
```

### Service Deployment
```bash
# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f n8n
```

### Health Checks
```bash
# n8n health
curl http://localhost:5678/healthz

# Database health
docker-compose exec postgres pg_isready -U n8n
```

## Development Workflow

### Testing Workflows
1. Access web interface: `http://n8n-local.alistairhenderson.info:5678`
2. Import workflow from `workflows/` directory
3. Configure webhook endpoints
4. Test with curl or Postman

### Debugging
- Container logs: `docker-compose logs n8n`
- Database access: `docker-compose exec postgres psql -U n8n`
- Workflow execution logs in database
- n8n built-in execution history

### Custom Node Development
- Mount custom nodes directory
- Install via npm in container
- Restart n8n service
- Nodes available in workflow editor

## Performance Considerations

### Resource Requirements
- **n8n**: 512MB RAM minimum, 1GB recommended
- **PostgreSQL**: 256MB RAM minimum, 512MB recommended
- **Storage**: 1GB minimum for workflows and logs

### Scaling Considerations
- Single instance suitable for development
- Production requires load balancing
- Database connection pooling
- Workflow execution queuing

## Monitoring and Logging

### Health Monitoring
- n8n health endpoint
- PostgreSQL health checks
- Docker container status
- Workflow execution metrics

### Log Management
- Container logs via Docker
- n8n execution logs in database
- PostgreSQL query logs
- Custom workflow logging

## Troubleshooting

### Common Issues
1. **Port conflicts**: Check 5678 availability
2. **Database connection**: Verify PostgreSQL startup
3. **Docker socket**: Check permissions
4. **DNS resolution**: Verify hostname configuration
5. **Traefik routing**: Check labels and network

### Debug Commands
```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs n8n postgres

# Database connection test
docker-compose exec postgres psql -U n8n -c "SELECT version();"

# n8n API test
curl http://localhost:5678/api/v1/workflows
```