#!/bin/bash
TMCONF=/var/qdata/tm.conf
LD_LIBRARY_PATH=/opt/constellation-latest/bin/ /opt/constellation-node $TMCONF --verbosity=4 >> /var/cdata/logs/constellation.log 2>&1