#!/usr/bin/env bash

    ################################################################################
    # Create PKCS12
    # 
    # $1 - crt [IN]
    # $2 - pvt key [IN]
    # $3 - pfx [OUT]
    #
    ################################################################################
    outdir=$(pwd)
    ossl="docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"

    # 7. Export a certificate to PKCS#12 format
    # If you want to import a certificate to your browser or your email client you have 
    # to export the certificate to another format. Most of the applications need a 
    # certificate in PKCS#12 format. This format contains the public and private key. 
    # You have to enter a (backup) passphrase for exported certificate, to protect you private key.
    # Encrypted with empty string password
    $ossl pkcs12 -export -nodes -in ${1} -inkey ${2} -out ${3} -name "User Certificate" -passout pass:

    # unencrypted no pwd
    $ossl pkcs12 -export -keypbe NONE -certpbe NONE -nomaciter -out ${3}.2 -inkey ${2} -in ${1} -name CA_SubCA -passout pass:

    