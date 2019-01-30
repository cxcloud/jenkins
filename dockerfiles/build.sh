#!/bin/bash

function help {
    printf "
This script will build a custom Docker image and optionally push it to the registry.

Usage:
    ./build.sh -t NAME:TAG
    -t  Name and tag in the 'name:tag' format
        E.g. ./build.sh -t cxcloud-jenkins:0.0.0
    -r  Registry, default: 033155846522.dkr.ecr.eu-west-1.amazonaws.com
        E.g. ./build.sh -r 033155846522.dkr.ecr.eu-west-1.amazonaws.com -t cxcloud-jenkins:0.0.0
    -p  Push to registry, boolean
        E.g. ./build.sh -p true -t cxcloud-jenkins:0.0.0
    -a  AWS Profile
        E.g. ./build.sh -a cxcloud -p true -t cxcloud-jenkins:0.0.0
    \n";
}

# Get parameters
while getopts t:r:p:a: option; do
    case "${option}" in
        t) IMAGE_TAG=${OPTARG};;
        p) PUSH=${OPTARG};;
        r) REGISTRY=${OPTARG};;
        a) AWS_PROFILE=${OPTARG};;
    esac
done

# Check that required parameter exist
if [ -z ${IMAGE_TAG} ]; then
    help
    exit
fi

# Set registry default value if parameter is not yet set
if [ -z ${REGISTRY} ]; then
    REGISTRY="033155846522.dkr.ecr.eu-west-1.amazonaws.com"
fi

# Add profile flag to AWS command
if [ ! -z ${AWS_PROFILE} ]; then
    AWS_PROFILE="--profile ${AWS_PROFILE}"
fi

# Get the image name without tag and enter the right directory
IMAGE=${IMAGE_TAG%:*}
cd $IMAGE

# Build image
docker build --pull -t ${REGISTRY}/${IMAGE_TAG} .

# Push to registry if -p is true
if [ ! -z ${PUSH} ] && [ ${PUSH} == "true" ]; then
    # Login to registry
    $(aws ecr get-login ${AWS_PROFILE} --no-include-email)
    # Push to registry
    docker push ${REGISTRY}/${IMAGE_TAG}
fi
