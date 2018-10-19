FROM ubuntu:16.04

COPY build/quorum-*-linux-amd64.tar.gz /tmp/quorum.tar.gz

RUN cd /opt && \
  tar xzf /tmp/quorum.tar.gz && \
  rm /tmp/quorum.tar.gz && \
  chmod +x /opt/geth

COPY docker/quorum-start.sh /opt/quorum-start.sh

RUN chmod +x /opt/quorum-start.sh

CMD ["/opt/quorum-start.sh"]