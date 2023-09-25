#!/bin/bash

# Set the script to work in strict mode.
# http://redsymbol.net/articles/unofficial-bash-strict-mode/ without the fail fast.
set -uo pipefail

start_process() {
    echo "Initiating local run of project scan..."
}

save_current_directory() {
    echo "Saving current directory prior to execution."
    if ! pushd . >"$TEMP_FILE" 2>&1;  then
        cat "$TEMP_FILE"
        complete_process 1 "Script cannot save the current directory before proceeding."
    fi
    DID_PUSHD=1
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
        echo "Local run of project scan failed."
    else
        echo "Local run of project scan succeeded."
    fi

    if [ -f "$TEMP_FILE" ]; then
        rm "$TEMP_FILE"
    fi

    if [ "$DID_PUSHD" -eq 1 ]; then
        popd > /dev/null 2>&1 || exit
    fi

    exit "$SCRIPT_RETURN_CODE"
}

verify_script_prerequisites() {
    if ! which docker > /dev/null ; then
        echo "Check failed: Docker is not installed on your system."
        echo " Please consult https://docs.docker.com/engine/install/ for installation information."
        echo " When the installation has completed, run this script again."
        complete_process 1
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
}

validate_terraform() {
    local DIRECTORY_TO_SCAN=$1

    if ! pushd . >"$TEMP_FILE" 2>&1; then
        cat "$TEMP_FILE"
        complete_process 1 "Function 'validate_terraform' cannot save the current directory before proceeding."
    fi

    cd "$DIRECTORY_TO_SCAN" || exit

    echo "Validating Terraform in directory '$DIRECTORY_TO_SCAN'."
    if ! "$SCRIPT_DIR"/terraform-image/terraform.sh validate -no-color ; then
        popd > /dev/null 2>&1 || exit
        complete_process 1 "One or more Terraform files were not valid.  Please fix any reported issues and try again."
    fi

    popd > /dev/null 2>&1 || exit
}

sync_pipenv() {
    # If the Pipfile.lock is not found, use pipenv to create it and install any required packages.
    if [ ! -f "./Pipfile.lock" ]; then
        pipenv lock
    fi

    # If the Pipfile was changed without using "pipenv install" or "pipenv uninstall", take steps to fix it.
    if [ "./Pipfile" -nt "./Pipfile.lock" ]; then
        pipenv --rm
        pipenv lock
    fi

    pipenv sync -d
}

format_terraform() {
    if ! ./terraform-image/terraform.sh fmt -recursive ./terraform ; then
        complete_process 1 "One or more Terraform files were formatted.  Please try again."
    fi
}

# Set up any variables that we will need in the script.
TEMP_FILE=$(mktemp /tmp/run_scan_local.XXXXXXXXX)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Set this for the script and any subprocesses so we keep the venv in the project.
export PIPENV_VENV_IN_PROJECT=1
export PRE_COMMIT_HOME=${SCRIPT_DIR}/.pre-commit

# Clean entrance into the script.
start_process
save_current_directory
verify_script_prerequisites

# Change the directory into the script's directory, to make things consistent.
cd "$SCRIPT_DIR" || exit

sync_pipenv

format_terraform
validate_terraform ./terraform
validate_terraform ./terraform/deploy
validate_terraform ./terraform/create-state

echo "Executing pre-commit tool to scan for issues.  (this may take up to 5 minutes)"
if ! pipenv run pre-commit run --all ; then
    complete_process 1 "Scan of project detected issues.  Please resolve these issues before trying again."
fi

complete_process 0 ""
