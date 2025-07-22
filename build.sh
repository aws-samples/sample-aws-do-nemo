#!/bin/bash

source .env

echo "aws-do-nemo shell $VERSION" > Container-Root/version.txt

# Get NEMO sample code
echo ""
echo "Downloading NEMO 2.0 examples from https://github.com/aws-samples/awsome-distributed-training/tree/main/3.test_cases/megatron/nemo/kubernetes ..."
mkdir -p Container-Root/nemo/kubernetes
pushd Container-Root/nemo/kubernetes
docker container run --rm -it -v $(pwd):/wd iankoulski/do-git /gitcp.sh https://github.com/aws-samples/awsome-distributed-training/tree/main/3.test_cases/megatron/nemo/kubernetes /wd ${UID}
echo "Examples from https://github.com/aws-samples/aws-distributed-training/tree/main/3.test_cases/megatron/nemo/kubernetes" > ./info.txt
echo "Cloned on $(date)" >> ./info.txt
popd

# Build Docker image
echo ""
echo "Building container image ${REGISTRY}${IMAGE}${TAG} ..."
CMD="docker image build ${BUILD_OPTS} -t ${REGISTRY}${IMAGE}${TAG} ."
eval "$CMD"

