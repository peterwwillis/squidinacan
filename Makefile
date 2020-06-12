include ./.env

docker-build:
	docker build \
        -t $(DOCKER_IMG) \
        .

docker-build-cache-web:
	docker build \
        -t $(DOCKER_IMG) \
        --build-arg http_proxy=http://192.168.88.10:3132 \
        --build-arg https_proxy=http://192.168.88.10:3132 \
        --build-arg HTTP_PROXY=http://192.168.88.10:3132 \
        --build-arg HTTPS_PROXY=http://192.168.88.10:3132 \
        --build-arg no_proxy="localhost,localdomain,127.0.0.1" \
        --build-arg NO_PROXY="localhost,localdomain,127.0.0.1" \
        .

docker-run:
	./squid-in-a-can
