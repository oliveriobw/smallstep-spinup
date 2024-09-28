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

        # $1 - crt [IN]
        # $2 - pvt key [IN]
        # $3 - pfx [OUT]
        create_pkcs12.sh ${domain}/certs/server.crt ${domain}/private/server.key ${domain}/certs/server.pfx 

        # echo "run dummy server on port 44330 to test tls"
        # docker network 
        # $osslweb s_server -key ${domain}/private/server.key -cert ${domain}/certs/${domain}.crt -accept 44330 -www

        # echo "testing"
        # ${ossl} s_client -connect localhost:44330

        # echo kill 
        # read n
        # docker kill websrv