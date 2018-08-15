# My Node Bootstrap

## Requirements
Requires Node >= 8.9.0, yarn installed globally, also Docker and Docker Compose.

## How to install
1) Clone & run `yarn`
2) Copy and set your local environment variables: `cp .env.example .env`
3) Spin up the database with `npm run db:start`, run the migrations with `npm run db:migrate` and add test-data with `npm run db:add`
4) Start the TypeScript compiler with `yarn ts:watch` and in another terminal the app with `yarn dev`