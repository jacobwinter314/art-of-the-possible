# This file should only be sourced.
# 
# This file should also NEVER be committed with any values present.

if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "Hey, you should source this script, not execute it!"
    exit 1
fi

export TF_VAR_arm_client_id=""
export TF_VAR_arm_client_secret=""
export TF_VAR_arm_subscription_id=""
export TF_VAR_arm_tenant_id=""
