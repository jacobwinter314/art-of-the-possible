#!/bin/bash

BASE_IMAGE_NAME="art-of-the-possible"
DOCKER_IMAGE_BASE_VERSION="0.5.0"
IMAGE_NAME="${BASE_IMAGE_NAME}:${DOCKER_IMAGE_BASE_VERSION}"


if ./run_build_docker.sh ; then
    echo "good build"
fi

if docker run -it --rm -p 5000:5000 $IMAGE_NAME  ; then
    echo "good run"
fi
