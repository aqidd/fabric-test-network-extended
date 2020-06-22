#!/bin/bash
# import utils
. envVar.sh

# set bin path
cd ${FABRIC_SAMPLES_DIR}/test-network

cryptogen extend --config=/home/aqid/test-network-extended/crypto-config.yaml --input="organizations"

cd /home/aqid/test-network-extended
# create orderer 1
./update-channel.sh 1 system-channel
cd ${FABRIC_SAMPLES_DIR}/test-network

docker-compose -f /home/aqid/test-network-extended/docker-compose-extended.yaml up -d orderer1.example.com

cd /home/aqid/test-network-extended
# compose orderer 2
./update-channel.sh 2 system-channel
cd ${FABRIC_SAMPLES_DIR}/test-network

docker-compose -f /home/aqid/test-network-extended/docker-compose-extended.yaml up -d orderer2.example.com

sleep 2

# compose peers
docker-compose -f /home/aqid/test-network-extended/docker-compose-extended.yaml up -d