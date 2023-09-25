#!/bin/bash

# Set the script to work in strict mode.
# http://redsymbol.net/articles/unofficial-bash-strict-mode/ without the fail fast.
set -uo pipefail

start_process() {
    echo "Creating online storage for Terraform backend..."
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
        echo "Creation of online storage for Terraform backend failed."
    else
        echo "Creation of online storage for Terraform backend succeeded."
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

    # This uses the Az Cli primitives to tell if someone is still connected.
    if az account show -o jsonc > /dev/null 2>&1 ; then
        echo "Command line is currently logged in."
    else
        echo "Command line was not logged in. Requesting user to login."
        if ! az login ; then
            complete_process 1 "User cannot proceed without being logged in to Azure through the Az Cli."
        fi
    fi
}

# Set up any variables that we will need in the script.
TEMP_FILE=$(mktemp /tmp/init_backend_storage.XXXXXXXXX)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Set this for the script and any subprocesses so we keep the venv in the project.
export PIPENV_VENV_IN_PROJECT=1

# Clean entrance into the script.
start_process
save_current_directory
verify_script_prerequisites

# Change the directory into the script's directory, to make things consistent.
cd "$SCRIPT_DIR" || exit

if ! ../../terraform-image/terraform.sh init ; then
    complete_process 1 "Terraform for creation of Terraform backend was not initialized."
fi

if ! ../../terraform-image/terraform.sh apply ; then
    complete_process 1 "Terraform for creation of Terraform backend was not applied."
fi

complete_process 0 ""
