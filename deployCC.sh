#!/bin/bash
# https://hyperledger-fabric.readthedocs.io/en/release-2.0/chaincode_lifecycle.html

CHANNEL_NAME="$1"
CC_SRC_LANGUAGE="$2"
VERSION="$3"
DELAY="$4"
MAX_RETRY="$5"
VERBOSE="$6"
: ${CHANNEL_NAME:="mychannel"}
: ${CC_SRC_LANGUAGE:="golang"}
: ${VERSION:="1"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}
CC_SRC_LANGUAGE=`echo "$CC_SRC_LANGUAGE" | tr [:upper:] [:lower:]`

FABRIC_CFG_PATH=${FABRIC_SAMPLES_DIR}/config/

if [ "$CC_SRC_LANGUAGE" = "go" -o "$CC_SRC_LANGUAGE" = "golang" ] ; then
	CC_RUNTIME_LANGUAGE=golang
	CC_SRC_PATH="${FABRIC_SAMPLES_DIR}/chaincode/fabcar/go/"

	echo Vendoring Go dependencies ...
	pushd ${FABRIC_SAMPLES_DIR}/chaincode/fabcar/go
	GO111MODULE=on go mod vendor
	popd
	echo Finished vendoring Go dependencies

elif [ "$CC_SRC_LANGUAGE" = "javascript" ]; then
	CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
	CC_SRC_PATH="${FABRIC_SAMPLES_DIR}/chaincode/fabcar/javascript/"

elif [ "$CC_SRC_LANGUAGE" = "java" ]; then
	CC_RUNTIME_LANGUAGE=java
	CC_SRC_PATH="${FABRIC_SAMPLES_DIR}/chaincode/fabcar/java/build/install/fabcar"

	echo Compiling Java code ...
	pushd ${FABRIC_SAMPLES_DIR}/chaincode/fabcar/java
	./gradlew installDist
	popd
	echo Finished compiling Java code

elif [ "$CC_SRC_LANGUAGE" = "typescript" ]; then
	CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
	CC_SRC_PATH="${FABRIC_SAMPLES_DIR}/chaincode/fabcar/typescript/"

	echo Compiling TypeScript code into JavaScript ...
	pushd ${FABRIC_SAMPLES_DIR}/chaincode/fabcar/typescript
	npm install
	npm run build
	popd
	echo Finished compiling TypeScript code into JavaScript

else
	echo The chaincode language ${CC_SRC_LANGUAGE} is not supported by this script
	echo Supported chaincode languages are: go, java, javascript, and typescript
	exit 1
fi

# import utils
. envVar.sh


packageChaincode() {
  ORG=$1
  PEER=$2
  setPeerEnv $ORG $PEER
  set -x
  peer lifecycle chaincode package out/fabcar.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label fabcar_${VERSION} >&out/log.txt
  res=$?
  set +x
  cat out/log.txt
  verifyResult $res "Chaincode packaging on peer${PEER}.org${ORG} has failed"
  echo "===================== Chaincode is packaged on peer${PEER}.org${ORG} ===================== "
  echo
}

# installChaincode PEER ORG
installChaincode() {
  ORG=$1
  PEER=$2
  setPeerEnv $ORG $PEER
  set -x
  peer lifecycle chaincode install out/fabcar.tar.gz >&out/log.txt
  res=$?
  set +x
  cat out/log.txt
  verifyResult $res "Chaincode installation on peer${PEER}.org${ORG} has failed"
  echo "===================== Chaincode is installed on peer${PEER}.org${ORG} ===================== "
  echo
}

# queryInstalled PEER ORG
queryInstalled() {
  ORG=$1
  PEER=$2
  setPeerEnv $ORG $PEER
  set -x
  peer lifecycle chaincode queryinstalled >&out/log.txt
  res=$?
  set +x
  cat out/log.txt
	PACKAGE_ID=$(sed -n "/fabcar_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" out/log.txt)
  verifyResult $res "Query installed on peer${PEER}.org${ORG} has failed"
  echo PackageID is ${PACKAGE_ID}
  echo "===================== Query installed successful on peer${PEER}.org${ORG} on channel ===================== "
  echo
}

# approveForMyOrg VERSION PEER ORG
approveForMyOrg() {
  ORG=$1
  PEER=$2
  setPeerEnv $ORG $PEER
  set -x
  peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name fabcar --version ${VERSION} --init-required --package-id ${PACKAGE_ID} --sequence ${VERSION} >&out/log.txt
  set +x
  cat out/log.txt
  verifyResult $res "Chaincode definition approved on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' failed"
  echo "===================== Chaincode definition approved on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
  echo
}

