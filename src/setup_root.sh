#!/usr/bin/env bash


        ################################################################################
        # 1. 4 steps
        ################################################################################
        outdir=$(pwd)
        ossl="docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"

        #https://evilshit.wordpress.com/2013/06/19/how-to-create-your-own-pki-with-openssl/

        #rand
        $ossl rand -out RootCA/private/.rootca.rand 8192

        #create key
        # NB: had to remove options
        $ossl genrsa -out RootCA/private/rootca.key -rand RootCA/private/.rootca.rand

echo 1.1
        #   ss root cert
        #export ALTNAME="DNS:www.example.com, DNS:www2.example.com"
        #args=" -e ALTNAME='DNS:www.example.com, DNS:www2.example.com' "
        cat openssl.cnf | sed 's#$ENV::ALTNAME#DNS:www.example.com, DNS:www2.example.com#1' \
                        | sed 's#$ENV::HOME/.rnd#RootCA/private/.rootca.rand#1' >tmp.cfg
        $ossl req -new -x509 -days 3650 -key RootCA/private/rootca.key -out RootCA/rootca.crt -config tmp.cfg  \
            -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"  

echo 1.2           
        $ossl x509 -text -in RootCA/rootca.crt > RootCA/rootca_crt.txt   

echo rooty done