#!/usr/bin/bash

LOCAL_TERRAFORM_VARS_FILE="terraform.tfvars"

{
    echo "# This file should never be committed."
    echo ""

    echo "acr_host_name             = \"$ACR_NAME\""
    echo "acr_image_name            = \"art-of-the-possible\""
    echo "acr_image_tag             = \"0.5.0.1695566861\""
    echo "aks_cluster_name          = \"aks-artpossible-dev-westus\""
    echo "aks_resource_group_name   = \"rg-artpossible-dev-westus\""
} > $LOCAL_TERRAFORM_VARS_FILE

../../terraform-image/terraform.sh init
if ../../terraform-image/terraform.sh apply ; then
    echo "good"
    ../../terraform-image/terraform.sh output
else
    echo "bad"
fi

if [ -f "$LOCAL_TERRAFORM_VARS_FILE" ]; then
    rm "$LOCAL_TERRAFORM_VARS_FILE"
fi
