#!/bin/bash
TMCONF=/var/qdata/tm.conf
LD_LIBRARY_PATH=/opt/constellation-v0.3.2-linux-64/bin/ /opt/constellation-node $TMCONF --verbosity=4 >> /var/cdata/logs/constellation.log 2>&1