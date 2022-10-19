# syntax=docker/dockerfile:1

FROM node:12.18.1

ENV NODE_ENV=production

ENV PORT 8080
EXPOSE 8080

WORKDIR /app

COPY package*.json ./
COPY src/ ./
COPY public/ ./

RUN npm install

COPY . ./

CMD [ "npm", "start" ]