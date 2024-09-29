#!/usr/bin/env bash

#
# PKI Management
#
# Revoke a PKI cert
#  ./pki.sh <pki name> <domain>
#

[ "" == "$1" ] && echo pki name needed && exit 
[ "" == "$1" ] && echo domain needed && exit 

PATH=$PATH:`pwd`
export SUBJECT="/C=GB/O=Our Research Group/OU=IT Department"
export CONFIG="`pwd`/openssl.cnf"

[ ! -d "deploy/${1}" ] && echo missing deploy/${1} && exit 

pushd deploy/${1}
    revoke_cert.sh ${2}
popd 

