FROM alpine

LABEL maintainer="docker@matthias-simonis.de"

RUN apk update
RUN apk add -U openssl
RUN apk add -U wget

RUN wget https://github.com/rancher/convoy/releases/download/v0.5.0/convoy.tar.gz
RUN tar xvf convoy.tar.gz
RUN cp convoy/convoy convoy/convoy-pdata_tools /usr/local/bin/
RUN rm convoy.tar.gz

COPY run.sh .

ENTRYPOINT [ "sh","run.sh" ]