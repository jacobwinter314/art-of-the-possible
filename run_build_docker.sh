#!/bin/bash

BASE_IMAGE_NAME="art-of-the-possible"
DOCKER_IMAGE_BASE_VERSION="0.5.0"
IMAGE_NAME="${BASE_IMAGE_NAME}:${DOCKER_IMAGE_BASE_VERSION}"

if docker image build -f Dockerfile -t $IMAGE_NAME . ; then
    echo "good image build"
else
    echo "bad image build"
    exit 1
fi
