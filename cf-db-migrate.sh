#!/usr/bin/env bash

#####
# This script migrates the database using Flyway migrations inside db/migrations folder. Flyway is a simple
# migration library that is first and foremost, simple to use and uses just regular .sql-files instead of
# library specific magic. I'm using a MD5 checksum of the migrations-folder contents to prevent migrations
# being run when there are no migrations. But if there are migrations, we are simply using a Flyway Docker-image
# to run them as "migration" ECS-task as defined in Sceptre ecs-db-migration.yaml-file.
#
# There aren't really checks incase something fails, and if something fails you probably you have to fix it manually
# eg something goes wrong in the ECS migration task. If you were by accident to run some buggy migrations which either
# fail or are missing something, the only correct way is to either create a new one with "Vx_x__xx" or undo one
# "Ux_x_xx". This is because Flyway stores the last ran migration's version number, and won't run any new migrations
# below that number even if their files are changed.
#
# Usage: AWS_PROFILE=x ./cf-db-migrate.sh ?(dev|prod) ?x
# where 1st argument is the environment which is either dev or prod
# and 2nd argument any string to pass the checksum check (incase the previous migration
# ECS task failed but updated the checksum)
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

if [ -z "$2" ]; then
  SKIP_CHECKSUM=false
else
  SKIP_CHECKSUM=true
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
# Defined in the ecr.yaml RepositoryName with ${Project}-${Environment}/${ExampleNodejsAppName}
ECR_REPOSITORY=${PROJECT}-${ENVIRONMENT}/${ECR_APP_NAME}
REGISTRY_URL=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
IMAGE_TAG="latest"
# The to-be-updated Sceptre stack (and only its "Image" parameter)
TEMPLATE_NAME="ecs-db-migration"
CF_STACK_NAME=${PROJECT}-${ENVIRONMENT}-${AWS_REGION}-${TEMPLATE_NAME} # Probably example-app-dev-eu-west-1-ecs-service
MIGRATIONCHECKSUM_SSM_PATH="/example-app/dev/migration-checksum"
#####

# First check if the current checksum of migration sql files matches the one in use
CHECKSUM=$(find -s ./db/migrations -type f | md5)
CURRENT_CHECKSUM=$(aws ssm get-parameter \
  --name ${MIGRATIONCHECKSUM_SSM_PATH} \
  --region ${AWS_REGION} \
  --output text \
  --query Parameter.Value)

if [ "$CHECKSUM" = "$CURRENT_CHECKSUM" ] && [ $SKIP_CHECKSUM = false ]; then
  print_red "0) Migrations checksum unchanged - skip migrations"
  exit 0
fi

print_red "0) Running the migrations"

# Eg 014750007983.dkr.ecr.eu-west-1.amazonaws.com/example-app-dev/migration:latest
IMAGE_WITH_LATEST_TAG=${REGISTRY_URL}/${ECR_REPOSITORY}:${IMAGE_TAG}

set +x
eval $(aws ecr get-login --no-include-email --region ${AWS_REGION})
# set -x

print_red "1) Building the new Docker images with '${IMAGE_TAG}' tag"
docker build -t ${IMAGE_WITH_LATEST_TAG} -f ./db/Dockerfile ./db

print_red "2) Pushing the image with '${IMAGE_TAG}' tag"
docker push ${IMAGE_WITH_LATEST_TAG}

print_red "3) Update the CloudFormation stack ${CF_STACK_NAME}"
aws cloudformation update-stack \
  --stack-name ${CF_STACK_NAME} \
  --use-previous-template \
  --region ${AWS_REGION} \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
      ParameterKey=Project,ParameterValue=${PROJECT} \
      ParameterKey=Environment,ParameterValue=${ENVIRONMENT} \
      ParameterKey=MigrationRepositoryUri,UsePreviousValue=true \
      ParameterKey=ServiceName,ParameterValue=${ECS_SERVICE_NAME} \
      ParameterKey=ImageTag,ParameterValue=${IMAGE_TAG} \
      ParameterKey=DBName,UsePreviousValue=true \
      ParameterKey=DBURL,UsePreviousValue=true \
      ParameterKey=MigrationChecksum,ParameterValue=${CHECKSUM} \
      ParameterKey=ApplicationPort,UsePreviousValue=true

aws cloudformation wait stack-update-complete \
  --stack-name ${CF_STACK_NAME} \
  --region ${AWS_REGION}

print_red "4) Run the migration task"
# NOTE: If the script fails at running the migration task in ECS, the checksum value won't be
# reversed thus you have to manually run the "aws ecs run-task" part again.

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

print_red "5) Migrations finished"
