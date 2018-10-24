FROM ubuntu:16.04
ARG osarch
ARG version
COPY crux-${version}-${osarch}.tar.gz /tmp/

RUN cd /opt \
    && tar xzf /tmp/crux-${version}-${osarch}.tar.gz \
    && rm /tmp/crux-${version}-${osarch}.tar.gz \
    && chmod +x /opt/crux

COPY crux-start.sh /opt/crux-start.sh

RUN chmod +x /opt/crux-start.sh

CMD ["/opt/crux-start.sh"]

