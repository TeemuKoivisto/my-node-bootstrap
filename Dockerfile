FROM node:8.11.0

LABEL maintainer="https://github.com/teemukoivisto"

ENV API_PORT 8800
ENV INSTALL_PATH /usr/my-node-bootstrap

COPY ./dist ${INSTALL_PATH}/dist
COPY ./node_modules ${INSTALL_PATH}/node_modules
COPY ./db ${INSTALL_PATH}/db
COPY ./package.json ${INSTALL_PATH}

WORKDIR ${INSTALL_PATH}

EXPOSE ${API_PORT}

CMD ["node", "./dist/index.js"]