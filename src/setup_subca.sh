#!/usr/bin/env bash

    ################################################################################
    # INTERMEDIATE CERT
    #
    # $1 - PKI Name
    #
    # Create a sub ca certificate (signed by the root ca)
    # 2. 4 steps
    ################################################################################
    BASE="SubCA"
    ROOT="RootCA"

    if [ -d "${BASE}" ] ; then 
        echo "PKI ${1} intermediate already initialised."
        exit 0 
    fi 

    outdir=$(pwd)
    ossl="docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"
    mkdir -p -m 777 ${BASE}/private/  ${BASE}/certs/ ${BASE}/newcerts/

    echo "Create a sub ca certificate (signed by the root ca):"
    # intermediate : rand ; key; csr ; sign csr ; 
    echo rand seed
    $ossl rand -out ${BASE}/.randSubCA 8192
    echo 2.1

    # new pvt key
    #-aes256 removed to prevent password promt
    $ossl genrsa -out ${BASE}/private/subca.key -rand ${BASE}/.randSubCA 2048

    echo 2.2
    echo Now we can create the CSR:
    $ossl req -new -key ${BASE}/private/subca.key -out ${BASE}/subca.csr -config pki.cfg  \
            -subj "${SUBJECT}/CN=$1 Intermediate X1" 


    echo 2.3
    echo The CSR can now be signed by the Root CA:
    mkdir ${ROOT}/newcerts/
    mkdir -m 777 ${ROOT}/certs/
    touch ./${ROOT}/index.txt
    echo '01' > ./${ROOT}/serial

    # batch avoids sign prompt
    $ossl ca -batch -name CA_RootCA -in ${BASE}/subca.csr -out ${BASE}/subca.crt -extensions subca_cert -config pki.cfg \
            -subj "${SUBJECT}/CN=$1 Intermediate X1" 
    create_pkcs12.sh ${BASE}/subca.crt ${BASE}/private/subca.key ${BASE}/subca.pfx 

    #mv subca.crt ./${BASE}/certs/

  
