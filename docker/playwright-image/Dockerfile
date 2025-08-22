FROM mcr.microsoft.com/playwright:v1.55.0-jammy

# Install additional development tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    jq \
    unzip \
    && apt-get clean

# Verify Node.js version (should already be 18+)
RUN node --version && npm --version

# Note: Playwright browsers are already installed in the official image

# Install additional tools
RUN npm install -g claude-cli

# Expose port for development server (if needed)
EXPOSE 3000 8080

# Set working directory
WORKDIR /workspace

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node --version || exit 1
