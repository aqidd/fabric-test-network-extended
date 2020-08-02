#!/bin/bash
# report_name=`date +"%Y-%m-%d-%T-report.html"`

npx caliper launch master --caliper-bind-sut fabric:2.1.0 --caliper-workspace caliper/ --caliper-benchconfig benchmarks/fabcar/config.yaml --caliper-networkconfig fabric-go-tls.yaml --caliper-flow-only-test --caliper-fabric-gateway-usegateway 
# --caliper-report-path $report_name 

# discovery has a bug in 0.3.2 (PR #853 caliper)
# --caliper-fabric-gateway-gatewaylocalhost --caliper-fabric-gateway-discovery 
