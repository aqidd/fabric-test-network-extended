# collection of bash functions
export $(egrep -v '^#' .env | xargs)

export PATH=${FABRIC_SAMPLES_DIR}/bin:$PATH
export FABRIC_CFG_PATH=${FABRIC_SAMPLES_DIR}/config

# orderer CA root
export ORDERER_CA=${FABRIC_SAMPLES_DIR}/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export TLS_ROOT_CA=${FABRIC_SAMPLES_DIR}/test-network/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem
# defaut orderer address
export ORDERER_CONTAINER=orderer.example.com
export ORDERER_ADDRESS=localhost:7050

# set environment variables for peers
# ORG is param 1, PEER is param 2
function setPeerEnv {
    if [ $1 == 1 ]; then
        PEER_ADDRESS=7$251
    elif [ $1 == 2 ]; then
        PEER_ADDRESS=9$251
    fi

    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org"$1"MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${FABRIC_SAMPLES_DIR}/test-network/organizations/peerOrganizations/org$1.example.com/peers/peer$2.org$1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${FABRIC_SAMPLES_DIR}/test-network/organizations/peerOrganizations/org$1.example.com/users/Admin@org$1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:$PEER_ADDRESS
    export PEER$2_ORG$1_CA=${FABRIC_SAMPLES_DIR}/test-network/organizations/peerOrganizations/org$1.example.com/peers/peer$2.org$1.example.com/tls/ca.crt
}

# Set OrdererOrg.Admin globals
function setOrdererGlobals {
  # workaround for the default settings orderer.example.com
  ORDERER=''
  if [ $1 -gt 0 ]; then
    ORDERER=$1
  fi

  export CORE_PEER_LOCALMSPID="OrdererMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${FABRIC_SAMPLES_DIR}/test-network/organizations/ordererOrganizations/example.com/orderers/orderer${ORDERER}.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  export CORE_PEER_MSPCONFIGPATH=${FABRIC_SAMPLES_DIR}/test-network/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp
  export ORDERER_TLS=${FABRIC_SAMPLES_DIR}/test-network/organizations/ordererOrganizations/example.com/orderers/orderer${ORDERER}.example.com/tls/server.crt
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
function parsePeerConnectionParameters {
  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    _org=`echo $1 | cut -d\: -f1`
    _peer=`echo $1 | cut -d\: -f2`
    setPeerEnv $_org $_peer
    PEER="peer$_peer.org${_org}"
    ## Set peer adresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER${_peer}_ORG${_org}_CA")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}
