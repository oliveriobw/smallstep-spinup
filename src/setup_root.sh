#!/usr/bin/env bash

    ################################################################################
    # ROOT CERT
    #
    # $1 - PKI Name
    #
    # 1. 4 steps
    ################################################################################
    BASE="RootCA"

    if [ -d "${BASE}" ] ; then 
        echo "PKI ${1} already initialised."
        exit 0 
    fi 

    mkdir -p -m 777 ${BASE}/private
    outdir=$(pwd)
    ossl="docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"

    #rand
    $ossl rand -out ${BASE}/private/.rootca.rand 8192

    #create key
    # NB: had to remove options
    $ossl genrsa -out ${BASE}/private/rootca.key -rand ${BASE}/private/.rootca.rand

    echo 1.1
    #   ss root cert
    #export ALTNAME="DNS:www.example.com, DNS:www2.example.com"
    #args=" -e ALTNAME='DNS:www.example.com, DNS:www2.example.com' "
    ls -la $CONFIG
    cat ${CONFIG} | sed 's|$ENV::ALTNAME|DNS:www.our-team.co.uk, DNS:www.our-it.co.uk|1' \
                       | sed "s|\$ENV::HOME/.rnd|${BASE}/private/.rootca.rand|1" >pki.cfg

    $ossl req -new -x509 -days 3650 -key ${BASE}/private/rootca.key -out ${BASE}/rootca.crt -config pki.cfg  \
        -subj "${SUBJECT}/CN=${1} Root X1"  

    echo 1.2           
    $ossl x509 -text -in ${BASE}/rootca.crt > ${BASE}/rootca_crt.txt   
    create_pkcs12.sh ${BASE}/rootca.crt ${BASE}/private/rootca.key ${BASE}/rootca.pfx

