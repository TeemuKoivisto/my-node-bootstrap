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
#####

##### Sceptre specific attributes

# AWS account id with access to push to the ECR, used in the CloudFormation stacks ecr.yaml-template
# Default value is my own id
AWS_ACCOUNT_ID="014750007983"
AWS_REGION="eu-west-1"
# Project name as in the Sceptre configs
PROJECT="example-app"
# Default environment is dev
ENVIRONMENT="dev"

# Repo name or whatever of the repository as in the ecr.yaml-template
ECR_APP_NAME="migration"
# Defined in the ecr.yaml RepositoryName as ${Project}-${Environment}/${AppName}
ECR_REPOSITORY=${PROJECT}-${ENVIRONMENT}/${ECR_APP_NAME}
REGISTRY_URL=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
IMAGE_TAG="latest"
# Eg 014750007983.dkr.ecr.eu-west-1.amazonaws.com/example-app-dev/migration:latest
IMAGE_WITH_LATEST_TAG=${REGISTRY_URL}/${ECR_REPOSITORY}:${IMAGE_TAG}

# From the ecs-service.yaml-template
ECS_SERVICE_NAME="migration"
# The to-be-updated Sceptre stack (and only its "Image" parameter)
TEMPLATE_NAME="ecs-db-migration"
# Probably example-app-dev-eu-west-1-ecs-db-migration
CF_STACK_NAME=${PROJECT}-${ENVIRONMENT}-${AWS_REGION}-${TEMPLATE_NAME}

MIGRATION_CHECKSUM_SSM_PATH="/example-app/dev/migration-checksum"
SKIP_MIGRATION_CHECKSUM=false
#####

print_red() {
  printf "\033[1;31m$1\033[0m\n"
}

usage_migration() {
  cat << USAGE >&2
Usage:
    $0 ?[-e=ENV] ?[-id=ID] ?[-s]
    -e=ENV | --env=ENV          Environment, either dev or prod. Default is dev
    -id=ID | --aws-id=ID        AWS account id where your stacks are launched. Used for ECR pull access. I'm using my own
                                AWS account id as default value since I'm lazy and probably only one who'll ever use this.
    -s | --skip-checksum        Skip migration checksum when deploying ECS migration task (incase previous task errored)
USAGE
}

# Parse the arguments
for i in "$@"; do
  case $i in
    -e=*|--env=*)
      ENVIRONMENT="${i#*=}"
      shift
    ;;
    -id=*|--aws-id=*)
      AWS_ACCOUNT_ID="${i#*=}"
      shift
    ;;
    -s|--skip-checksum)
      SKIP_MIGRATION_CHECKSUM=true
      shift
    ;;
    *)
      print_red "Unknown option '$i'"
      usage_migration
      exit 1
    ;;
  esac
done

# First check if the current checksum of migration sql files matches the one in use
CHECKSUM=$(find -s ./db/migrations -type f | md5)
CURRENT_CHECKSUM=$(aws ssm get-parameter \
  --name ${MIGRATION_CHECKSUM_SSM_PATH} \
  --region ${AWS_REGION} \
  --output text \
  --query Parameter.Value)

if [ "$SKIP_MIGRATION_CHECKSUM" = true ]; then
  print_red "0) Skip migration checksum check - running the migrations"
elif [ "$CHECKSUM" = "$CURRENT_CHECKSUM" ]; then
  print_red "0) Migrations checksum unchanged - skip migrations"
  exit 0
else
  print_red "0) Checksum changed - running the migrations"
fi

set +x # Disable echoing if enabled, since the output is ECR docker login & password
eval $(aws ecr get-login --no-include-email --region ${AWS_REGION})

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

print_red "5) Migration ECS task running, finishes in approximately 1 minute"
