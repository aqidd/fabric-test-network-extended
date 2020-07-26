#!/bin/bash

# import utils
. envVar.sh

./compose-peers-orderers.sh

# wait for everything to settle
sleep 3

./join-channel.sh

# install fabcar chaincode
cd ${TEST_NETWORK_EXTENDED_DIR}

# deploy to channel / language / version 
# no idea why but this is the most stable way to install chaincode
./deployCC.sh mychannel javascript 1
./deployCC.sh mychannel javascript 2