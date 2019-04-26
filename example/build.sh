#!/usr/bin/env bash

USER="$(id -u):$(id -g)"
docker run -it \
    --rm \
    --user $USER \
    --mount type=bind,source="$(pwd)",target=/work \
    --tmpfs /tmp:exec \
    charithe/prototool-docker prototool $@
