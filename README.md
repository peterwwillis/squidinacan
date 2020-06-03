# About
**squid-in-a-can** is a Squid caching web proxy in a Docker container. If you just want to get a Squid caching proxy up *right now*, this will do it.

The default configuration has enough for you to start using it immediately, **but no security is assumed at all! DO NOT RUN THIS ON A PUBLIC NETWORK!**

By default the container will create persistent Docker volumes for '/var/cache/squid' and '/var/log/squid'. You can map in your own volumes on top of them at run time. See below for configuration details.

The following ports are configured for Squid to listen on:
 - 3128: a regular Squid proxy listener (most commonly used)
 - 3129: an intercept listener
 - 3130: a transparent listener
 - 3131: a tproxy listener

# Requirements
 - Docker
 - Probably a Linux/Unix-like system
 - Make

# Usage
 - Build and run the container:
   ```bash
   $ docker build -t peterwwillis/squidinacan:0.1 .
   $ docker run -p 3128:3128 peterwwillis/squidinacan:0.1
   ```
 - Run a command using the new proxy:
   ```bash
   $ http_proxy=http://localhost:3128 curl -v -I http://www.google.com/
   ```

# Configuration
You can change the configuration of the running Squid in two ways:
 1. Create a new `squid.conf` file and volume-mount it into the container at `/etc/squid/squid.conf`
 2. Pass new build arguments at `docker build` time.
    - `--build-arg DISK_CACHE_SIZE=5000`
      - This specifies the size of the Squid disk cache in megabytes.
    - `--build-arg MAX_CACHE_OBJECT=1000`
      - This specifies the max number of objects Squid should cache.

# License
All contents of this repository is released to the public domain.

This repository's contents and subsequent Docker containers come with no warranty whatsoever. You break it, you buy it.

# Tips
 - You may want to set the following environment variables for any commands you want to proxy:
   ```bash
   $ export https_proxy=http://localhost:3128
   $ export http_proxy=http://localhost:3128
   $ export HTTP_PROXY=http://localhost:3128
   $ export HTTPS_PROXY=http://localhost:3128
   $ export no_proxy="localhost,localdomain,127.0.0.1"
   $ export NO_PROXY="localhost,localdomain,127.0.0.1"
   ```
   You can pass those variables to `docker build` as `--build-arg` arguments to cache download steps in a container build process (such as when **apt**, **yum**, or **apk** download files at build time)
   
   You can pass those variables to `docker run` as `--env` arguments to set them when running a container.

 - If you use this for a Docker container (build or runtime), you probably want the proxy IP or hostname to be an address that your container can route to (so: not 'localhost')

 - To view the cache and log volumes auto-created by the container:
   ```bash
   $ docker inspect -f '{{ json .Mounts }}' $(docker ps -q) | jq
   ```

 - To display all the cache files sorted by size:
   ```bash
   $ docker inspect -f '{{ json .Mounts }}' $(docker ps -q) \
        | jq -r '.[].Source' \
        | grep -v null \
        | sudo /bin/sh -c \
            ' xargs -n1 -I{} find {} -type f -print0 | xargs -0 du -csh | sort -h '
   ```

# Credits

Much thanks to Jérôme Petazzoni (github.com/jpetazzo) for his earlier Squid In A Can implementation!
