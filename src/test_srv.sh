#!/usr/bin/env bash

[ "" == "$1" ]&& echo no pki provided && exit 0
[ "" == "$2" ]&& echo no domain provided && exit 0

pki="$1"
domain="$2"
dir="./deploy/${pki}/${domain}"
if [ ! -d "${dir}" ] ; then 
        echo "${dir} missing"
        exit 0 
fi 

################################################################################
#
################################################################################
outdir=$(pwd)
ossl="docker run --network=ossl_test -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"
osslweb="docker run -d --network=ossl_test --name ossl_websrv -p 44330:44330 -ti -v ${outdir}:/apps -w /apps alpine/openssl"
path="./deploy/${pki}/${domain}"

docker network create ossl_test
docker container rm -f ossl_websrv
echo $osslweb s_server -key ${path}/private/server.key -cert ${path}/certs/server.crt -accept 44330 -www
#$osslweb s_server -key ${path}/private/server.key -cert ${path}/certs/server.crt -accept 44330 -www -tls1_3

#test full-chain
$osslweb s_server -key ${path}/private/server.key -cert ${path}/certs/server.crt -CAfile ${path}/certs/full-chain.pem -accept 44330 -www -tls1_3
echo Server runnning

# echo "test hostname"
# ${ossl} s_client -connect  ossl_websrv:44330 -verify_hostname ${domain} -servername ${domain}

echo "Test tls"
#${ossl} s_client -CApath ./deploy/${pki}/RootCA/private/  -connect ossl_websrv:44330
${ossl} s_client -CApath ${path}/certs/  -connect ossl_websrv:44330

