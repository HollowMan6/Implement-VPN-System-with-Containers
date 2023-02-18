#! /bin/bash
# This script is run on gateway-s when it boots up

## Traffic going to the internet
route add default gw 172.24.24.2

## NAT Masquerade for eth1
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

## Iptables rules (strict firewall)
### Accept IKE and esp traffic from/to the clients
iptables -A INPUT -i eth1 -p udp -s 172.22.22.22 --sport 500 -d 172.24.24.24 --dport 500 -j ACCEPT
iptables -A INPUT -i eth1 -p udp -s 172.22.22.22 --sport 4500 -d 172.24.24.24 --dport 4500 -j ACCEPT
iptables -A INPUT -i eth1 -p esp -s 172.22.22.22 -d 172.24.24.24 -j ACCEPT
iptables -A INPUT -i eth1 -p udp -s 172.23.23.23 --sport 500 -d 172.24.24.24 --dport 500 -j ACCEPT
iptables -A INPUT -i eth1 -p udp -s 172.23.23.23 --sport 4500 -d 172.24.24.24 --dport 4500 -j ACCEPT
iptables -A INPUT -i eth1 -p esp -s 172.23.23.23 -d 172.24.24.24 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.24.24.24 --sport 500 -d 172.22.22.22 --dport 500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.24.24.24 --sport 4500 -d 172.22.22.22 --dport 4500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p esp -s 172.24.24.24 -d 172.22.22.22 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.24.24.24 --sport 500 -d 172.23.23.23 --dport 500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.24.24.24 --sport 4500 -d 172.23.23.23 --dport 4500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p esp -s 172.24.24.24 -d 172.23.23.23 -j ACCEPT
### Drop everything else (including Internet traffic)
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Certificates
cat > /etc/ipsec.d/cacerts/caCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB5zCCAW2gAwIBAgIIefSs4TmghfMwCgYIKoZIzj0EAwQwOTELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxGDAWBgNVBAMTD0NTRTQzMDAgUm9vdCBDQTAe
Fw0yMzAyMTgxNzQ5MzNaFw0zMzAyMTcxNzQ5MzNaMDkxCzAJBgNVBAYTAkZJMRAw
DgYDVQQKEwdDU0U0MzAwMRgwFgYDVQQDEw9DU0U0MzAwIFJvb3QgQ0EwdjAQBgcq
hkjOPQIBBgUrgQQAIgNiAAROt6XCV5s1mILaCTT39rxmRTk4KgkseSTtZ1a3XuD8
ZUzkNo+srpzWNvUbg2bSJiP1tZq4R9/YRSnFkeMztQh6Zy8B3FM9Ytc4/2m7IIaL
CzLz/gGYsWU9jm/PVkelPEqjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/
BAQDAgEGMB0GA1UdDgQWBBQHgLcdOl66gQsjKU2zCoBkr6mLNDAKBggqhkjOPQQD
BANoADBlAjEArWxgCtpHjbfSWrOgT3ldUzvbTB8I/zogS4o2QK82Y0lhtneVbLht
OpKAHpf4a5xnAjAXC5a4+YM39NDg62wC/3uCeLeYvgGiWDA44123P9nD5ANON1gB
JsSiA6kS5yxB084=
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/cacerts/intCaCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIICCjCCAZCgAwIBAgIIDrttUOqrhk0wCgYIKoZIzj0EAwQwOTELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxGDAWBgNVBAMTD0NTRTQzMDAgUm9vdCBDQTAe
Fw0yMzAyMTgxNzQ5MzNaFw0yODAyMTgxNzQ5MzNaMDgxCzAJBgNVBAYTAkZJMRAw
DgYDVQQKEwdDU0U0MzAwMRcwFQYDVQQDEw5DU0U0MzAwIElOVCBDQTB2MBAGByqG
SM49AgEGBSuBBAAiA2IABC4hUmL9TFtozy0HeggI4oZ7XCSbiyS4Te/Xi9FCbkVC
+85Scg8GRkZeAgiGr2csV4bHxq/vzzmStWT6pITanaXtVWUYi/2MKRsDhx6tgj19
SWBqRLZ781zSbGYhsLRGW6NmMGQwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8B
Af8EBAMCAQYwHQYDVR0OBBYEFBRc5K5Y1n88eGrF9WU/l7jh+AYQMB8GA1UdIwQY
MBaAFAeAtx06XrqBCyMpTbMKgGSvqYs0MAoGCCqGSM49BAMEA2gAMGUCMGpuRY6e
Rh392lSvCeMasNJ6Gd8ajJGhKRdwOZksWxW0NwRRgCLzP+D6zGPXB+Da2AIxAOKH
uwqOFi8vc9GZtaWI4BqB+ujlIoMRzbZDpw7yfhfBd5j1sqwHnWlwQAMs1xRM/g==
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/siteACert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB+jCCAX+gAwIBAgIIZwh/j/Y8CtYwCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIzMDIxODE3NDkzM1oXDTI1MDgxOTE3NDkzM1owRTELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxJDAiBgNVBAMTG0NTRTQzMDAgU2l0ZSBBIDE3Mi4yMi4y
Mi4yMjB2MBAGByqGSM49AgEGBSuBBAAiA2IABADW3QIeuIRqXQ4xtqbPYR2l9qqc
KOJT8j7zBqcucaFak0HdhMKUlWGSaBI6HwmzDtDJFIb4ZdsfchC1b4eaNjBhVCkz
Yqt7CbXIqY2liiK2vDpXO9TXNqn9bWE8Ia0GM6NJMEcwHwYDVR0jBBgwFoAUFFzk
rljWfzx4asX1ZT+XuOH4BhAwDwYDVR0RBAgwBocErBYWFjATBgNVHSUEDDAKBggr
BgEFBQcDAjAKBggqhkjOPQQDBANpADBmAjEA40u89WF4sVhGouBYpcOSdZ26HaZ5
AJGCp6PYFjBNfS43fdA6WkAfwdI9BEzmqgnhAjEA4fW2wX9dguI3fDnyp1XOLC89
rrV7yOfQ/qrVR1VpGB7MYut24hq1enUTfJM+sXaP
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/siteBCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB+TCCAX+gAwIBAgIIbjJFk5HsEEYwCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIzMDIxODE3NDkzM1oXDTI1MDgxOTE3NDkzM1owRTELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxJDAiBgNVBAMTG0NTRTQzMDAgU2l0ZSBCIDE3Mi4yMy4y
My4yMzB2MBAGByqGSM49AgEGBSuBBAAiA2IABG3C+BBEeqrWPZNIGAQoXWqhcIt7
3FvPmMGrivuDPQQBCok2EukrHOWJAHULypaYZk1ZC2bAwtlCyvbQEeICP0wz9QhM
/j84acULtGSbncF7PqoZgmoC0wCCgTfRuLkEK6NJMEcwHwYDVR0jBBgwFoAUFFzk
rljWfzx4asX1ZT+XuOH4BhAwDwYDVR0RBAgwBocErBcXFzATBgNVHSUEDDAKBggr
BgEFBQcDAjAKBggqhkjOPQQDBANoADBlAjEA70VIKMc7nyuzQ8YSwfVpGC944g7B
cue+2eB+VaA+kDS/b2vsABg+ldQWXP7vhw4bAjAm1m8Y3NbUEoUy91rcKFUHW9IP
y2MqSNG4Rke4xl2BctzGiCypJ3+jqW05cYrA9sk=
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/cloudCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB9zCCAX6gAwIBAgIIGvY/tR3HaiQwCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIzMDIxODE3NDkzM1oXDTI1MDgxOTE3NDkzM1owRDELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxIzAhBgNVBAMTGkNTRTQzMDAgQ2xvdWQgMTcyLjI0LjI0
LjI0MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEs/3UYQmI45zmpmnTb00og6Rh1qqN
qiKDS8BQ9zuADifm+Hx4TVcboXvNvYY5e7CT7nUIcFVervluNLEXiKs15+o56iJn
lOmIpOB+xTDTZrzdPNLHE7tEX6fX1LN0lVh2o0kwRzAfBgNVHSMEGDAWgBQUXOSu
WNZ/PHhqxfVlP5e44fgGEDAPBgNVHREECDAGhwSsGBgYMBMGA1UdJQQMMAoGCCsG
AQUFBwMBMAoGCCqGSM49BAMEA2cAMGQCMCGv/YRPUfErysNySNaXeNa3ELb2lhiQ
Bq8w+uk+9e0G0l+37jHiNaMyDepQnW47aAIwYAyEOxUHnjE516yQu5TedjVkVxqs
763QOgFrJu6cvWds78s7aI+vRDfBslfNb6JI
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/private/cloudKey.pem <<EOL
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDDp/B2X/Stw7tKi2EL6owuZgF7GQtk0rulIP9Rrj5zC5+U111TWL22K
jRLAkiH6acigBwYFK4EEACKhZANiAASz/dRhCYjjnOamadNvTSiDpGHWqo2qIoNL
wFD3O4AOJ+b4fHhNVxuhe829hjl7sJPudQhwVV6u+W40sReIqzXn6jnqImeU6Yik
4H7FMNNmvN080scTu0Rfp9fUs3SVWHY=
-----END EC PRIVATE KEY-----
EOL

