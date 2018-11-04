#!/usr/bin/env bash

USER="$(id -u):$(id -g)"

rm -rf go java
docker run --rm --user $USER -i -t -v $(pwd):/in charithe/prototool-docker all
