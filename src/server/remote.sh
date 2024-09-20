#
#  script is copied to the server container to initialise smallstep CA
#   PKI_NAME is replaced
#   DNSes can be added later with addDNS.sh
#

step ca init \
    --deployment-type=standalone \
    --name=PKI_NAME \
    --dns=localhost --dns=127.0.0.1 --dns=some.fqdn.local   \
    --address=:9100 \
    --provisioner=admin \
    --issuer="Your Issuer"  \
    --provisioner-password-file=password.ini  \
    --password-file=password.ini

cat password.ini > /home/step/secrets/password

echo "volume content..."
find /home/step/ -type f

# Should be like:
# /home/step/secrets/root_ca_key
# /home/step/secrets/intermediate_ca_key
# /home/step/certs/intermediate_ca.crt
# /home/step/certs/root_ca.crt
# /home/step/password.ini
# /home/step/init.sh
# /home/step/config/ca.json
# /home/step/config/defaults.json

