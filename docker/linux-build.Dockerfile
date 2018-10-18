FROM ubuntu:16.04

ENV LANG en_US.UTF-8
ENV GOVERSION 1.9.1
ENV GOROOT /opt/go
ENV GOPATH /root/.go

RUN apt-get update -qq && apt-get -y -qq install libdb-dev libpthread-stubs0-dev build-essential libleveldb-dev libsodium-dev zlib1g-dev libtinfo-dev wget curl git

RUN cd /opt && wget -q https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz && \
    tar zxf go${GOVERSION}.linux-amd64.tar.gz && rm go${GOVERSION}.linux-amd64.tar.gz && \
    ln -s /opt/go/bin/go /usr/bin/ && \
    mkdir $GOPATH

RUN curl -sSL https://get.haskellstack.org/ | sh && stack setup

RUN echo "#!/bin/bash\ncd /tmp/constellation && stack install && cp /root/.local/bin/constellation-node ./bin/" > build-constellation.sh && chmod +x build-constellation.sh
RUN echo "#!/bin/bash\ncd /tmp/crux && make setup && make build" > build-crux.sh && chmod +x build-crux.sh
RUN echo "#!/bin/bash\ncd /tmp/geth && make all" > build-geth.sh && chmod +x build-geth.sh
CMD "echo Building..."