#!/bin/bash

# remove existing samples folder (if any)
cd ${FABRIC_SAMPLES_DIR}
cd ..
sudo rm -rf fabric-samples

# install latest fabric and docker containers
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.1.0 1.4.7 0.4.18

# set bin path
export $(egrep -v '^#' .env | xargs)

export PATH=${FABRIC_SAMPLES_DIR}/bin:$PATH
export FABRIC_CFG_PATH=${FABRIC_SAMPLES_DIR}/config

cd ${FABRIC_SAMPLES_DIR}
cd test-network

./network.sh up
./network.sh createChannel -c mychannel
./network.sh deployCC -l javascript

cd ${TEST_NETWORK_EXTENDED_DIR}
./extend-network.sh