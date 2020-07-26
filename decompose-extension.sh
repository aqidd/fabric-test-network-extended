#!/bin/bash

docker-compose -f ${TEST_NETWORK_EXTENDED_DIR}/network/docker-compose-extended.yaml down --volumes --remove-orphans
