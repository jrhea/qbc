FROM ubuntu:16.04
ARG osarch
ARG version
COPY constellation-${version}-${osarch}.tar.gz /tmp/

RUN cd /opt \
  && tar xzf /tmp/constellation-${version}-${osarch}.tar.gz \
  && rm /tmp/constellation-${version}-${osarch}.tar.gz \
  && chmod +x /opt/constellation-node

COPY constellation-start.sh /opt/constellation-start.sh

RUN chmod +x /opt/constellation-start.sh

CMD ["/opt/constellation-start.sh"]

