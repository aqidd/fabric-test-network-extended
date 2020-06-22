#!/bin/bash

# first argument is orderer id, second argument is channel name
if [ -z "$2" ]; then
    echo "please specify channel name" 
fi

. envVar.sh

setOrdererGlobals $1

peer channel fetch config config_block.pb -o $ORDERER_ADDRESS -c $2 --tls --cafile $TLS_ROOT_CA

configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json

jq .data.data[0].payload.data.config config_block.json > config.json

cp config.json modified_config.json

setOrdererGlobals $1
echo "{\"client_tls_cert\":\"$(cat $ORDERER_TLS | base64 -w 0)\",\"host\":\"orderer$1.example.com\",\"port\":7$150,\"server_tls_cert\":\"$(cat $ORDERER_TLS | base64 -w 0)\"}" > $PWD/ord$1consenter.json

jq ".channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters += [$(cat ord$1consenter.json)]" config.json > modified_config.json

echo "calculating config differences"
configtxlator proto_encode --input config.json --type common.Config --output config.pb

configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

configtxlator compute_update --channel_id $2 --original config.pb --updated modified_config.pb --output config_update.pb

echo "applying changes"
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"'$2'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json

configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

echo "submit update transaction"
peer channel update -f config_update_in_envelope.pb -c $2 -o $ORDERER_ADDRESS --tls --cafile $TLS_ROOT_CA
