# Setting up your own Quorum network

## Set up the Quorum node network

### Generate a key pair for each node

TODO

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

`curl -vv http://localhost:9000/upcheck`

Check the quorum logs to check the node came up without issues.

`less <path to quorum data>/logs/node.log`
  

  