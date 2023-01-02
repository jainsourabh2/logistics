# syntax=docker/dockerfile:1

FROM node:12.18.1

ENV NODE_ENV=production
ENV BT_INSTANCE=logistics_inst
ENV BT_TABLE_ORDER=logistics_order
ENV BT_TABLE_CUSTOMER=logistics_customer

WORKDIR /app

COPY package*.json ./
COPY *.js ./

RUN npm install

COPY . ./

EXPOSE 8080

CMD [ "npm", "start" ]