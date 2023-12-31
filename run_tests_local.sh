#!/bin/bash

# Set the script to work in strict mode.
# http://redsymbol.net/articles/unofficial-bash-strict-mode/ without the fail fast.
set -uo pipefail

start_process() {
    echo "Initiating local run of Flask server tests..."
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
        echo "Local run of Flask server tests failed."
    else
        echo "Local run of Flask server tests succeeded."
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
    # Make sure any prerequisites are installed.

    if ! which docker > /dev/null ; then
        echo "Check failed: Docker is not installed on your system."
        echo " Please consult https://docs.docker.com/engine/install/ for installation information."
        echo " When the installation has completed, run this script again."
        complete_process 1
    fi

    if ! which pip > /dev/null ; then
        echo "Check failed: Pip is not installed on your system."
        echo " Please run the command 'sudo apt install python3-pip' and run this script again."
        complete_process 1
    fi

    if ! which pipenv > /dev/null; then
        echo "Check failed: Pipenv is not installed on your system."
        echo " Please run the command 'sudo apt install pipenv' and run this script again."
        complete_process 1
    fi
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

# Set up any variables that we will need in the script.
TEMP_FILE=$(mktemp /tmp/run_tests_local.XXXXXXXXX)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Set this for the script and any subprocesses so we keep the venv in the project.
export PIPENV_VENV_IN_PROJECT=1

# Clean entrance into the script.
start_process
save_current_directory
verify_script_prerequisites

# Change the directory into the script's directory, to make things consistent.
cd "$SCRIPT_DIR" || exit

sync_pipenv

if ! pipenv run pytest ; then
    complete_process 1 "Execution of tests failed."
fi

complete_process 0 ""
