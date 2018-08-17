#!/bin/bash -xe

LOCAL_PORT=8800
CONTAINER_PORT=8800

NAMESPACE="teemukoivisto"
IMAGE_NAME="my-node-bootstrap"
LATEST_LOCAL_TAG="$(docker images | grep "${NAMESPACE}"/"${IMAGE_NAME}" | awk 'NR==1{print $2}')"

CONTAINER_ID=$(docker run -d -p ${LOCAL_PORT}:${CONTAINER_PORT} "${NAMESPACE}"/"${IMAGE_NAME}":"${LATEST_LOCAL_TAG}")
docker logs "${CONTAINER_ID}" -f