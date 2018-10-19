#!/bin/bash

# Wait for the socket to Constellation to be available
while [ ! -S "/var/qdata/tm.ipc" ]; do
   sleep 0.1
done

TMCONF=/var/qdata/tm.conf
GETH_ARGS="--syncmode full --mine --port 21000 --rpc --rpcport 22000 --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --nodiscover --datadir /var/qdata/dd --nodekey /var/qdata/nodekey --unlock 0 --password /var/qdata/passwords.txt"
PRIVATE_CONFIG=$TMCONF /opt/geth $GETH_ARGS --verbosity=6 2>>/var/qdata/logs/node.log
