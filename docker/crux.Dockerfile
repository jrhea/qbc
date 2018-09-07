FROM ubuntu:16.04

COPY build/crux-*-linux-386.tar.gz /tmp/crux.tar.gz

RUN cd /opt && \
  tar xzf /tmp/crux.tar.gz && \
  rm /tmp/crux.tar.gz && \
  chmod +x /opt/crux
  
ENTRYPOINT ["/opt/crux"]


