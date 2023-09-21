#!/bin/bash

# Set up any variables that we will need in the script.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

x-www-browser "report/coverage/index.html"
