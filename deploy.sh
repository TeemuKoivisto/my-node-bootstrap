#!/usr/bin/env bash -x

print_red() {
  printf "\033[1;31m$1\033[0m\n"
}

if [ -z "$1" ]; then
  print_red "No version tag provided, using the latest git tag"
  # The version tag eg v0.1.0 used for the created image, pushed to ECR and used in the ecs-service.yaml-stack Image-parameter
  NEW_TAG=$(git describe --abbrev=0)
else
  NEW_TAG=$1
fi

##### Sceptre specific attributes
# AWS account id with access to push to the ECR, defined in the CloudFormation stacks ecr.yaml-template
AWS_ACCOUNT_ID="014750007983"
AWS_REGION="eu-west-1"
# From the Sceptre config.yaml
PROJECT="example-app"
# Should be probably a parameter but since there's only one environment meh
ENVIRONMENT="dev"
# From the ecr.yaml-template
ECR_APP_NAME="example-nodejs"
# From the ecs-service.yaml-template, not the same as app name because ehh
ECS_SERVICE_NAME="examplenodejs"
# Defined in the ecr.yaml RepositoryName with ${Project}-${Environment}/${ExampleNodejsAppName}
ECR_REPOSITORY=${PROJECT}-${ENVIRONMENT}/${ECR_APP_NAME}
REGISTRY_URL=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
# The to-be-updated Sceptre stack (and only its "Image" parameter)
TEMPLATE_NAME="ecs-service"
APP_STACK_NAME=${PROJECT}-${ENVIRONMENT}-${AWS_REGION}-${TEMPLATE_NAME} # Probably example-app-dev-eu-west-1-ecs-service
#####

print_red "Updating the app ${ECR_APP_NAME} for the ECS service in stack ${APP_STACK_NAME} with tag ${NEW_TAG}"
aws cloudformation update-stack \
  --stack-name ${APP_STACK_NAME} \
  --use-previous-template \
  --region ${AWS_REGION} \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
      ParameterKey=Project,ParameterValue=${PROJECT} \
      ParameterKey=Environment,ParameterValue=${ENVIRONMENT} \
      ParameterKey=VpcId,UsePreviousValue=true \
      ParameterKey=1PublicSubnetId,UsePreviousValue=true \
      ParameterKey=2PublicSubnetId,UsePreviousValue=true \
      ParameterKey=3PublicSubnetId,UsePreviousValue=true \
      ParameterKey=AppSecurityGroupId,UsePreviousValue=true \
      ParameterKey=ECSClusterName,UsePreviousValue=true \
      ParameterKey=ScalingRoleArn,UsePreviousValue=true \
      ParameterKey=PublicTargetGroupArn,UsePreviousValue=true \
      ParameterKey=ExampleNodejsRepositoryUri,UsePreviousValue=true \
      ParameterKey=ServiceName,ParameterValue=${ECS_SERVICE_NAME} \
      ParameterKey=ImageTag,ParameterValue=${NEW_TAG} \
      ParameterKey=DBName,UsePreviousValue=true \
      ParameterKey=DBURL,UsePreviousValue=true \
      ParameterKey=ApplicationPort,UsePreviousValue=true

aws cloudformation wait stack-update-complete \
  --stack-name ${APP_STACK_NAME} \
  --region ${AWS_REGION}
