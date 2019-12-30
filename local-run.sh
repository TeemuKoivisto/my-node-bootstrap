#!/bin/bash -xe

LOCAL_PORT=9601
CONTAINER_PORT=8600

NAMESPACE="teemukoivisto"
IMAGE_NAME="my-node-bootstrap"

NAMESPACE="teemukoivisto"
IMAGE_NAME="my-node-bootstrap"
LATEST_LOCAL_TAG="$(docker images | grep "${NAMESPACE}"/"${IMAGE_NAME}" | awk 'NR==1{print $2}')"
IMAGE="${NAMESPACE}"/"${IMAGE_NAME}":"${LATEST_LOCAL_TAG}"

# Stop and remove previously running same containers
OLD_CONTAINER_ID="$(docker ps -a | grep ${IMAGE} | awk '{print $1}')"
docker stop "${OLD_CONTAINER_ID}" || true
docker rm "${OLD_CONTAINER_ID}" || true

# Running this requires dotenv-cli installed globally eg "npm i -g dotenv-cli" https://github.com/entropitor/dotenv-cli
# It exposes the environment variables from a .env-file

dotenv -- docker run -it \
  -e JWT_SECRET \
  -e DB_USER \
  -e DB_PASSWORD \
  -p ${LOCAL_PORT}:${CONTAINER_PORT} \
  "${NAMESPACE}"/"${IMAGE_NAME}":"${LATEST_LOCAL_TAG}"

# CONTAINER_ID=$(docker run -d -p ${LOCAL_PORT}:${CONTAINER_PORT} "${NAMESPACE}"/"${IMAGE_NAME}":"${LATEST_LOCAL_TAG}")
# docker logs "${CONTAINER_ID}" -f