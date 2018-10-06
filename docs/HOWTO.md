# Setting up your own Quorum network

## Set up the Quorum node network

### Generate Enode and nodekey

Each node in the network is identified by a unique id assigned to it called the enode.  This enode is the public key corresponding to a private nodekey.


Generate public enode from the private nodekey:

```
nodekey=`docker run -v <PATH TO DATA FOLDER>:/var/qdata/ consensys/quorum:latest sh -c "/opt/bootnode -genkey /var/qdata/dd/nodekey -writeaddress;cat /var/qdata/dd/nodekey"`;
enode=`docker run -v <PATH TO DATA FOLDER>:/var/qdata/ consensys/quorum:latest sh -c "/opt/bootnode -nodekeyhex $nodekey -writeaddress"`;
```

Only nodes who's enodes are listed in the static-nodes.json file can participate in the consensus mechanism.

Here is an example of how to generate a static-nodes.json file:

```
ips=("10.5.0.15" "10.5.0.16" "10.5.0.17" "10.5.0.18")
i=1
mkdir -p $WORKDIR/q1/dd/
echo "[" > $WORKDIR/q1/dd/static-nodes.json;
for ip in ${ips[*]}; do
    mkdir -p $WORKDIR/q${i}/logs;
    mkdir -p $WORKDIR/q${i}/dd/{keystore,geth};
    enode=`docker run -v $WORKDIR/q${i}:/var/qdata/ consensys/quorum:latest sh -c "/opt/bootnode -genkey /var/qdata/dd/nodekey -writeaddress; cat /var/qdata/dd/nodekey"`;
    enode=`docker run -v $WORKDIR/q${i}:/var/qdata/ consensys/quorum:latest sh -c "/opt/bootnode -nodekeyhex $enode -writeaddress"`;
    sep=`[[ $i < ${#ips[@]} ]] && echo ","`;
    echo '  "enode://'$enode'@'$ip':21000?discport=0"'$sep >> $WORKDIR/q1/dd/static-nodes.json;
    let i++;
done
echo "]" >> $WORKDIR/q1/dd/static-nodes.json

```

The output should look something like this:

```
$ cat $WORKDIR/q1/dd/static-nodes.json
[
  "enode://07f75277b1bb17329d91dde84d2e4d2d01d67b50a8e6974fbc19602edd3a832b@10.5.0.15:21000?discport=0",
  "enode://48ef4d4bdcb04db9bb0095dde90ed49abb4be995b6c673e8e2715e3c0cb34614@10.5.0.16:21000?discport=0",
  "enode://bf94844598cbfe955952076ba046ed143fec160968eed12d3fa93256c6e7a8b0@10.5.0.17:21000?discport=0",
  "enode://14d2b9dc41c34638bf736cd84d43b30e733d94a98e60190ee760c6b73548c26c@10.5.0.18:21000?discport=0"
]

```

Passwords file

### Create a genesis file

All nodes should have in common the first block (the genesis block) and a set of common parameters to operate the network.

An example of genesis JSON file is in this repository under `tests/crux_quorum/istanbul-genesis.json`.

The JSON file is ingested by the geth init command to initialize the first block.

`docker run -it -v <PATH TO DATA FOLDER>:/var/qdata/ -v <PATH TO JSON FILE>:/tmp/genesis.json \
	  consensys/quorum:latest /opt/geth --datadir /var/qdata/dd init /tmp/genesis.json`

### Create a list of static and permissioned nodes

As you create the Quorum network, you will need to organize your nodes so they can connect to each other.

You can use two separate files to organize the network:

`static-nodes.json`: this file contains the list of nodes this Quorum instance will connect to.

`permissioned-nodes.json`:  nodes listed in this file are explicitly allowed to send data to the Quorum instance.

Both files have the same format. Here is an example.

```
["enode://abcde....1234@10.5.0.11:21000?discport=0, "enode://abcdde...6543@10.5.0.12:21000?discport=0]
```

Each enode URI is built with the public key of the node, associated with its host name and RPC port. The discport parameter is set to zero as no discovery is performed on the network.

### Quorum. data folder structure

Create the folders as follows:

`mkdir -p dd/keystore logs`

Copy the files created earlier so it conforms to the structure below:

```
├── dd
│   ├── keystore
│   │   └── key
│   ├── permissioned-nodes.json
│   └── static-nodes.json
├── logs
│   └── node.log
├── nodekey
└── passwords.txt
```

## Set up Tessera or Crux nodes

### Generate Constellation keys

For each Constellation instance, you will need a unique keypair.

This command generates a keypair under /tmp/out.key and /tmp/out.pub.

`docker run -v /tmp:/tmp -it consensys/crux:latest /opt/crux --generate-keys /tmp/out`

### Constellation data folder structure

Create the logs folder: `mkdir -p logs`

Copy the files created earlier so it conforms to the structure below. Make sure to rename the keypair to tm.key and tm.pub respectively.

```
├── logs
│   └── crux.log
├── tm.key
└── tm.pub
```

# Running the Quorum network

## Running Docker

On each node participating in the network, you will need to run Quorum and Constellation (either Crux or Tessera).

Assuming you followed the instructions above, you should have a data folder for Quorum and Constellation respectively.

You can then start Crux with:

`env HOSTNAME=<hostname of the crux node> OTHER_NODES=http://<hostname of an other crux node to discover> docker run -p 9000:9000 -v <path to constellation data>:/var/cdata/ <path to quorum data>:/var/qdata/ -it consensys/crux:latest`

You can start Quorum with:

`docker run -p 22000:22000 -p 21000:21000 -v <path to quorum data>:/var/qdata/ consensys/quorum:latest`

You can also use a docker compose yaml configuration file to run both containers together:

```
version: "3.4"
services:
  crux:
    image: consensys/crux:latest
    container_name: crux
    ports:
      - 9000:9000
    restart: always
    environment:
      - HOSTNAME=<hostname of the crux node>
      - OTHER_NODES=<hostname of an other crux node to discover>
    volumes:
      - ${WORKDIR}/c1:/var/cdata/
      - ${WORKDIR}/q1:/var/qdata/
  node:
    image: consensys/quorum:latest
    container_name: quorum
    ports:
      - 22000:22000
      - 21000:21000
    restart: always
    volumes:
      - ${WORKDIR}/q1:/var/qdata/

```

## Check the network is up and running.

On the node, perform the following to check Constellation is up and running:

`curl -vv http://localhost:19001/upcheck`

Check the quorum logs to check the node came up without issues.

`less <path to quorum data>/logs/node.log`

## Troubleshooting

Open a shell to a container:

```
docker exec -it <container_name> /bin/bash
```

Node Info
```
curl -X POST --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","id":1}' 0.0.0.0:22001
```

Get list of connected peers
```
curl -X POST --data '{"jsonrpc":"2.0","method":"admin_peers","id":1}' 0.0.0.0:22001
```

Get blocknumber
```
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' 0.0.0.0:22001
```

