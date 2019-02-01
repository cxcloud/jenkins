#!/usr/bin/env bash

# ==========================================================
# COPY from cxcloud-dna-infra. Repository has secrets
# needs to be crypted/removed. Then we can use it as package
# ==========================================================

set -euo pipefail

function help(){
    echo "";
    echo "Usage: ecr-update-service.sh cluster_name service_name image_tag";
    exit 1;
}

if [[ $# -ne 3 ]]; then
    help
fi

CLUSTER_NAME=$1
SERVICE_NAME=$2
NEW_IMAGE_URL=$3

CURRENT_TASK_DEF_ARN=$(aws ecs describe-services --cluster $1 --service $2 --query "services[*].taskDefinition" --output text)
CURRENT_TASK_DEF=$(aws ecs describe-task-definition --task-definition $CURRENT_TASK_DEF_ARN)

echo "Current task definition arn:  $CURRENT_TASK_DEF_ARN"

CURRENT_IMAGE_NAME=$(echo $CURRENT_TASK_DEF | jq '.taskDefinition.containerDefinitions[0].image')

echo "Current image:                $CURRENT_IMAGE_NAME"

echo "New image:                    \"$NEW_IMAGE_URL\""

NEW_TASK_DEF=$(echo $CURRENT_TASK_DEF | jq ".taskDefinition | .containerDefinitions[0].image |= \"$NEW_IMAGE_URL\" | del(.taskDefinitionArn,.status,.revision,.requiresAttributes,.compatibilities)")

NEW_TASK_DEF_ARN=$(aws ecs register-task-definition --cli-input-json "$NEW_TASK_DEF" | jq -r '.taskDefinition.taskDefinitionArn')

echo "New task definition arn:      $NEW_TASK_DEF_ARN"

SERVICE=$(aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $NEW_TASK_DEF_ARN)

echo "Service updated successfully!"


