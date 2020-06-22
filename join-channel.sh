#!/bin/bash

# import utils
. envVar.sh
cd ${FABRIC_SAMPLES_DIR}/test-network

# join channel
setPeerEnv 1 1
peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block

setPeerEnv 1 2
peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block

setPeerEnv 2 1
peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block

setPeerEnv 2 2
peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block
