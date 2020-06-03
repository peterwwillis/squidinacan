FROM chrisdaish/squid

ENV DISK_CACHE_SIZE=5000
ENV MAX_CACHE_OBJECT=1000

RUN printf "maximum_object_size $MAX_CACHE_OBJECT MB\n" >> /etc/squid/squid.conf && \
    printf "cache_dir ufs /var/cache/squid $DISK_CACHE_SIZE 16 256\n" >> /etc/squid/squid.conf && \
    printf "http_port 3129 intercept\n" >> /etc/squid/squid.conf && \
    squid -k parse

VOLUME /var/cache/squid
VOLUME /var/log/squid
#    -v /etc/localtime:/etc/localtime:ro
