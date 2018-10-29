DOCKER_IMAGE:=charithe/prototool

build:
	@docker build --rm -t $(DOCKER_IMAGE) .

