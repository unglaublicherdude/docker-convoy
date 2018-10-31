FROM alpine

LABEL maintainer="docker@matthias-simonis.de"

RUN apk update && \
    apk add -U openssl wget && \
    rm -rf /var/cache/apk/*

RUN wget https://github.com/rancher/convoy/releases/download/v0.5.1/convoy.tar.gz && \
    tar xvf convoy.tar.gz && \
    cp convoy/convoy convoy/convoy-pdata_tools /usr/local/bin/ && \
    rm convoy.tar.gz

COPY run.sh .

ENTRYPOINT [ "sh","run.sh" ]