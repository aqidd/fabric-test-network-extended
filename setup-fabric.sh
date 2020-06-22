#!/bin/bash

# remove existing setup
docker stop $(docker ps -aq)
docker system prune -af --volumes

cd ..
sudo rm -rf fabric-samples

# install latest fabric and docker containers
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.1.0 1.4.7 0.4.18

# set bin path
cd fabric-samples
cd test-network

export PATH=~/fabric-samples/bin:$PATH
export FABRIC_CFG_PATH=~/fabric-samples/config

./network.sh up
./network.sh createChannel -c mychannel
./network.sh deployCC -l javascript