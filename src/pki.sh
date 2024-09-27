#!/usr/bin/env bash


[ "" == "$1" ] && echo no && exit 


# pwd 
# find . | grep priv
# pushd ./deploy/${1}/ca/root-ca/private/
#     touch root-ca.key
#     ls 
# popd 

if [ $csr ] ; then

    base=./deploy/${1}/ca/root-ca
    echo mkdir -p -m 777 "deploy/${1}/root"
    mkdir -p -m 777 ${base}/private ${base}/db ${base}/crl ${base}/certs
    mkdir -p -m 777 ./deploy/${1}/etc/

    # databse 
    touch ${base}/db/root-ca.db
    echo 01 > ${base}/db/root-ca.crt.srl
    echo 01 > ${base}/db/root-ca.crl.srl

    # ca request need to be 
    cp -v root.cfg ./deploy/${1}/etc/

    pushd ./deploy/${1}
    pwd 
    ls ./etc/root.cfg 
    openssl_="docker run -ti --rm -v $(pwd):/apps -w /apps alpine/openssl"

        #
        # NEW CSR WITH KEY!!
        #
        #nodes for no encryption on the key
            $openssl_ req -new \
                -nodes   \
                -config ./etc/root.cfg \
                -out ./ca/root-ca.csr \
                -keyout root-ca.key

        $openssl_ x509 -noout -text -in ./ca/root-ca.csr >./ca/root-ca.csr.txt
fi 

if [ $v1 ] ; then
            #
            # Self Signed RSA:4096
            # no pwd
            $openssl_ req \
                -new \
                -newkey rsa:4096 \
                -days 365 \
                -nodes \
                -x509 \
                -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
                -keyout www.example.com.key \
                -out www.example.com.cert


            $openssl_ x509 -noout -text -in www.example.com.cert >www.example.com.cert.txt
fi 


function openssl()
{
    echo $*
    docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl $*
}

if [ 1 -ne 0 ] ; then

    mkdir -p -m 777 deploy/v3/RootCA/private
    cp openssl.cnf deploy/v3/
    PATH=$PATH:`pwd`
    pushd deploy/v3/
        echo version3
        setup_root.sh
        setup_subca.sh
        create_srv_cert.sh
    exit 
fi 

if [ 1 -ne 1 ] ; then

    mkdir -p -m 777 deploy/v2/
    #alias openssl_="docker run -ti --rm -v $(pwd)/deploy/v2/:/apps -w /apps alpine/openssl"


   pushd deploy/v2/

        echo version2
        outdir=$(pwd)
        ossl="docker run -ti --rm -v ${outdir}:/apps -w /apps alpine/openssl"

        #
        # 1. PKI Private Key
        #
        echo pki pvt key...]
        $ossl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out pki_pvt_ca.key

        #$ossl req -x509 -new -nodes -key ca.key -sha512 -days 30 -subj "/CN=example-selfsigned-ca" -out ca.crt
        chmod +r pki_pvt_ca.key

        echo certificate...
        #
        # 2. Issue a self-signed certificate for your internal certificate authority 
        #
        #X509v3 Basic Constraints: critical
        #               CA:TRUE
        #
        # Self Signed RSA:4096 
        # NO CSR: just crt
        # YOU EXTRA ARGS: 
        #  no pwd
        # TO NOT PROVIDE OWN KEY:   -newkey rsa:4096 \
           #  -addext 'basicConstraints = CA:FALSE'      
        echo $ossl 
        $ossl req \
            -x509 \
            -new \
            -nodes \
            -key pki_pvt_ca.key  \
            -sha512   \
            -days 365 \
            -subj "/C=GB/L=Swindon/O=YourOrg/CN=Self Signed CA" \
            -addext "authorityKeyIdentifier = keyid,issuer"  \
            -keyout ca.key \
            -out distribute_ca.crt   


        #-addext "extendedKeyUsage = serverAuth,1.3.6.1.4.1.311.80.1"
        # -addext "subjectAltName = DNS:localhost DNS:your.domain.co.uk"   \
        # -addext "keyUsage = digitalSignature, keyEncipherment"  \

                           
        #openssl x509 -noout -text -in www.example.com.cert.2 >www.example.com.cert2.txt
    popd 
fi 

exit




DONE 2. Create a configuration file
Copy the root CA configuration file to the directory you created. For example, you can use /root/ca/openssl.cnf.

DONE 3. Create the root key
Encrypt the root key with a strong password and AES 256-bit encryption.

4. Create the root certificate
Use the root key to create a root certificate. Make sure to give the root certificate a long expiry date. 
The process for creating a PKI root with OpenSSL can vary depending on the operating system you are using. For example, on macOS, you can:
Open a Command Console
Enter openssl genrsa -des3 -out myCA. key 2048
Enter your passphrase when prompted
Enter openssl req -x509 -new -nodes -key myCA. key -sha256 -days 1825 -out myCA. pem
Answer questions about Name, Location, State, Organization, and more 

