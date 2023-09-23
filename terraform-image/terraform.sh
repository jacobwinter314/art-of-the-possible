#!/usr/bin/env bash

# Cribbed from
# https://github.com/zenika-open-source/terraform-azure-cli/blob/master/dev.sh
# with some changes to make more transparent

set -eo pipefail

save_current_directory() {
    # echo "Saving current directory prior to execution."
    if ! pushd . >"$TEMP_FILE" 2>&1;  then
        cat "$TEMP_FILE"
        complete_process 1 "Script cannot save the current directory before proceeding."
    fi
    DID_PUSHD=1
}

restore_current_directory() {
    if [ "$DID_PUSHD" -eq 1 ]; then
        popd > /dev/null 2>&1 || exit
    fi
    DID_PUSHD=0
}

complete_process() {
    local SCRIPT_RETURN_CODE=$1
    local COMPLETE_REASON=$2

    if [ -n "$COMPLETE_REASON" ] ; then
        echo "$COMPLETE_REASON"
    fi

    # if [ "$SCRIPT_RETURN_CODE" -ne 0 ]; then
    #     echo "Local run of Flask server tests failed." > /dev/null 2>&1
    # else
    #     echo "Local run of Flask server tests succeeded." > /dev/null 2>&1
    # fi

    if [ -f "$TEMP_FILE" ]; then
        rm "$TEMP_FILE"
    fi
    if [ -f "$TEMP_VARS_FILE" ]; then
        rm "$TEMP_VARS_FILE"
    fi

    restore_current_directory

    exit "$SCRIPT_RETURN_CODE"
}

build_docker_image_if_required() {
    AZ_VERSION="2.52.0"
    TF_VERSION="1.5.7"
    IMAGE_NAME="zenika/terraform-azure-cli"
    IMAGE_TAG="dev"
    if docker images | grep "$IMAGE_NAME" > /dev/null 2>&1 ; then
        echo "Image already exists.  No building required." > /dev/null 2>&1
    else
        echo "Image does not currently exist. Bulding..." > /dev/null 2>&1
        if docker image build --build-arg AZURE_CLI_VERSION="$AZ_VERSION" --build-arg TERRAFORM_VERSION="$TF_VERSION" -t $IMAGE_NAME:$IMAGE_TAG . > "$TEMP_FILE" 2>&1 ; then
            cat "$TEMP_FILE"
            complete_process 1 "Docker image '$IMAGE_NAME:$IMAGE_TAG' failed to build."
        fi
    fi
}

build_secrets_script() {
    if [ -z "$TF_VAR_arm_client_id" ] ; then
        complete_process 1 "Environment variable 'TF_VAR_arm_client_id' is not set.  Please source ./terraform/init_tfvars.sh"
    fi
    if [ -z "$TF_VAR_arm_client_secret" ] ; then
        complete_process 1 "Environment variable 'TF_VAR_arm_client_secret' is not set.  Please source ./terraform/init_tfvars.sh"
    fi
    if [ -z "$TF_VAR_arm_subscription_id" ] ; then
        complete_process 1 "Environment variable 'TF_VAR_arm_subscription_id' is not set.  Please source ./terraform/init_tfvars.sh"
    fi
    if [ -z "$TF_VAR_arm_subscription_id" ] ; then
        complete_process 1 "Environment variable 'TF_VAR_arm_tenant_id' is not set.  Please source ./terraform/init_tfvars.sh"
    fi

    echo "# !!! This is a temporary file.  This should never be committed to a repository!!!" > $TEMP_VARS_FILE
    echo ""
    echo "export ARM_CLIENT_ID=\"$TF_VAR_arm_client_id\" " >> $TEMP_VARS_FILE
    echo "export ARM_CLIENT_SECRET=\"$TF_VAR_arm_client_secret\" "   >> $TEMP_VARS_FILE
    echo "export ARM_TENANT_ID=\"$TF_VAR_arm_tenant_id\" " >> $TEMP_VARS_FILE
    echo "export ARM_SUBSCRIPTION_ID=\"$TF_VAR_arm_subscription_id\" " >> $TEMP_VARS_FILE
    chmod +x $TEMP_VARS_FILE
}

# Set up any variables that we will need in the script.
TEMP_FILE=$(mktemp /tmp/show_reports.XXXXXXXXX)
TEMP_VARS_FILE=".secret.sh"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Clean entrance into the script.
save_current_directory

# Change the directory into the script's directory, to make things consistent.
cd "$SCRIPT_DIR" || exit

build_docker_image_if_required

restore_current_directory

build_secrets_script

if docker run -it --rm -v $PWD:$PWD -w $PWD zenika/terraform-azure-cli:dev bash -c "source ./$TEMP_VARS_FILE ;  terraform $*" ; then
    echo "Terraform command succeeded."
else
    echo "Terraform command failed."
    complete_process 1
fi

# cleanup
complete_process 0
