#!/usr/bin/env bash

    ################################################################################
    #
    ################################################################################
    outdir=$(pwd)
    ossl="docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"

    echo "Create a sub ca certificate (signed by the root ca):"
    # intermediate : rand ; key; csr ; sign csr ; 
    echo rand seed
    $ossl rand -out .randSubCA 8192
    echo 4
#    read n
    #-aes256 removed to prevent password promt
    $ossl genrsa -out RootCA/private/subca.key -rand .randSubCA 2048


    echo Now we can create the CSR:
    #read n
    $ossl req -new -key RootCA/private/subca.key -out subca.csr -config tmp.cfg  \
            -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com" 


    echo The CSR can now be signed by the Root CA:
    mkdir RootCA/newcerts/
    mkdir -m 777 RootCA/certs/
    touch ./RootCA/index.txt
    echo '01' > ./RootCA/serial
    # bathc avoids sign prompt
    $ossl ca -batch -name CA_RootCA -in subca.csr -out subca.crt -extensions subca_cert -config tmp.cfg \
        -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com" 
    mv subca.crt ./RootCA/certs/


