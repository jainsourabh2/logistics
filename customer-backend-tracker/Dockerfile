# syntax=docker/dockerfile:1

FROM node:12.18.1

ENV NODE_ENV=production
ENV BT_INSTANCE=production
ENV BT_TABLE=production


WORKDIR /app

COPY package*.json ./
COPY *.js ./

RUN npm install

COPY . ./

CMD [ "npm", "start" ]