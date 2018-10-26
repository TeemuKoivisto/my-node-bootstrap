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

CONTAINER_ID=$(docker run -d -p ${LOCAL_PORT}:${CONTAINER_PORT} "${NAMESPACE}"/"${IMAGE_NAME}":"${LATEST_LOCAL_TAG}")
docker logs "${CONTAINER_ID}" -f