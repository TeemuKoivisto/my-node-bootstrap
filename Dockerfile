FROM node:8.11.0

LABEL maintainer="https://github.com/teemukoivisto"

ENV API_PORT 8800
ENV INSTALL_PATH /usr/my-node-bootstrap

COPY ./dist ${INSTALL_PATH}
COPY ./node_modules ${INSTALL_PATH}/node_modules

WORKDIR ${INSTALL_PATH}

EXPOSE ${API_PORT}

CMD ["node", "index.js"]