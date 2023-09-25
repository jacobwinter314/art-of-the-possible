#!/bin/bash

# Set the script to work in strict mode.
# http://redsymbol.net/articles/unofficial-bash-strict-mode/ without the fail fast.
set -uo pipefail

start_process() {
    echo "Initiating publish of Flask server image..."
}

complete_process() {
    local SCRIPT_RETURN_CODE=$1
    local COMPLETE_REASON=$2

    if [ "$SCRIPT_RETURN_CODE" -ne 0 ]; then
        echo ""
    fi

    if [ -n "$COMPLETE_REASON" ] ; then
        echo "$COMPLETE_REASON"
    fi

    if [ "$SCRIPT_RETURN_CODE" -ne 0 ]; then
        echo "Publish of Flask server image failed."
    else
        echo "Publish of Flask server image succeeded."
    fi

    if [ -f "$TEMP_FILE" ]; then
        rm "$TEMP_FILE"
    fi

    if [ "$DID_PUSHD" -eq 1 ]; then
        popd > /dev/null 2>&1 || exit
    fi

    exit "$SCRIPT_RETURN_CODE"
}

save_current_directory() {
    echo "Saving current directory prior to execution."
    if ! pushd . >"$TEMP_FILE" 2>&1;  then
        cat "$TEMP_FILE"
        complete_process 1 "Script cannot save the current directory before proceeding."
    fi
    DID_PUSHD=1
}

verify_script_prerequisites() {
    VALUE=${ACR_HOST_NAME:-}
    if [ -z "$VALUE" ] ; then
        complete_process 1 "Environment variable 'ACR_HOST_NAME' is not set.  Please execute ./terraform/deploy_resources.sh first."
    fi

    VALUE=${ACR_USERID:-}
    if [ -z "$VALUE" ] ; then
        complete_process 1 "Environment variable 'ACR_USERID' is not set.  Please execute ./terraform/deploy_resources.sh first."
    fi

    VALUE=${ACR_PASSWORD:-}
    if [ -z "$VALUE" ] ; then
        complete_process 1 "Environment variable 'ACR_PASSWORD' is not set.  Please execute ./terraform/deploy_resources.sh first."
    fi
}

# Set up any variables that we will need in the script.
TEMP_FILE=$(mktemp /tmp/run_publish_docker.XXXXXXXXX)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

BASE_IMAGE_NAME="art-of-the-possible"
DOCKER_IMAGE_BASE_VERSION="0.5.0"

# Set this for the script and any subprocesses so we keep the venv in the project.
export PIPENV_VENV_IN_PROJECT=1

# Clean entrance into the script.
start_process
save_current_directory
verify_script_prerequisites

# Change the directory into the script's directory, to make things consistent.
cd "$SCRIPT_DIR" || exit

IMAGE_NAME="${BASE_IMAGE_NAME}:${DOCKER_IMAGE_BASE_VERSION}"

if ! ./run_build_docker.sh ; then
    complete_process 1 "Build of Flask server image failed."
fi

if ! echo "$ACR_PASSWORD" | docker login "$ACR_HOST_NAME" --username "$ACR_USERID" --password-stdin ; then
    complete_process 1 "Login to ACR '$ACR_HOST_NAME' failed."
fi

NEW_IMAGE_VERSION="${DOCKER_IMAGE_BASE_VERSION}.$(date +%s)"
NEW_IMAGE_NAME="${ACR_HOST_NAME}/${BASE_IMAGE_NAME}:${NEW_IMAGE_VERSION}"

if ! docker tag "$IMAGE_NAME" "$NEW_IMAGE_NAME" ; then
    complete_process 1 "Retagging of Flask server image for ACR failed."
fi

if ! docker push "$NEW_IMAGE_NAME" ; then
    complete_process 1 "Push of image '$NEW_IMAGE_NAME' to ACR '$ACR_HOST_NAME' failed."
fi

# Export these variables to allow the deploy_to_cluster.sh script to know what to deploy.
{
    echo "# !!! This is a temporary file.  This should never be committed to a repository !!!"
    echo ""
    echo "export ACR_IMAGE_NAME=\"$BASE_IMAGE_NAME\""
    echo "export ACR_IMAGE_TAG=\"$NEW_IMAGE_VERSION\""
} > ./run_publish_docker.var

echo "File ./run_publish_docker.var written with values that can be sourced."

complete_process 0 "Image '$NEW_IMAGE_NAME' was pushed to ACR '$ACR_HOST_NAME'."
