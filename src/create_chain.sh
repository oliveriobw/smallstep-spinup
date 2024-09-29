#!/usr/bin/env bash

    ################################################################################
    # Create Full Chain with Private Key
    # 
    # $1 - domain
    #
    ################################################################################
    domain=${1}
    pki=./
    outdir=$(pwd)
    ossl="docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"

    echo chain
    grep -A 200 "PRIVATE KEY" ${domain}/private/server.key      > ${domain}/certs/full-chain.pem
    grep -A 200 "BEGIN CERTIFICATE" ${domain}/certs/server.crt >> ${domain}/certs/full-chain.pem
    grep -A 200 "BEGIN CERTIFICATE" ${pki}/SubCA/subca.crt     >> ${domain}/certs/full-chain.pem
    grep -A 200 "BEGIN CERTIFICATE" ${pki}/RootCA/rootca.crt   >> ${domain}/certs/full-chain.pem

