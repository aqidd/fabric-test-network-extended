#!/bin/bash

. envVar.sh

npm install @hyperledger/caliper-cli@0.3.2

sed -i "s/\${.*}/${FABRIC_SAMPLES_DIR}/g" caliper/fabric-go-tls.yaml 

npx caliper launch master --caliper-bind-sut fabric:2.1.0 --caliper-workspace caliper/ --caliper-benchconfig benchmarks/fabcar/config.yaml --caliper-networkconfig fabric-go-tls.yaml --caliper-flow-only-test --caliper-fabric-gateway-usegateway --caliper-fabric-gateway-discovery