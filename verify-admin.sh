#!/bin/bash

. envVar.sh

setPeerEnv 1 0

peer channel fetch config ./out/config_block.pb -o $ORDERER_CONTAINER -c $CHANNEL_NAME --tls --cafile $TLS_ROOT_CA

configtxlator proto_decode --input ./out/config_block.pb --type common.Block --output ./out/config_block.json

jq .data.data[0].payload.data.config ./out/config_block.json > ./out/config.json

jq -r .data.data[0].payload.data.config.channel_group.groups.Application.groups.${CORE_PEER_LOCALMSPID}.values.MSP.value.config.root_certs[0] ./out/config_block.json | base64 -d > root.pem

openssl verify -CAfile root.pem ${FABRIC_SAMPLES_DIR}/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem