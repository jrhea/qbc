FROM ubuntu:16.04

COPY build/crux-*-linux-amd64.tar.gz /tmp/crux.tar.gz

RUN cd /opt && \
  tar xzf /tmp/crux.tar.gz && \
  rm /tmp/crux.tar.gz && \
  chmod +x /opt/crux

COPY docker/crux-start.sh /opt/crux-start.sh

RUN chmod +x /opt/crux-start.sh

CMD ["/opt/crux-start.sh"]

