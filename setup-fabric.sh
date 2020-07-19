#!/bin/bash

# remove existing setup
docker stop $(docker ps -aq)
docker system prune -af --volumes

sudo rm -rf fabric-samples

# install latest fabric and docker containers
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.1.0 1.4.7 0.4.18

# set bin path
cd fabric-samples
cd test-network

export $(egrep -v '^#' .env | xargs)

export PATH=${FABRIC_SAMPLES_DIR}/bin:$PATH
export FABRIC_CFG_PATH=${FABRIC_SAMPLES_DIR}/config

./network.sh up
./network.sh createChannel -c mychannel
./network.sh deployCC -l javascript