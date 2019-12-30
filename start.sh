#!/bin/sh

AWS_REGION="eu-west-1"

if [ -z "$DB_PASSWORD" ]; then
  echo "BEFORE BOOT: Fetching the environment variables from SSM"
  set +e
  export JWT_SECRET=`aws ssm get-parameter --name ${JWT_SECRET_SSM_PATH} --with-decryption --region ${AWS_REGION} --output text --query Parameter.Value`
  export DB_USER=`aws ssm get-parameter --name ${DB_USER_SSM_PATH} --with-decryption --region ${AWS_REGION} --output text --query Parameter.Value`
  export DB_PASSWORD=`aws ssm get-parameter --name ${DB_PASSWORD_SSM_PATH} --with-decryption --region ${AWS_REGION} --output text --query Parameter.Value`
  set -e
else
  # For running the image locally with manually exposed environment variables and without AWS credentials
  echo "BEFORE BOOT: Database credentials have been already set manually"
fi

node ./dist/index.js
