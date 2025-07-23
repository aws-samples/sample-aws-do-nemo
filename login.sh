#!/bin/bash

######################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. #
# SPDX-License-Identifier: MIT-0                                     #
######################################################################

source ./.env

# Login to container registry
echo "Logging in to $REGISTRY ..."

P=$(aws ecr get-login-password)

CMD="docker login --username AWS --password $P $REGISTRY"
verbose=false
if [ ! "$verbose" == "false" ]; then echo -e "\n${CMD}\n"; fi
eval "$CMD"

