DOCKER_IMAGE:=charithe/prototool-docker

build:
	@docker build --rm -t $(DOCKER_IMAGE) .

