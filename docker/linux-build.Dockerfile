FROM ubuntu:16.04

ENV LANG en_US.UTF-8
ENV GOVERSION 1.9.1
ENV GOROOT /opt/go
ENV GOPATH /root/.go

RUN apt-get update -qq \
    && apt-get -y -qq install libdb-dev libpthread-stubs0-dev build-essential libleveldb-dev libsodium-dev zlib1g-dev libtinfo-dev wget curl git \
    && cd /opt && wget -q https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz \
    && tar zxf go${GOVERSION}.linux-amd64.tar.gz \
    && rm go${GOVERSION}.linux-amd64.tar.gz \
    && ln -s /opt/go/bin/go /usr/bin/ \
    && mkdir ${GOPATH}

RUN curl -sSL https://get.haskellstack.org/ | sh && stack setup

ARG CACHEBUST=1

# /tmp/constellation/.stack-work/install/x86_64-linux/lts-10.5/8.2.2/bin

RUN echo "#!/bin/bash\ncd /tmp/constellation && stack install && cp /root/.local/bin/constellation-node /tmp/constellation/bin/ && ldd /tmp/constellation/bin/constellation-node | cut -f3- -d ' ' | grep '^/.*' | cut -f1 -d ' '| xargs -I '{}' cp -v '{}' /tmp/constellation/bin/" > build-constellation.sh && chmod +x build-constellation.sh \
    && echo "#!/bin/bash\ncd /tmp/crux && make setup && make build" > build-crux.sh && chmod +x build-crux.sh \
    && echo "#!/bin/bash\ncd /tmp/quorum && make all" > build-quorum.sh && chmod +x build-quorum.sh
