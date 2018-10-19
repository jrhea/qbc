#!/bin/bash

# Wait for the socket to Constellation to be available
while [ ! -S "/var/qdata/tm.ipc" ]; do
   sleep 0.1
done

ARGS="--syncmode full --mine --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --nodiscover"
/opt/geth --datadir /var/qdata/dd $ARGS --rpcport 22000 --port 21000 --nodekey /var/qdata/nodekey --unlock 0 --password /var/qdata/passwords.txt --verbosity=6 2>>/var/qdata/logs/node.log
