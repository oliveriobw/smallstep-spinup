#!/usr/bin/env bash

        [ "" == "$1" ]&& echo no ${domain} cert provided && exit 0
        domain="$1"

        ################################################################################
        # SERVER CERTS
        ################################################################################
        echo "3. Create a ${domain} certificate (signed by the sub ca) for $domain:"

        ################################################################################
        #
        ################################################################################
        outdir=$(pwd)
        ossl="docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"
        osslweb="docker run -d --name websrv -p 44330:44330 -ti -v ${outdir}:/apps -w /apps alpine/openssl"

        mkdir -p -m 777 ${domain}/private/ ${domain}/certs/

        # rand
        $ossl rand -out ${domain}/.randServer 8192
        echo 3.1

        #-aes256 removed to avoid passphrase promtpt
        $ossl genrsa -out ${domain}/private/server.key  -rand ${domain}/.randServer 2048
        echo 3.2

        #The next step is to create the CSR. But make sure that you enter the domain name 
        # the server as common Name (in this example: commonName=www.example.com).
        $ossl req -new -key ${domain}/private/server.key -out ${domain}/server.csr -config pki.cfg \
                -subj "${SUBJECT}/CN=${domain}" 

        echo 3.3

        #Now we can sign the server CSR:
        touch ./SubCA/index.txt
        # lastSerialNumber=`cat ./SubCA/serial`
        # echo last=${lastSerialNumber}
        # lastSerialNumber=$((lastSerialNumber + 1))
        # echo last=${lastSerialNumber}
        # echo '$lastSerialNumber' > ./SubCA/serial

        $ossl ca -rand_serial -batch -name CA_SubCA -in ${domain}/server.csr -out ${domain}/certs/server.crt  -extensions server_cert -config pki.cfg
        echo 3.4

        #create pfx
        create_pkcs12.sh ${domain}/certs/server.crt ${domain}/private/server.key ${domain}/certs/server.pfx 

        #version 3 certificate der
        $ossl x509 -outform der -in ${domain}/certs/server.crt -out ${domain}/certs/server.der

        echo 3.5
        # full-chain 
        create_chain.sh ${domain}

        # verifies the SubCA cert 
        echo verify SubCA cert
        ${ossl} verify -CAfile ${domain}/certs/full-chain.pem ./SubCA/subca.crt 

        # verifies the Server cert
        echo Verify server cert
        ${ossl} verify -CAfile ${domain}/certs/full-chain.pem ${domain}/certs/server.crt

