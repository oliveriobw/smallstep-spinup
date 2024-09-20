#!/usr/bin/env bash  

# usage
#  $1 - path to the mount volume
#  $2 - hostname to create certificate for eg abc.domain.co.uk 
#

[ "" == "$1" ] && echo pass volume path && exit 1
[ ! -d "$1" ] && echo pass valid volume path && exit 1
[ "" == "$2" ] && echo pass domain  && exit 1

VOLUME="$1"
DOMAINS="$2" 

CA_URL=https://${HOSTNAME}:9100
MOUNT="`pwd`"
IMAGE=spinup/step-cli
NOT_AFTER=8760h
PUID=1000
PGID=1000
ROOT_CERT=root_ca.crt

echo "VOLUME: $VOLUME"  

generate_certs() {

  docker run -it --rm \
     --network host \
     -e "STEPDEBUG=1" \
     -v ${MOUNT}:/home/step \
     -v ${VOLUME}:/root-certs \
     -u ${PUID}:${PGID} \
     ${IMAGE} ca certificate ${1} ${1}.crt ${1}.key  \
     --ca-url=${CA_URL} \
     --root=/root-certs/certs/root_ca.crt \
     --kty=RSA \
     --san=127.0.0.1  \
     --san=${HOSTNAME}  \
     --not-after=${NOT_AFTER} \
     --provisioner-password-file=/root-certs/secrets/password        

  mkdir -p certs/${1}        
  mv ${1}.* certs/${1}/        
  cp ${ROOT_CERT} certs/${1}/ 
} 

fingerprint() {        
  docker run -it --rm \
    -v ${MOUNT}:/home/step \
    -v ${VOLUME}:/root-certs \
    --user ${PUID}:${PGID} \
    ${IMAGE} certificate fingerprint /root-certs/certs/root_ca.crt     
} 

#download_root_cert() {        
#   docker run -it --rm \
#     --network host \
#     -v ${MOUNT}:/home/step \
#     --user ${PUID}:${PGID} \
#     ${IMAGE} ca root ${ROOT_CERT} \
#     --ca-url=${CA_URL} \
#     --fingerprint=${1}
# }  

## main

FINGERPRINT=$(fingerprint | tr -d '\n' | tr -d '\r') 
echo $FINGERPRINT

# have the cert in local dir anyway
# download_root_cert ${FINGERPRINT} 

for val in $DOMAINS; do        
  echo "Generating certs for ${val}"        
  generate_certs $val
done 

rm ${ROOT_CERT}

