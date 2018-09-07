FROM ubuntu:16.04

COPY build/quorum-*-linux-386.tar.gz /tmp/quorum.tar.gz

RUN cd /opt && \
  tar xzf /tmp/quorum.tar.gz && \
  rm /tmp/quorum.tar.gz && \
  chmod +x /opt/geth
  
ENTRYPOINT ["/opt/geth"]


