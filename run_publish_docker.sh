#!/bin/bash

BASE_IMAGE_NAME="art-of-the-possible"
DOCKER_IMAGE_BASE_VERSION="0.5.0"

IMAGE_NAME="${BASE_IMAGE_NAME}:${DOCKER_IMAGE_BASE_VERSION}"

NEW_IMAGE_VERSION="0.5.0.$(date +%s)"
NEW_IMAGE_NAME="${ACR_NAME}/${BASE_IMAGE_NAME}:${NEW_IMAGE_VERSION}"

if ./run_build_docker.sh ; then
    echo "good build"
fi

if echo "$ACR_PASSWORD" | docker login "$ACR_NAME" --username "$ACR_USERID" --password-stdin ; then
    echo "good login"
fi

if docker tag "$IMAGE_NAME" "$NEW_IMAGE_NAME" ; then
    echo "good tag"
fi

if docker push "$NEW_IMAGE_NAME" ; then
    echo "good push"
fi
