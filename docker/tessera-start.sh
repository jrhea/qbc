#!/bin/bash
cd /opt
java $JAVA_OPTS -jar tessera-app.jar -configfile /var/cdata/tessera-config.json \
  --jdbc.url jdbc:h2:/var/cdata/data \
  --peer.url $OTHER_NODES \
  --unixSocketFile /var/qdata/tm.ipc \
  --server.port 9000 \
  --server.hostName $URL \
  --server.bindingAddress 0.0.0.0 \
  --keys.keyData.privateKeyPath /var/cdata/tm.key \
  --keys.keyData.publicKeyPath /var/cdata/tm.pub \
    >> /var/cdata/logs/tessera.log 2>&1
