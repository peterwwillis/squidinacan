# About
**squid-in-a-can** is a Squid caching web proxy in a Docker container. If you just want to get a Squid caching proxy up *right now*, this will do it.

The default configuration has enough for you to start using it immediately, **but no security is assumed at all! DO NOT RUN THIS ON A PUBLIC NETWORK!**


# Requirements
 - Docker
 - Probably a Linux/Unix-like system
 - Make

# Usage
 - Build the container:
   ```bash
   $ docker build -t peterwwillis/squidinacan:0.1 .
   ```
 - Run the container:
   - Simple method:
     ```bash
     $ docker run -p 3128:3128 peterwwillis/squidinacan:0.1
     ```
   - Fancy wrapper method (backgrounds container; use `-h` option for details):
     ```bash
     $ ./squid-in-a-can -v squidcache
     ```
 - Run a command using the new proxy:
   ```bash
   $ http_proxy=http://localhost:3128 curl -v -I http://www.google.com/
   ```

# More Details

## Data Volumes
By default the container will create a persistent *anonymous* Docker volume for `/var/cache/squid` and `/var/log/squid`. Because it is an anonymous volume, the next time you run the container, it won't find the old volume, so your cache will appear to be gone.

However, there should still be a volume with a very long name sitting on your disk with the old cache. You can recover the cache by finding the volume, creating a new volume, and copying the contents from the old one to the new one. If the new one is 'named' (non an anonymous volume), it should persist between container runs. Use the script [copy-squid-docker-volume](./copy-squid-docker-volume) to automate this.

To preserve your Squid cache between runs, use a 'named' volume for `/var/cache/squid` each time (ex: `docker run --rm -v squidcache:/var/cache/squid -p 3128:3128 peterwwillis/squidinacan`)

## Open Ports
The following ports are configured for Squid to listen on:
 - 3128: a regular Squid proxy listener (most commonly used)
 - 3129: an intercept listener
 - 3130: a transparent listener
 - 3131: a tproxy listener

## Squid Configuration
You can change the configuration of the running Squid in two ways:
 1. Create a new `squid.conf` file and volume-mount it into the container at `/etc/squid/squid.conf`. (This is done automatically if the [squid-in-a-can](./squid-in-a-can) script finds a `squid.conf` file in the current directory)
 2. Pass new build arguments at `docker build` time.
    - `--build-arg DISK_CACHE_SIZE=5000`
      - This specifies the size of the Squid disk cache in megabytes.
    - `--build-arg MAX_CACHE_OBJECT=1000`
      - This specifies the max number of objects Squid should cache.

# License
All contents of this repository is released to the public domain.

This repository's contents and subsequent Docker containers come with no warranty whatsoever. You break it, you buy it.

# FAQ
 - **Q: Why am I getting the error 'docker: Error response from daemon: source is not directory.' ?**
   - **A:** You specified the `-f` option to [squid-in-a-can](./squid-in-a-can) without a fully-qualified path.
 - **Q: Why am I getting the error 'The container name "/squidcache" is already in use' ?**
   - **A:** You need to remove your old containers with the same name. Run `docker rm squidcache` or `docker container prune`.
 - **Q: Why aren't some files getting cached?**
   - **A:** Usually this is because an application either doesn't take an `http_proxy` option, or it is downloading through HTTPS. The workaround is to install a custom CA certificate into your OS or application (some applications don't use the OS's certificate store, like PIP and AWS CLI), and then install it into Squid, and configure Squid to basically terminate and re-initiate connections as a Man-in-the-Middle.
   
     An alternative may exist for your application. Some applications take an option to specify a custom source for downloads, like a custom download repository. Provide your app an HTTP download source (assuming it also accepts an `http_proxy` option) and your downloads will probably cache correctly.
 - **Q: Can I intercept all traffic without needing to specify an `http_proxy=` option to applications?**
   - **A:** Yes, but apparently it's much more complicated now than it used to be, and I still haven't gotten it to work...

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
