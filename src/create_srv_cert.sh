#!/usr/bin/env bash

    ################################################################################
    #
    ################################################################################
    echo "3. Create a server certificate (signed by the sub ca):"

        ################################################################################
        #
        ################################################################################
        outdir=$(pwd)
        ossl="docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"

        mkdir -p -m 777 server/private/ server/certs/

        # rand
        $ossl rand -out server/.randServer 8192
        echo 3.1

        #-aes256 removed to avoid passphrase promtpt
        $ossl genrsa -out server/private/server.key  -rand server/.randServer 2048
        echo 3.2

        #The next step is to create the CSR. But make sure that you enter the domain name 
        # the server as common Name (in this example: commonName=www.example.com).
        $ossl req -new -key server/private/server.key -out server/server.csr -config tmp.cfg \
            -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com" 

echo 3.3

#Now we can sign the server CSR:
       touch ./SubCA/index.txt
       echo '01' > ./SubCA/serial
     
        $ossl ca -batch -name CA_SubCA -in server/server.csr -out server/certs/server.crt  -extensions server_cert -config tmp.cfg
        echo 13