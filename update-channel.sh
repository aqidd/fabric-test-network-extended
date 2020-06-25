#!/bin/bash

# first argument is orderer id, second argument is channel name
if [ -z "$2" ]; then
    echo "please specify channel name" 
fi

. envVar.sh

setOrdererGlobals $1

peer channel fetch config ./out/config_block.pb -o $ORDERER_ADDRESS -c $2 --tls --cafile $TLS_ROOT_CA

configtxlator proto_decode --input ./out/config_block.pb --type common.Block --output ./out/config_block.json

jq .data.data[0].payload.data.config ./out/config_block.json > ./out/config.json

cp ./out/config.json ./out/modified_config.json

setOrdererGlobals $1
echo "{\"client_tls_cert\":\"$(cat $ORDERER_TLS | base64 -w 0)\",\"host\":\"orderer$1.example.com\",\"port\":7$150,\"server_tls_cert\":\"$(cat $ORDERER_TLS | base64 -w 0)\"}" > $PWD/out/ord$1consenter.json

jq ".channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters += [$(cat ./out/ord$1consenter.json)]" ./out/config.json > ./out/modified_config.json

echo "calculating config differences"
configtxlator proto_encode --input ./out/config.json --type common.Config --output ./out/config.pb

configtxlator proto_encode --input ./out/modified_config.json --type common.Config --output ./out/modified_config.pb

configtxlator compute_update --channel_id $2 --original ./out/config.pb --updated ./out/modified_config.pb --output ./out/config_update.pb

echo "applying changes"
configtxlator proto_decode --input ./out/config_update.pb --type common.ConfigUpdate --output ./out/config_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"'$2'", "type":2}},"data":{"config_update":'$(cat ./out/config_update.json)'}}}' | jq . > ./out/config_update_in_envelope.json

configtxlator proto_encode --input ./out/config_update_in_envelope.json --type common.Envelope --output ./out/config_update_in_envelope.pb

echo "submit update transaction"
peer channel update -f ./out/config_update_in_envelope.pb -c $2 -o $ORDERER_ADDRESS --tls --cafile $TLS_ROOT_CA
