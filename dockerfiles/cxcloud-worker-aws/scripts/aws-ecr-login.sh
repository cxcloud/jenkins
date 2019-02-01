#/bin/bash

# Requires aws-cli with configured permissions
AWS_DOCKER_REPO=$(aws ecr get-authorization-token --output text  --query 'authorizationData[].proxyEndpoint' --region eu-central-1)
aws ecr get-login --no-include-email --region eu-central-1 | awk '{print $6}' | docker login -u AWS --password-stdin $AWS_DOCKER_REPO
