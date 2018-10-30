#!/usr/bin/env bash

USER="$(id -u):$(id -g)"
docker run --rm --user $USER -i -t -v $(pwd):/in charithe/prototool-docker $@
