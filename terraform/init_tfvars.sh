#!/bin/bash

# !!! This should NEVER be committed to a repository with any values filled in !!!

# This file should only be sourced.

if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi

# These should be filled in before the scripts are executed.
export TF_VAR_arm_client_id=""
export TF_VAR_arm_client_secret=""
export TF_VAR_arm_subscription_id=""
export TF_VAR_arm_tenant_id=""

# These are here to clear exported variables between runs of the scripts.
export ACR_HOST_NAME=
export ACR_USERID=
export ACR_PASSWORD=
export ACR_IMAGE_NAME=
export ACR_IMAGE_TAG=
