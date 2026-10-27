FROM docker.io/library/ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# Remove the unused Go binary that Trivy flagged.
RUN rm -f /usr/bin/pebble

# Install only the packages needed for BIND9.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bind9 \
        bind9-utils \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Prepare directories for the unprivileged BIND process.
RUN mkdir -p /var/cache/bind /var/lib/bind /run/named && \
    chown -R bind:bind /var/cache/bind /var/lib/bind /run/named

# Copy DNS configuration files.
COPY named.conf /etc/bind/named.conf
COPY named.conf.local /etc/bind/named.conf.local

# Check BIND configuration during image build.
RUN named-checkconf /etc/bind/named.conf

EXPOSE 53/tcp 53/udp

USER bind

CMD ["/usr/sbin/named", "-g", "-u", "bind"]
