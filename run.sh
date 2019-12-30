#!/usr/bin/env bash

# Running this requires dotenv-cli installed globally eg "npm i -g dotenv-cli" https://github.com/entropitor/dotenv-cli
# It exposes the environment variables from a .env-file

dotenv -- docker run -it \
  -e JWT_SECRET \
  -e DB_USER \
  -e DB_PASSWORD \
  -p 8610:8600 \
  014750007983.dkr.ecr.eu-west-1.amazonaws.com/example-app-dev/example-nodejs
