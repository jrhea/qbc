FROM ubuntu:16.04

COPY build/constellation-*-linux-386.tar.gz /tmp/constellation.tar.gz

RUN cd /opt && \
  tar xzf /tmp/constellation.tar.gz && \
  rm /tmp/constellation.tar.gz && \
  chmod +x /opt/constellation-node

COPY docker/constellation-start.sh /opt/constellation-start.sh

RUN chmod +x /opt/constellation-start.sh

CMD ["/opt/constellation-start.sh"]

