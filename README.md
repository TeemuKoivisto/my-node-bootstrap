# My Node Bootstrap

## Requirements
Requires Node >= 8.9.0, yarn installed globally, also Docker and Docker Compose.

## How to install
1) Clone & run `yarn`
2) Copy and set your local environment variables: `cp .env.example .env`
3) Spin up the database with `npm run db:start`, run the migrations with `npm run db:migrate` and add test-data with `npm run db:add`
4) Start the TypeScript compiler with `yarn ts:watch` and in another terminal the app with `yarn dev`

## Architecture

The app is just a basic Express app with the basic boilerplate.

Due to the way how the ALB and CloudFront are configured, the routes to the NodeJS app are all on path `/api`. To change it you should change it 

## TODO

Switch local dev pm2 to Docker Compose too incase adding LocalStack for AWS services(?).

## Basic psql commands

Psql is a command line interface for issuing SQL statements against the database. You can use `npm run db:connect` to connect to your local instance created by the Docker Compose. Here's some useful commands to get started with it:

`\q` exits psql
`\dt` displays all the tables in the current database
