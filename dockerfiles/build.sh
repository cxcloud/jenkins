#!/bin/bash

function help {
    printf "
This script will build a custom Docker image and optionally push it to the registry.

Usage:
    ./build.sh -t NAME:TAG
    -t  Name and tag in the 'name:tag' format
        E.g. ./build.sh -t cxcloud-jenkins:0.0.0
    -r  Registry
        E.g. ./build.sh -r 012345678901.dkr.ecr.eu-west-1.amazonaws.com -t cxcloud-jenkins:0.0.0
    -p  Push to registry, boolean
        E.g. ./build.sh -p true -t cxcloud-jenkins:0.0.0
    -a  AWS Profile
        E.g. ./build.sh -a cxcloud -p true -t cxcloud-jenkins:0.0.0
    -n  Build Docker image with flag --no-cache, boolean
        E.g. ./build.sh -n true -r 012345678901.dkr.ecr.eu-west-1.amazonaws.com -t cxcloud-jenkins:0.0.0
    \n";
}

# Get parameters
while getopts t:r:p:a:n: option; do
    case "${option}" in
        t) IMAGE_TAG=${OPTARG};;
        p) PUSH=${OPTARG};;
        r) REGISTRY=${OPTARG};;
        a) AWS_PROFILE=${OPTARG};;
        n) NO_CACHE=${OPTARG};;
    esac
done

# Check that required parameter exist
if [ -z ${IMAGE_TAG} ] || [ -z ${REGISTRY} ]; then
    help
    exit
fi

# Add profile flag to AWS command
if [ ! -z ${AWS_PROFILE} ]; then
    AWS_PROFILE="--profile ${AWS_PROFILE}"
fi

if [ ! -z ${NO_CACHE} ] && [ ${NO_CACHE} == "true" ]; then
    NO_CACHE="--no-cache"
fi

# Get the image name without tag and enter the right directory
IMAGE=${IMAGE_TAG%:*}
cd $(dirname $0)/$IMAGE

# Build image
docker build ${NO_CACHE} --pull -t ${REGISTRY}/${IMAGE_TAG} .

# Push to registry if -p is true
if [ ! -z ${PUSH} ] && [ ${PUSH} == "true" ]; then
    # Login to registry
    $(aws ecr get-login ${AWS_PROFILE} --no-include-email)
    # Push to registry
    docker push ${REGISTRY}/${IMAGE_TAG}
fi
