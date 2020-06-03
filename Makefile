DOCKER_IMG          :=  squidinacan:0.1

docker-build:
	docker build \
        -t $(DOCKER_IMG) \
        .

docker-run:
	DOCKER_IMG=$(DOCKER_IMG) ./squid-in-a-can
