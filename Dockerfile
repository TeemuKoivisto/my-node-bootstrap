# The builder image
FROM node:8.11.0 as builder

# Set NODE_ENV to build so that all devDependencies are fetched and tslint won't fail
ENV NODE_ENV build
ENV INSTALL_PATH /usr/my-node-bootstrap

WORKDIR ${INSTALL_PATH}

COPY package.json yarn.lock tsconfig.json tslint.json pm2-prod-app.yml ./
RUN yarn

COPY ./src ./src
COPY ./db ./db

# Set NODE_ENV to production so that all optimizations are enabled
ENV NODE_ENV production
RUN yarn ts

# The Node server image
FROM node:8.11.0

LABEL maintainer="https://github.com/teemukoivisto"

ENV API_PORT 8600
ENV INSTALL_PATH /usr/my-node-bootstrap
ENV CORS_SAME_ORIGIN true
# the ENVs are not shared so NODE_ENV needs to be set again
ENV NODE_ENV production

WORKDIR ${INSTALL_PATH}

COPY --from=builder ${INSTALL_PATH}/dist ./dist
COPY --from=builder ${INSTALL_PATH}/db ./db
COPY --from=builder ${INSTALL_PATH}/package.json ${INSTALL_PATH}/yarn.lock ${INSTALL_PATH}/pm2-prod-app.yml ./

RUN yarn install --production

EXPOSE ${API_PORT}

CMD ["./node_modules/pm2/bin/pm2-runtime", "start", "pm2-prod-app.yml"]