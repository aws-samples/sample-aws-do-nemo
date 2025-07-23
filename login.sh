#!/bin/bash

######################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. #
# SPDX-License-Identifier: MIT-0                                     #
######################################################################

source ./.env

# Login to container registry
echo "Logging in to $REGISTRY ..."

ENDPOINT="https://api.ecr.${AWS_REGION}.amazonaws.com"

echo "AWS_REGION=${AWS_REGION}"

export AWS_DEFAULT_REGION=$AWS_REGION
export REGION=$AWS_REGION

P=$(aws ecr get-login-password --endpoint-url $ENDPOINT)

echo "Cred: $P"
echo "REGISTRY: $REGISTRY"

CMD="docker login --username AWS --password $P $REGISTRY"
verbose=false
if [ ! "$verbose" == "false" ]; then echo -e "\n${CMD}\n"; fi
eval "$CMD"

