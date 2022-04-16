#!/bin/bash
set -ev

if [ $# -ne 6 ]; then
  echo "use: $0 new_image_tag task_definition_name aws_account aws_region image_name cluster_name"
  exit 1
fi


#NEW IMAGE TAG ID

export CLUSTER_NAME="$1"
echo $CLUSTER_NAME

export TASK_DEFINITION_NAME="$2"
echo $TASK_DEFINITION_NAME

export REGISTRY="$3"
echo $REGISTRY

export IMAGE_NAME="$4"
echo $IMAGE_NAME

export TAG="$5"
echo $TAG

export REPOSITORY_URL="$REGISTRY/$IMAGE_NAME:$TAG"
echo $REPOSITORY_URL

#GENERATE NEW TASK DEFINITION
aws ecs describe-task-definition --task-definition $TASK_DEFINITION_NAME --query taskDefinition | jq 'del(.taskDefinitionArn, .compatibilities, .revision, .status, .requiresAttributes, .registeredAt, .registeredBy)' | jq --arg IMAGE $REPOSITORY_URL '.containerDefinitions[].image = $IMAGE' > task_definition.json
echo "NEW TASK JSON GENERATED"

#CREATE NEW TASK DEFINITION
export NEW_TASK_DEFINITION_ARN=$(aws ecs register-task-definition --cli-input-json file://task_definition.json --query taskDefinition | jq '.taskDefinitionArn' -r)
echo "PUSH NEW TASK DEFINITION ARN $NEW_TASK_DEFINITION_ARN"

#UPDATE SERVICE TO NEW TASK DEFINITION
aws ecs update-service --cluster $CLUSTER_NAME --service $TASK_DEFINITION_NAME --task-definition $NEW_TASK_DEFINITION_ARN --force-new-deployment
echo "SERVICE UPDATED"
