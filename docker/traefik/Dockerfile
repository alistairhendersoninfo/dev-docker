# Use official Traefik image as base instead of building from Ubuntu
FROM traefik:v3.0

# Copy our custom configuration
COPY traefik.yml /etc/traefik/

# Create necessary directories with proper permissions
USER root
RUN mkdir -p /var/log/traefik /var/lib/traefik && \
    touch /var/lib/traefik/acme.json && \
    chmod 600 /var/lib/traefik/acme.json && \
    chown -R traefik:traefik /var/log/traefik /var/lib/traefik

# Switch back to traefik user
USER traefik

# Expose ports
EXPOSE 80 443 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ping || exit 1

# Start Traefik with our config
CMD ["traefik", "--configfile=/etc/traefik/traefik.yml"]
