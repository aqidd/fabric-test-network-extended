#!/bin/bash

. envVar.sh

npm install @hyperledger/caliper-cli@0.3.2

sed -i "s|\${.*}|${FABRIC_SAMPLES_DIR}|g" caliper/fabric-go-tls.yaml 