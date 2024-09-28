#!/usr/bin/env bash

    ################################################################################
    # CERT REVOKE
    #
    # $1 - DOMAIN
    # 
    ################################################################################
    BASE="SubCA"
    ROOT="RootCA"

    if [ -e "${BASE}/crl/crl.pem" ] ; then 
        setup_crl.sh
    else
        echo "Revoking $2"
    fi 

    if [ ! -d "${1}" ] ; then 
        echo "No dir for $1"
        exit 1
    fi 

pwd 
ls
    outdir=$(pwd)
    ossl="docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"
    $ossl ca -name CA_SubCA -revoke ${1}/certs/server.crt -config pki.cfg
