#!/usr/bin/env bash

    ################################################################################
    # CERT REVOCATION LIST
    #
    # $1 - PKI Name
    #
    # Create a cert revocation list
    # 
    ################################################################################
    BASE="SubCA"
    ROOT="RootCA"

    if [ -e "${BASE}/crl/crl.pem" ] ; then 
        echo "PKI ${1} CRL already initialised."
        exit 0 
    else
        echo "Create cert revocation list"
    fi 

    outdir=$(pwd)
    ossl="docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"
    mkdir -p -m 777 ${BASE}/crl/
    echo '01' > ${BASE}/crlnumber
    $ossl ca -rand_serial -name CA_SubCA -gencrl -out ${BASE}/crl/crl.pem -config pki.cfg
