FROM alpine:latest

RUN apk add --no-cache bash

RUN apk add --no-cache procps util-linux

WORKDIR /app

COPY app/ .

RUN chmod +x ./*.sh

ENTRYPOINT ["./app.sh"]