#!/bin/bash -xe

NAMESPACE="teemukoivisto"
IMAGE_NAME="my-node-bootstrap"
VERSION_TAG="$(git tag -l | awk 'END{print}')"

docker build -t "${NAMESPACE}"/"${IMAGE_NAME}":"${VERSION_TAG}" .
