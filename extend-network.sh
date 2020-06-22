#!/bin/bash

# import utils
. envVar.sh

./compose-peers-orderers.sh

# wait for everything to settle
sleep 3

./join-channel.sh

# install fabcar chaincode
cd /home/aqid/test-network-extended

# deploy to channel / language / version 
./deployCC.sh mychannel golang 2