# checkCommitReadiness VERSION PEER ORG
checkCommitReadiness() {
  ORG=$1
  PEER=$2
  shift 2
  setPeerEnv $ORG $PEER
  echo "===================== Checking the commit readiness of the chaincode definition on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME'... ====================="
	local rc=1
	local COUNTER=1
	# continue to poll
  # we either get a successful response, or reach MAX RETRY
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    echo "Attempting to check the commit readiness of the chaincode definition on peer${PEER}.org${ORG} secs"
    set -x
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name fabcar --version ${VERSION} --sequence ${VERSION} --output json --init-required >&out/log.txt
    res=$?
    set +x
    let rc=0
    for var in "$@"
    do
      grep "$var" out/log.txt &>/dev/null || let rc=1
    done
		COUNTER=$(expr $COUNTER + 1)
	done
  cat out/log.txt
  if test $rc -eq 0; then
    echo "===================== Checking the commit readiness of the chaincode definition successful on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
  else
    echo "!!!!!!!!!!!!!!! After $MAX_RETRY attempts, Check commit readiness result on peer${PEER}.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

# commitChaincodeDefinition VERSION PEER ORG (PEER ORG)...
commitChaincodeDefinition() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  set -x
  peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name fabcar $PEER_CONN_PARMS --version ${VERSION} --sequence ${VERSION} --init-required >&out/log.txt
  res=$?
  set +x
  cat out/log.txt
  verifyResult $res "Chaincode definition commit failed on peer0.org${ORG} on channel '$CHANNEL_NAME' failed"
  echo "===================== Chaincode definition committed on channel '$CHANNEL_NAME' ===================== "
  echo
}

# queryCommitted ORG
queryCommitted() {
  ORG=$1
  PEER=$2
  setPeerEnv $ORG $PEER
  EXPECTED_RESULT="Version: ${VERSION}, Sequence: ${VERSION}, Endorsement Plugin: escc, Validation Plugin: vscc"
  echo "===================== Querying chaincode definition on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME'... ===================== "
	local rc=1
	local COUNTER=1
	# continue to poll
  # we either get a successful response, or reach MAX RETRY
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    echo "Attempting to Query committed status on peer${PEER}.org${ORG}, Retry after $DELAY seconds."
    set -x
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name fabcar >&out/log.txt
    res=$?
    set +x
		test $res -eq 0 && VALUE=$(cat out/log.txt | grep -o '^Version: [0-9], Sequence: [0-9], Endorsement Plugin: escc, Validation Plugin: vscc')
    test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
		COUNTER=$(expr $COUNTER + 1)
	done
  echo
  cat out/log.txt
  if test $rc -eq 0; then
    echo "===================== Query chaincode definition successful on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
		echo
  else
    echo "!!!!!!!!!!!!!!! After $MAX_RETRY attempts, Query chaincode definition result on peer${PEER}.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

chaincodeInvokeInit() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  set -x
  peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n fabcar $PEER_CONN_PARMS --isInit -c '{"function":"initLedger","Args":[]}' >&out/log.txt
  res=$?
  set +x
  cat out/log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
}

chaincodeQuery() {
  ORG=$1
  PEER=$2
  setPeerEnv $ORG $PEER
  echo "===================== Querying on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME'... ===================== "
	local rc=1
	local COUNTER=1
	# continue to poll
  # we either get a successful response, or reach MAX RETRY
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    echo "Attempting to Query peer${PEER}.org${ORG} ...$(($(date +%s) - starttime)) secs"
    set -x
    peer chaincode query -C $CHANNEL_NAME -n fabcar -c '{"Args":["queryAllCars"]}' >&out/log.txt
    res=$?
    set +x
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
  echo
  cat out/log.txt
  if test $rc -eq 0; then
    echo "===================== Query successful on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
		echo
  else
    echo "!!!!!!!!!!!!!!! After $MAX_RETRY attempts, Query result on peer${PEER}.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

## at first we package the chaincode
packageChaincode 1 0

## Install chaincode on peer
installChaincode 1 0
installChaincode 1 1
installChaincode 1 2
installChaincode 2 0
installChaincode 2 1
installChaincode 2 2

## query whether the chaincode is installed
queryInstalled 1 0
queryInstalled 1 1
queryInstalled 1 2
queryInstalled 2 0
queryInstalled 2 1
queryInstalled 2 2

# majority of channel members need to approve a chaincode before it can used on a channel
# only need to target 1 peer, other will follow via gossip

## approve the definition for org1
approveForMyOrg 1 1

# wait for gossip to settle 
sleep 3

## now approve also for org2
approveForMyOrg 2 1

# wait for gossip to settle
sleep 3

commitChaincodeDefinition 1:0 1:1 1:2 2:0 2:1 2:2

queryCommitted 1 0
queryCommitted 1 1
queryCommitted 1 2
queryCommitted 2 0
queryCommitted 2 1
queryCommitted 2 2

chaincodeInvokeInit 1:0 1:1 1:2 2:0 2:1 2:2

sleep 10

# Query chaincode
chaincodeQuery 1 0
chaincodeQuery 1 1
chaincodeQuery 1 2
chaincodeQuery 2 0
chaincodeQuery 2 1
chaincodeQuery 2 2

exit 0
