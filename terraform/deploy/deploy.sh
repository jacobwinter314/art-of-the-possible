#!/usr/bin/bash

../../terraform-image/terraform.sh init
if ../../terraform-image/terraform.sh apply ; then
    echo "good"
    ../../terraform-image/terraform.sh output
else
    echo "bad"
fi
