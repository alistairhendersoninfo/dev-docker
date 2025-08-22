FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Use Google DNS for better connectivity during build
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# Install essential packages for Traefik
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add Traefik GPG key and repository
RUN curl -fsSL https://pkgs.traefik.io/gpg.key | gpg --dearmor -o /usr/share/keyrings/traefik-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/traefik-archive-keyring.gpg] https://pkgs.traefik.io/deb stable main" | tee /etc/apt/sources.list.d/traefik.list

# Install Traefik
RUN apt-get update && apt-get install -y traefik && apt-get clean

# Create Traefik user
RUN useradd -r -s /bin/false traefik

# Create necessary directories
RUN mkdir -p /etc/traefik /var/log/traefik /var/lib/traefik
RUN chown -R traefik:traefik /etc/traefik /var/log/traefik /var/lib/traefik

# Copy configuration files
COPY traefik.yml /etc/traefik/

# Create acme.json file with proper permissions
RUN touch /var/lib/traefik/acme.json
RUN chmod 600 /var/lib/traefik/acme.json
RUN chown traefik:traefik /var/lib/traefik/acme.json

# Expose ports
EXPOSE 80 443 8080

# Switch to traefik user
USER traefik

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ping || exit 1

# Start Traefik
CMD ["traefik", "--configfile=/etc/traefik/traefik.yml"]
