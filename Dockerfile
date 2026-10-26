FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends bind9 bind9-utils ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/cache/bind /var/lib/bind /run/named && \
    chown -R bind:bind /var/cache/bind /var/lib/bind /run/named

COPY named.conf /etc/bind/named.conf

EXPOSE 53/tcp 53/udp

CMD ["/usr/sbin/named", "-g", "-u", "bind"]