## Certificate revocation lists
cp /crls/* /etc/ipsec.d/crls/

## Ipsec config
FIND_FILE="/etc/ipsec.secrets"
FIND_STR=": ECDSA cloudKey.pem"
if [ `grep -c "$FIND_STR" $FIND_FILE` == '0' ];then
    echo "$FIND_STR" >> $FIND_FILE
fi

cat > /etc/ipsec.conf <<EOL
conn %default
        keyexchange=ikev2
        leftfirewall=yes
        rightfirewall=yes
        left=172.24.24.24
        leftsubnet=10.3.0.0/16
        leftcert=cloudCert.pem
        leftid="C=FI, O=CSE4300, CN=CSE4300 Cloud 172.24.24.24"
        leftca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        rightca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        ike=aes256gcm16-prfsha384-ecp384!
        esp=aes256gcm16-ecp384!
        auto=route
        dpdaction=hold
conn cloud-to-a
        also=%default
        right=172.22.22.22
        rightsubnet=10.1.0.0/16
        rightcert=siteACert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Site A 172.22.22.22"
conn cloud-to-b
        also=%default
        right=172.23.23.23
        rightsubnet=10.2.0.0/16
        rightcert=siteBCert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Site B 172.23.23.23"
EOL

## Start ipsec for updates to take effect
ipsec start

# Prevent the container from exiting
while true; do
    sleep 60
done
