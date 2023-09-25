#!/bin/bash

# Set the script to work in strict mode.
# http://redsymbol.net/articles/unofficial-bash-strict-mode/ without the fail fast.
set -uo pipefail

start_process() {
    echo "Initiating deployment of resources..."
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
        echo "Deployment of resources failed."
    else
        echo "Deployment of resources succeeded."
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
    if ! which docker > /dev/null ; then
        echo "Check failed: Docker is not installed on your system."
        echo " Please consult https://docs.docker.com/engine/install/ for installation information."
        echo " When the installation has completed, run this script again."
        complete_process 1 ""
    fi

    if ! which pip > /dev/null ; then
        echo "Check failed: Pip is not installed on your system."
        echo " Please run the command 'sudo apt install python3-pip' and run this script again."
        complete_process 1 ""
    fi

    if ! which pipenv > /dev/null ; then
        echo "Check failed: Pipenv is not installed on your system."
        echo " Please run the command 'sudo apt install pipenv' and run this script again."
        complete_process 1 ""
    fi

    if ! "$SCRIPT_DIR"/../terraform-image/terraform.sh version ; then
        complete_process 1 "Terraform variables have not be initialized in ./terraform/init_tfvars.sh. Please check README.md for instructions."
    fi
}

# Set up any variables that we will need in the script.
TEMP_FILE=$(mktemp /tmp/deploy_resources.XXXXXXXXX)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Set this for the script and any subprocesses so we keep the venv in the project.
export PIPENV_VENV_IN_PROJECT=1

# Clean entrance into the script.
start_process
save_current_directory
verify_script_prerequisites

# Change the directory into the script's directory, to make things consistent.
cd "$SCRIPT_DIR" || exit

if ! ../terraform-image/terraform.sh init ; then
    complete_process 1 "Terraform for deployment of resources was not initialized."
fi

if ! ../terraform-image/terraform.sh apply ; then
    complete_process 1 "Terraform for deployment of resources was not applied."
fi

ACR_HOST_NAME=$("$SCRIPT_DIR"/../terraform-image/terraform.sh output -raw acr_server_url)
ACR_CLIENT_ID=$("$SCRIPT_DIR"/../terraform-image/terraform.sh output -raw acr_client_id)
ACR_CLIENT_SECRET=$("$SCRIPT_DIR"/../terraform-image/terraform.sh output -raw acr_client_secret)

# Export these variables to allow the run_publish_docker.sh script to know what to publish.
{
    echo "# !!! This is a temporary file.  This should never be committed to a repository !!!"
    echo ""
    echo "export ACR_HOST_NAME=\"$ACR_HOST_NAME\""
    echo "export ACR_USERID=\"$ACR_CLIENT_ID\""
    echo "export ACR_PASSWORD=\"$ACR_CLIENT_SECRET\""
} > ../depoloy_resources.var

echo "File ./depoloy_resources.var written with values that can be sourced."

complete_process 0 ""
