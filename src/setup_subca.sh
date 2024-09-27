#!/usr/bin/env bash

    ################################################################################
    # Create a sub ca certificate (signed by the root ca)
    # 2. 4 steps
    ################################################################################
    outdir=$(pwd)
    ossl="docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"
    mkdir -p -m 777 SubCA/private/  SubCA/certs/ SubCA/newcerts/

    echo "Create a sub ca certificate (signed by the root ca):"
    # intermediate : rand ; key; csr ; sign csr ; 
    echo rand seed
    $ossl rand -out .randSubCA 8192
    echo 2.1

    # new pvt key
    #-aes256 removed to prevent password promt
    $ossl genrsa -out SubCA/private/subca.key -rand .randSubCA 2048

    echo 2.2
    echo Now we can create the CSR:
    $ossl req -new -key SubCA/private/subca.key -out SubCA/subca.csr -config tmp.cfg  \
            -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com" 


    echo 2.3
    echo The CSR can now be signed by the Root CA:
    mkdir RootCA/newcerts/
    mkdir -m 777 RootCA/certs/
    touch ./RootCA/index.txt
    echo '01' > ./RootCA/serial

    # batch avoids sign prompt
    $ossl ca -batch -name CA_RootCA -in SubCA/subca.csr -out SubCA/subca.crt -extensions subca_cert -config tmp.cfg \
        -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com" 
    #mv subca.crt ./SubCA/certs/

  
