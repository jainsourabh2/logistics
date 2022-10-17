# syntax=docker/dockerfile:1

FROM node:12.18.1

ENV NODE_ENV=production

WORKDIR /app

COPY package*.json ./
COPY src/ ./
COPY public/ ./

RUN npm install

CMD [ "npm", "start" ]