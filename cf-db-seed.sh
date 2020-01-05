#!/usr/bin/env bash

#####
# This script seeds the Postgres database using the migration Docker-image and Flyway by adding specific
# 'afterMigrate.sql' file to the flyway sql folder. It's supposed to be run manually when the stack is created
# to create default data or for some testing purposes.
#####

print_red() {
  printf "\033[1;31m$1\033[0m\n"
}

if [ -z "$1" ]; then
  print_red "No environment provided, using dev-environment"
  ENVIRONMENT="dev"
else
  ENVIRONMENT=$1
fi

##### Sceptre specific attributes
# AWS account id with access to push to the ECR, defined in the CloudFormation stacks ecr.yaml-template
AWS_ACCOUNT_ID="014750007983"
AWS_REGION="eu-west-1"
# From the Sceptre config.yaml
PROJECT="example-app"
# From the ecr.yaml-template
ECR_APP_NAME="migration"
# From the ecs-service.yaml-template
ECS_SERVICE_NAME="migration"
# Defined in the ecr.yaml
ECR_REPOSITORY=${PROJECT}-${ENVIRONMENT}/${ECR_APP_NAME}
REGISTRY_URL=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
TEMPLATE_NAME="ecs-db-migration"
CF_STACK_NAME=${PROJECT}-${ENVIRONMENT}-${AWS_REGION}-${TEMPLATE_NAME}
IMAGE_TAG="seed"
#####

IMAGE_WITH_SEED_TAG=${REGISTRY_URL}/${ECR_REPOSITORY}:${IMAGE_TAG}

set +x
eval $(aws ecr get-login --no-include-email --region ${AWS_REGION})

print_red "0) Building the new Docker images with the '${IMAGE_TAG}' tag"
docker build -t ${IMAGE_WITH_SEED_TAG} -f ./db/seed/Dockerfile ./db

print_red "1) Pushing the image with '${IMAGE_TAG}' tag"
docker push ${IMAGE_WITH_SEED_TAG}

print_red "2) Update the CloudFormation stack ${CF_STACK_NAME} ImageTag-parameter"
aws cloudformation update-stack \
  --stack-name ${CF_STACK_NAME} \
  --use-previous-template \
  --region ${AWS_REGION} \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
      ParameterKey=Project,ParameterValue=${PROJECT} \
      ParameterKey=Environment,ParameterValue=${ENVIRONMENT} \
      ParameterKey=MigrationRepositoryUri,UsePreviousValue=true \
      ParameterKey=ServiceName,UsePreviousValue=true \
      ParameterKey=ImageTag,ParameterValue=${IMAGE_TAG} \
      ParameterKey=DBName,UsePreviousValue=true \
      ParameterKey=DBURL,UsePreviousValue=true \
      ParameterKey=MigrationChecksum,UsePreviousValue=true \
      ParameterKey=ApplicationPort,UsePreviousValue=true

aws cloudformation wait stack-update-complete \
  --stack-name ${CF_STACK_NAME} \
  --region ${AWS_REGION}

print_red "3) Run the Flyway migration ECS-task"

get_stack_resource() {
  STACK_NAME=${PROJECT}-${ENVIRONMENT}-${AWS_REGION}-$1 # Eg example-app-dev-eu-west-1-security-groups
  echo $(aws cloudformation describe-stack-resource \
    --stack-name ${STACK_NAME} \
    --region ${AWS_REGION} \
    --logical-resource-id $2 \
    --query "StackResourceDetail.PhysicalResourceId" \
    --output text)
}

MIGRATION_TASK_ARN=$(get_stack_resource ecs-db-migration TaskDefinition)
PRIVATE_SUBNET_ID=$(get_stack_resource vpc 1PrivateSubnet)
APP_SECURITY_GROUP_ID=$(get_stack_resource security-groups AppSecurityGroup)
ECS_CLUSTER_ID=$(get_stack_resource ecs-cluster ECSCluster)

aws ecs run-task \
  --task-definition ${MIGRATION_TASK_ARN} \
  --region ${AWS_REGION} \
  --count 1 \
  --started-by ${PROJECT}-${ENVIRONMENT}-ci-user \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[${PRIVATE_SUBNET_ID}],securityGroups=[${APP_SECURITY_GROUP_ID}]}" \
  --cluster ${ECS_CLUSTER_ID}

print_red "4) ECS seeding task of the database running, finishes in approximately 1 minute"
