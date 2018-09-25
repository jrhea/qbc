FROM ubuntu:16.04

ENV LANG en_US.UTF-8
ENV GOVERSION 1.9.1
ENV GOROOT /opt/go
ENV GOPATH /root/.go

RUN apt-get update -qq && apt-get -y -qq install libdb-dev libpthread-stubs0-dev build-essential wget git

RUN cd /opt && wget -q https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz && \
    tar zxf go${GOVERSION}.linux-amd64.tar.gz && rm go${GOVERSION}.linux-amd64.tar.gz && \
    ln -s /opt/go/bin/go /usr/bin/ && \
    mkdir $GOPATH

RUN echo "#!/bin/bash\ncd /tmp/crux && make setup && make build" > build.sh && chmod +x build.sh
RUN echo "#!/bin/bash\ncd /tmp/geth && make all" > build-geth.sh && chmod +x build-geth.sh
CMD "./build.sh"