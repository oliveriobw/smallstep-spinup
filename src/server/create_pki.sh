#
# setup a new PKI
#
# usage
#   ./run.sh <pki_name>
# 

[ "" == "${1}" ] && echo pass pki_name && exit 1 

PKI_NAME="${1}"
VOLUME="`pwd`/deploy/${PKI_NAME}_vol/"
TMP_CONTAINER=${PKI_NAME}_tmp
cfg=${VOLUME}/config/ca.json
tmp=/tmp/ca.json

echo "deleting ${VOLUME}/* ...<enter-to-continue> ?"
read n
rm -frd ${VOLUME}

echo "creating ${VOLUME}..."
mkdir -p ${VOLUME}

#Add scripts into volume with a transient run
echo "Adding files to volume..."
docker run -d --rm --name ${TMP_CONTAINER} -v ${VOLUME}:/home/step smallstep/step-ca tail -f /dev/null

echo "copy ..."
cat remote.sh  | sed "s/PKI_NAME/$PKI_NAME/g" > /tmp/a.sh
chmod +x /tmp/a.sh
docker cp /tmp/a.sh    ${TMP_CONTAINER}:/home/step/init.sh
docker cp password.ini ${TMP_CONTAINER}:/home/step/password.ini

echo "stop ..."
docker stop ${TMP_CONTAINER}

# launch and init the CA
echo "initialise pki ${PKI_NAME}"
docker run -it --rm -v ${VOLUME}:/home/step smallstep/step-ca ./init.sh

# configure CA
cat ${cfg} \
    | jq '.authority.provisioners[0].claims.minTLSCertDuration="5s"'   \
    | jq '.authority.provisioners[0].claims.maxTLSCertDuration="8760h"'   \
    | jq '.authority.provisioners[0].claims.defaultTLSCertDuration="8760h"'   \
    | jq '.authority.provisioners[0].claims.disableRenewal="false"'   \
    >${tmp}
cp -v ${tmp} ${cfg}    

# shell (opt)
#docker run -it --rm -v ${VOLUME}:/home/step smallstep/step-ca sh

echo "check volume ..."
ls -la ${VOLUME}

echo "root cert..."
crt=${VOLUME}/certs/root_ca.crt
#openssl storeutl -noout -text -certs ${crt}
openssl x509 -noout -text -in ${crt}

echo "intermedite cert ..."
crt=${VOLUME}/certs/intermediate_ca.crt
#openssl storeutl -noout -text -certs ${crt}
openssl x509 -noout -text -in ${crt}

touch launch_${PKI_NAME}.sh
chmod +x launch_${PKI_NAME}.sh
echo docker run -d -it --rm --name ${PKI_NAME} -p 9100:9100 -v ${VOLUME}:/home/step smallstep/step-ca sh >launch_${PKI_NAME}.sh

touch stop_${PKI_NAME}.sh
chmod +x stop_${PKI_NAME}.sh
echo docker stop ${PKI_NAME} >stop_${PKI_NAME}.sh




