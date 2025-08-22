FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dnsmasq
RUN apt-get update && apt-get install -y \
    dnsmasq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY dnsmasq.conf /etc/dnsmasq.conf

# Create dnsmasq user
RUN useradd -r -s /bin/false dnsmasq

# Expose DNS port
EXPOSE 53/udp 53/tcp

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD dig @127.0.0.1 google.com || exit 1

# Start dnsmasq
CMD ["dnsmasq", "--no-daemon", "--log-queries", "--log-facility=-"]
