# n8n Automation Server Container
# Based on official n8n Docker image with development environment setup

FROM n8nio/n8n:latest

# Set environment variables for development
ENV NODE_ENV=development
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV WEBHOOK_URL=http://n8n-local.alistairhenderson.info:5678
ENV N8N_EDITOR_BASE_URL=http://n8n-local.alistairhenderson.info:5678

# Create directories for persistent data
USER root
RUN mkdir -p /home/node/.n8n/workflows \
    && mkdir -p /home/node/.n8n/credentials \
    && mkdir -p /home/node/.n8n/nodes \
    && mkdir -p /home/node/.n8n/logs \
    && chown -R node:node /home/node/.n8n

# Install additional development tools
RUN apk add --no-cache \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    jq \
    bash \
    openssh-client \
    docker-cli

# Install additional n8n community nodes for container management
USER node
# Note: Install only verified community nodes that exist in npm registry
# RUN npm install -g n8n-nodes-docker (verify availability first)

# Create custom workflows directory
WORKDIR /home/node/.n8n

# Copy custom workflow templates (if they exist)
COPY --chown=node:node workflows/ ./workflows/

# Expose ports
EXPOSE 5678

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

# Set working directory
WORKDIR /home/node

# Start n8n
CMD ["n8n", "start"]
