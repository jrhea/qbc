#!/bin/bash

LD_LIBRARY_PATH=/opt/constellation-v0.3.2-linux-amd64/bin/ /opt/constellation-node --url=http://$HOSTNAME:9000/ \
--port=9000 \
--workdir=/var/cdata/ \
--socket=../qdata/tm.ipc \
--publickeys=tm.pub \
--privatekeys=tm.key \
--othernodes=$OTHER_NODES \
--verbosity=4 >> /var/cdata/logs/constellation.log 2>&1