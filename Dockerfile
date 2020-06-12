FROM chrisdaish/squid

ARG DISK_CACHE_SIZE=5000
ARG MAX_CACHE_OBJECT=1000

#COPY squid.conf /etc/squid/squid.conf

#    printf "acl localnet src 127.0.0.0/8\n" >> /etc/squid/squid.conf && \
RUN printf "maximum_object_size $MAX_CACHE_OBJECT MB\n" >> /etc/squid/squid.conf && \
    printf "cache_dir ufs /var/cache/squid $DISK_CACHE_SIZE 16 256\n" >> /etc/squid/squid.conf && \
    printf "http_port 3129 intercept\n" >> /etc/squid/squid.conf && \
    printf "http_port 3130 transparent\n" >> /etc/squid/squid.conf && \
    printf "http_port 3131 tproxy\n" >> /etc/squid/squid.conf && \
    squid -k parse

COPY certs/cert.sh /etc/squid/certs/cert.sh

RUN rm -rf /var/lib/ssl_db \
    && /usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB \
    && apk add --no-cache ca-certificates \
    && mkdir -p /usr/local/share/ca-certificates \
    && ln -sf /etc/squid/certs/squid-ca-cert.pem /usr/local/share/ca-certificates/squid-ca-cert.crt \
    && update-ca-certificates

VOLUME /var/cache/squid
VOLUME /var/log/squid
VOLUME /var/lib/ssl_db
