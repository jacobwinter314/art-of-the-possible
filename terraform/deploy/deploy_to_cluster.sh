#!/bin/bash

# Set the script to work in strict mode.
# http://redsymbol.net/articles/unofficial-bash-strict-mode/ without the fail fast.
set -uo pipefail

start_process() {
    echo "Deploying Flask image to Cluster..."
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
        echo "Deploy of Flask image to cluster failed."
    else
        echo "Deploy of Flask image to cluster succeeded."
    fi

    if [ -f "$TEMP_FILE" ]; then
        rm "$TEMP_FILE"
    fi

    if [ -f "$LOCAL_TERRAFORM_VARS_FILE" ]; then
        rm "$LOCAL_TERRAFORM_VARS_FILE"
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
        complete_process 1 "Environment variable 'ACR_HOST_NAME' is not set.  Please execute ./run_publish_docker.sh and source the *.var file first."
    fi

    VALUE=${ACR_IMAGE_NAME:-}
    if [ -z "$VALUE" ] ; then
        complete_process 1 "Environment variable 'ACR_IMAGE_NAME' is not set.  Please execute ./run_publish_docker.sh and source the *.var file first."
    fi

    VALUE=${ACR_IMAGE_TAG:-}
    if [ -z "$VALUE" ] ; then
        complete_process 1 "Environment variable 'ACR_IMAGE_TAG' is not set.  Please execute ./run_publish_docker.sh and source the *.var file first."
    fi
}

create_terraform_tfvars_file() {
    {
        echo "# !!! This is a temporary file.  This should never be committed to a repository !!!"
        echo ""
        echo "acr_host_name             = \"$ACR_HOST_NAME\""
        echo "acr_image_name            = \"$ACR_IMAGE_NAME\""
        echo "acr_image_tag             = \"$ACR_IMAGE_TAG\""
        echo "aks_cluster_name          = \"aks-artpossible-dev-westus\""
        echo "aks_resource_group_name   = \"rg-artpossible-dev-westus\""
    } > $LOCAL_TERRAFORM_VARS_FILE
}

# Set up any variables that we will need in the script.
TEMP_FILE=$(mktemp /tmp/deploy_to_cluster.XXXXXXXXX)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
LOCAL_TERRAFORM_VARS_FILE="terraform.tfvars"

# Set this for the script and any subprocesses so we keep the venv in the project.
export PIPENV_VENV_IN_PROJECT=1

# Clean entrance into the script.
start_process
save_current_directory
verify_script_prerequisites

# Change the directory into the script's directory, to make things consistent.
cd "$SCRIPT_DIR" || exit

create_terraform_tfvars_file

if ! ../../terraform-image/terraform.sh init ; then
    complete_process 1 "Terraform init failed.  Please check error message and resolve any issues before trying again."
fi

if ../../terraform-image/terraform.sh apply ; then
    CLUSTER_IP=$(../../terraform-image/terraform.sh output -raw webapp_cluster_ip)
    echo ""
    echo ""
    echo "Flask image was deployed to cluster at IP address $CLUSTER_IP."
    echo ""
    echo ""
else
    complete_process 1 "Application of Flask image deployment to cluster failed."
fi

complete_process 0 ""
