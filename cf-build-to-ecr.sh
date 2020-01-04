#!/usr/bin/env bash -x

print_red() {
  printf "\033[1;31m$1\033[0m\n"
}

if [ -z "$1" ]; then
  print_red "No version tag provided, using the latest git tag"
  # The version tag eg v0.1.0 used for the created image, pushed to ECR and used in the ecs-service.yaml-stack Image-parameter
  VERSION_TAG=$(git describe --abbrev=0)
else
  VERSION_TAG=$1
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
# Defined in the ecr.yaml RepositoryName with ${Project}-${Environment}/${ExampleNodejsAppName}
ECR_REPOSITORY=${PROJECT}-${ENVIRONMENT}/${ECR_APP_NAME}
REGISTRY_URL=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
#####

# Eg 014750007983.dkr.ecr.eu-west-1.amazonaws.com/example-app-dev/example-nodejs:v0.2.0
IMAGE_WITH_NEW_TAG=${REGISTRY_URL}/${ECR_REPOSITORY}:${VERSION_TAG}
# Eg 014750007983.dkr.ecr.eu-west-1.amazonaws.com/example-app-dev/example-nodejs:latest
IMAGE_WITH_LATEST_TAG=${REGISTRY_URL}/${ECR_REPOSITORY}:latest

set +x
eval $(aws ecr get-login --no-include-email --region ${AWS_REGION})
set -x

print_red "Building the new Docker images with the ${VERSION_TAG} and 'latest' tags"
docker build -t ${IMAGE_WITH_NEW_TAG} -t ${IMAGE_WITH_LATEST_TAG} .

print_red "Pushing the image as ${IMAGE_WITH_NEW_TAG}"
docker push ${IMAGE_WITH_NEW_TAG}

print_red "Pushing the image with 'latest' tag"
docker push ${IMAGE_WITH_LATEST_TAG}

print_red "Note the dangling <none> container from the builder image (contains cached layers for consecutive builds)"
print_red "You might remove it with the rest at some point with 'docker system prune'"
docker images | grep "<none>" | awk '{print $3}'
# Here is how to delete the created intermediate builder-image (with <none> name)
# docker images | grep "<none>" | awk '{print $3}' | xargs docker rmi -f

exit 0
