#!/bin/bash

######################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. #
# SPDX-License-Identifier: MIT-0                                     #
######################################################################

source ./.env

# Login to container registry
echo "Logging in to $REGISTRY ..."

export AWS_REGION=${AWS_REGION}
echo "AWS_REGION=${AWS_REGION}"

#export ENDPOINT="https://api.ecr.${AWS_REGION}.amazonaws.com"
#echo "ENDPOINT=${ENDPOINT}"

export AWS_DEFAULT_REGION=$AWS_REGION
export REGION=$AWS_REGION

#P=$(aws ecr get-login-password --endpoint-url $ENDPOINT)

echo "REGISTRY: $REGISTRY"

CMD="aws ecr get-login-password | docker login --username AWS --password-stdin $REGISTRY"
#verbose=false
if [ ! "$verbose" == "false" ]; then echo -e "\n${CMD}\n"; fi
eval "$CMD"

