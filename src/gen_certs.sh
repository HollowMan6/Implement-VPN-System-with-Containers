#!/bin/bash

mkdir private certs crls cacerts reqs

# CA
pki --gen --type ecdsa --outform pem > caKey.pem
pki --self --ca --lifetime 3652 --in caKey.pem --digest sha512 \
           --dn "C=FI, O=CSE4300, CN=CSE4300 Root CA" \
           --outform pem > cacerts/caCert.pem

# Intermediate CA
pki --gen --type ecdsa --outform pem > intCaKey.pem
pki --req --type priv --in intCaKey.pem \
          --dn "C=FI, O=CSE4300, CN=CSE4300 INT CA" \
          --outform pem > reqs/intCaReq.pem
pki --issue --cacert cacerts/caCert.pem --cakey caKey.pem --digest sha512 \
            --type pkcs10 --in reqs/intCaReq.pem --lifetime 1826 \
            --outform pem --ca --pathlen 0 > cacerts/intCaCert.pem

# Site a
pki --gen --type ecdsa --outform pem > private/siteAKey.pem
pki --req --type priv --in private/siteAKey.pem \
          --dn "C=FI, O=CSE4300, CN=CSE4300 Site A 172.26.26.26" \
          --san 172.26.26.26 --outform pem > reqs/siteAReq.pem
pki --issue --cacert cacerts/intCaCert.pem --cakey intCaKey.pem \
            --type pkcs10 --in reqs/siteAReq.pem --lifetime 913 \
            --outform pem --flag clientAuth --digest sha512 > certs/siteACert.pem

# Site b
pki --gen --type ecdsa --outform pem > private/siteBKey.pem
pki --req --type priv --in private/siteBKey.pem \
          --dn "C=FI, O=CSE4300, CN=CSE4300 Site B 172.27.27.27" \
          --san 172.27.27.27 --outform pem > reqs/siteBReq.pem
pki --issue --cacert cacerts/intCaCert.pem --cakey intCaKey.pem \
            --type pkcs10 --in reqs/siteBReq.pem --lifetime 913 \
            --outform pem --flag clientAuth --digest sha512 > certs/siteBCert.pem

# Cloud
pki --gen --type ecdsa --outform pem > private/cloudKey.pem
pki --req --type priv --in private/cloudKey.pem \
          --dn "C=FI, O=CSE4300, CN=CSE4300 Cloud 172.21.21.24" \
          --san 172.21.21.24 --outform pem > reqs/cloudReq.pem
pki --issue --cacert cacerts/intCaCert.pem --cakey intCaKey.pem \
            --type pkcs10 --in reqs/cloudReq.pem --lifetime 913 \
            --outform pem --flag serverAuth --digest sha512 > certs/cloudCert.pem

# CRL
pki --signcrl --cacert cacerts/caCert.pem --cakey caKey.pem \
              --lifetime 365 > crls/cse4300Ca.crl
pki --signcrl --cacert cacerts/intCaCert.pem --cakey intCaKey.pem \
              --lifetime 365 > crls/cse4300IntCa.crl
