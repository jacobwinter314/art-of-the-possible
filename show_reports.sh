#!/bin/bash

save_current_directory() {
    echo "Saving current directory prior to execution."
    if ! pushd . >"$TEMP_FILE" 2>&1;  then
        cat "$TEMP_FILE"
        complete_process 1 "Script cannot save the current directory before proceeding."
    fi
    DID_PUSHD=1
}

restore_current_directory() {

    if [ -f "$TEMP_FILE" ]; then
        rm "$TEMP_FILE"
    fi

    if [ "$DID_PUSHD" -eq 1 ]; then
        popd > /dev/null 2>&1 || exit
    fi
}

# Set up any variables that we will need in the script.
TEMP_FILE=$(mktemp /tmp/show_reports.XXXXXXXXX)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Clean entrance into the script.
save_current_directory

# Change the directory into the script's directory, to make things consistent.
cd "$SCRIPT_DIR" || exit

# This should work on most versions of linux, including WSL2.
x-www-browser "report/coverage/index.html"

# cleanup
restore_current_directory
