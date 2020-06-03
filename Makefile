include ./.env

docker-build:
	docker build \
        -t $(DOCKER_IMG) \
        .

docker-run:
	./squid-in-a-can
