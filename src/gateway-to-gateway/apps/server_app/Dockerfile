FROM docker:dind

# install dependencies
RUN apk add net-tools tcpdump npm

RUN npm install -g wait-on

ENTRYPOINT [ "/start.sh" ]
