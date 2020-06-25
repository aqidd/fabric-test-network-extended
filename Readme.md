# Test Network Extended

## What is this
A collection of shell script that helps extending Test Network as well as executing benchmarking using Hyperledger Caliper

## What does it do
It will extend your Test Network to 3 orderer (orderer.example.com, orderer1.example.com, orderer2.example.com) and 3 peers each organization (peer0, peer1, peer2). It will also join those nodes to channel and install the default chaincode (fabcar) to the nodes.

## How to use

### Updating .env
First you have to update .env files and make sure they point to the correct values. The important variables are `CHANNEL_NAME`, `FABRIC_SAMPLES_DIR` (where you clone fabric samples) and `TEST_NETWORK_EXTENDED_DIR` (where you clone this repository)

### Updating envVar.sh
envVar.sh contains helper variables and functions. It should work after you update `.env` file but please check the content of this files to make sure that everything points to the correct path/value

### Running the script
After you setup your test network + create channel + deploy fabcar chaincode, just execute `./extend-network.sh`.

When you want to decompose the extended peers & orderer, simpy execute `./decompose-extension.sh`

### Benchmarking with Hyperledger Caliper
`./setup.caliper.sh` - benchmark result will be inside `caliper` folder.