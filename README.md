# smallstep-spinup

## Create a Local PKI (non interactive)

Creates new docker container for the PKI. Creates new scripts to start and stop the container.
See ./deploy/<my-pki-name>/ for config, certificates, keys, secrets, database

1. cd src/server
2. ./create_pki.sh \<my-pki-name\>
    *eg: ./create_pki.sh mypki*


#### Options 
Edit hard coded values in password.ini,remote.sh, run.sh as needed.

## To Create Server Certs
Start the service with launch_* script 

1. cd src/cli
2. ./cli.h \<volume-path> \<domain>  
   eg:
    *Use the path created during the pki setup, previous stage*
    *export volume=/path/to/deploy/mypki/*
    *./cli.h ${volume} abc.mydomain.co.uk*




