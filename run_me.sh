#!/bin/bash

# Corresponds to `lint` job in main.yml
if ! ./run_scan_local.sh ; then
    echo "--lint"
    exit 1
fi

# Fetch the initial TF Variables and source them for later use.
# shellcheck source=/dev/null
source ./terraform/init_tfvars.sh

# Create the Azure storage to hold the state file.
if ! ./terraform/create-state/init_backend_storage.sh ; then
    echo "--create-state"
    exit 1
fi

# Corresponds to `terraform` job in main.yml
if ! ./terraform/deploy_resources.sh ; then
    echo "--create-state"
    exit 1
fi

# shellcheck source=/dev/null
source ./depoloy_resources.var
rm ./depoloy_resources.var

# Corresponds to `build-image` job in main.yml
if ! ./run_publish_docker.sh ; then
    echo "--build-image"
    exit 1
fi

# shellcheck source=/dev/null
source ./run_publish_docker.var
rm ./run_publish_docker.var

# Corresponds to `cluster-deploy` job in main.yml
#
# Note:
if ! ./terraform/deploy/deploy_to_cluster.sh ; then
    echo "--cluster-deploy"
    exit 1
fi
