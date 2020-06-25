#!/bin/bash
# import utils
. envVar.sh

# set bin path
cd ${FABRIC_SAMPLES_DIR}/test-network

cryptogen extend --config=${TEST_NETWORK_EXTENDED_DIR}/crypto-config.yaml --input="organizations"

cd ${TEST_NETWORK_EXTENDED_DIR}
# create orderer 1
./update-channel.sh 1 system-channel
cd ${FABRIC_SAMPLES_DIR}/test-network

docker-compose -f ${TEST_NETWORK_EXTENDED_DIR}/docker-compose-extended.yaml up -d orderer1.example.com

cd ${TEST_NETWORK_EXTENDED_DIR}
# compose orderer 2
./update-channel.sh 2 system-channel
cd ${FABRIC_SAMPLES_DIR}/test-network

docker-compose -f ${TEST_NETWORK_EXTENDED_DIR}/docker-compose-extended.yaml up -d orderer2.example.com

sleep 2

# compose peers
docker-compose -f ${TEST_NETWORK_EXTENDED_DIR}/docker-compose-extended.yaml up -d