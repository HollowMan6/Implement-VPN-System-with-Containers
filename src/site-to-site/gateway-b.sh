#! /bin/bash
# This script is run on gateway-b when it boots up

## NAT traffic going to the internet
route add default gw 172.23.23.2
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

## Bind the IP address of original local server to the interface
ip addr add 10.2.0.99/16 dev eth0

## Redirect to cloud with Destination NAT
iptables -t nat -A PREROUTING -p tcp -d 10.2.0.99 --dport 8080 -j DNAT --to 10.3.0.3:8080

## Allow VPN traffic to the cloud
iptables -t nat -I POSTROUTING -d 10.3.0.3 -j ACCEPT

## Iptables rules (strict firewall)
### Accept IKE and esp traffic from/to the cloud
iptables -A INPUT -i eth1 -p udp -s 172.24.24.24 --sport 500 -d 172.23.23.23 --dport 500 -j ACCEPT
iptables -A INPUT -i eth1 -p udp -s 172.24.24.24 --sport 4500 -d 172.23.23.23 --dport 4500 -j ACCEPT
iptables -A INPUT -i eth1 -p esp -s 172.24.24.24 -d 172.23.23.23 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.23.23.23 --sport 500 -d 172.24.24.24 --dport 500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.23.23.23 --sport 4500 -d 172.24.24.24 --dport 4500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p esp -s 172.23.23.23 -d 172.24.24.24 -j ACCEPT
### Drop everything else (including Internet traffic)
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

# ## Stop internet traffic
# iptables -A FORWARD -j DROP

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

cat > /etc/ipsec.d/private/siteBKey.pem <<EOL
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDBvlM8e1B/ZEuWOLIzbW94YEoaosP7OesPb7gXilkUL6xc6u1T0Ihb9
mvp+8wePIeKgBwYFK4EEACKhZANiAARtwvgQRHqq1j2TSBgEKF1qoXCLe9xbz5jB
q4r7gz0EAQqJNhLpKxzliQB1C8qWmGZNWQtmwMLZQsr20BHiAj9MM/UITP4/OGnF
C7Rkm53Bez6qGYJqAtMAgoE30bi5BCs=
-----END EC PRIVATE KEY-----
EOL

## Certificate revocation lists
cp /crls/* /etc/ipsec.d/crls/

## Ipsec config
FIND_FILE="/etc/ipsec.secrets"
FIND_STR=": ECDSA siteBKey.pem"
if [ `grep -c "$FIND_STR" $FIND_FILE` == '0' ];then
    echo "$FIND_STR" >> $FIND_FILE
fi

cat > /etc/ipsec.conf <<EOL
conn b-to-cloud
        keyexchange=ikev2
        leftfirewall=yes
        rightfirewall=yes
        left=172.23.23.23
        leftsubnet=10.2.0.0/16
        leftid=172.23.23.23
        leftcert=siteBCert.pem
        leftid="C=FI, O=CSE4300, CN=CSE4300 Site B 172.23.23.23"
        leftca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        right=172.24.24.24
        rightsubnet=10.3.0.0/16
        rightcert=cloudCert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Cloud 172.24.24.24"
        rightca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        ike=aes256gcm16-prfsha384-ecp384!
        esp=aes256gcm16-ecp384!
        auto=route
        dpdaction=hold
EOL

## Start ipsec for updates to take effect
ipsec start

# Prevent the container from exiting
while true; do
    sleep 60
done
