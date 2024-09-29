#!/usr/bin/env bash

#
# PKI Management
#
# Create a PKI
#  ./pki.sh <pki name>
#
# Create a PKI domain cert - must be new
#  ./pki.sh <pki name> <domain>
#
# Create user cert with pki
#  ./pki.sh <pki name> <domain> -u
# 
# TBD:
# Not yet configurable:
#   AuthorityInfoAccess  - default
#   crlDistributionPoints - default
#

[ "" == "$1" ] && echo pki name needed && exit 

PATH=$PATH:`pwd`
export SUBJECT="/C=GB/O=_Our Research Group/OU=IT Department"

mkdir -p -m 777 deploy/${1}
export CONFIG="`pwd`/openssl.cnf"
pushd deploy/${1}
    setup_root.sh "$1"
    setup_subca.sh "$1"
    setup_crl.sh "$1"
    create_srv_cert.sh "$2"
popd 
