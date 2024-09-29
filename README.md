# OpenSSL PKI

### Create a Local PKI and server certificates

See ./deploy/\<my-pki-name>/ for config, certificates, keys, secrets, database etc
1. cd src
2. ./pki.sh \<my-pki-name\> \<domain>
    *eg: ./pki.sh mypki abc.123.co.uk*


### Revoke certificate
1. cd src
2. ./revoke.sh \<pki> \<domain> 

### Test TLS
1. cd src
2. ./test_srv.sh \<pki> \<domain> 




