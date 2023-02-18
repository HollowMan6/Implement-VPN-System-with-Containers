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

## Stop internet traffic
iptables -A FORWARD -j DROP

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Certificates
cat > /etc/ipsec.d/cacerts/caCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB5zCCAW2gAwIBAgIIbmG+LQK80gMwCgYIKoZIzj0EAwQwOTELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxGDAWBgNVBAMTD0NTRTQzMDAgUm9vdCBDQTAe
Fw0yMzAyMDMxNDM3MDRaFw0zMzAyMDIxNDM3MDRaMDkxCzAJBgNVBAYTAkZJMRAw
DgYDVQQKEwdDU0U0MzAwMRgwFgYDVQQDEw9DU0U0MzAwIFJvb3QgQ0EwdjAQBgcq
hkjOPQIBBgUrgQQAIgNiAAQkS82r3TFpJwTJQhYbZdTRQrk8yU0HB9ASj36VrrGq
qBr7VRl0vxr+VddPzkhCAOD4u14i/p9I+jQW5aSnBE9+mnLb0XtUWIul2Jbgvz/j
4L0yqkND/ZEaJciwJhVhGlKjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/
BAQDAgEGMB0GA1UdDgQWBBQEYg8YvuV5y8vRdSLRLh8vkNqTbDAKBggqhkjOPQQD
BANoADBlAjEA6VWwb/U3hSL46Aad78AYkg80vmUdnZQSbge+V5zUGNya0L/ihQlL
rYLwclfARCcOAjAs/vzZDHfGXicjxqGVYUh4EJg/13lGDutqaSAUsDFYpH232dHN
LnaVlmVirVwCNC8=
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/cacerts/intCaCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIICCjCCAZCgAwIBAgIIZm3yX4K4k9MwCgYIKoZIzj0EAwQwOTELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxGDAWBgNVBAMTD0NTRTQzMDAgUm9vdCBDQTAe
Fw0yMzAyMDMxNDM3MDVaFw0yODAyMDMxNDM3MDVaMDgxCzAJBgNVBAYTAkZJMRAw
DgYDVQQKEwdDU0U0MzAwMRcwFQYDVQQDEw5DU0U0MzAwIElOVCBDQTB2MBAGByqG
SM49AgEGBSuBBAAiA2IABN8N99e3X2vgB1whWHSxxJIniM+HeBkXW/16hIrWCE1j
XOGor/SBRv1q/vPXea4aAy9mhfAcLjzrwKtHZ8Z3IqHULFQe5LyLVJm5npYaok4k
lJ6fcmBaUNcOTkpBeqaaXaNmMGQwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8B
Af8EBAMCAQYwHQYDVR0OBBYEFHKwNXkHYIEnsqQFw2TS5J+dGOsTMB8GA1UdIwQY
MBaAFARiDxi+5XnLy9F1ItEuHy+Q2pNsMAoGCCqGSM49BAMEA2gAMGUCMD32JWpc
A339JH/fdY+A2MUe/2ab/ncRi3jCVhlOFH07JN/l8bwKrMxWcMJeYGM5cwIxAKm2
Kg/eyT4E+fop8RQgmS4CSvi293TuG93Fd7ycZl2uROkz6LYdmIJuCpDYK4SUow==
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/siteBCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB9zCCAXygAwIBAgIIQj1LxmgMrPMwCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIzMDIwMzE0MzcwNVoXDTI1MDgwNDE0MzcwNVowQjELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxITAfBgNVBAMTGENTRTQzMDAgU2l0ZSBCIDE3Mi44Ljgu
ODB2MBAGByqGSM49AgEGBSuBBAAiA2IABC0g1mVelcL6JAQQgjYpS1xagbqUZEBW
tkuRozRpayRSDd19SVvw3NXz0K2ER4uI0RpwlZ5kTpagx8uEp0OMiu6Tn6YHQOBA
kT0SAV4spyZROrGGprtMBPuihv34y+ymdKNJMEcwHwYDVR0jBBgwFoAUcrA1eQdg
gSeypAXDZNLkn50Y6xMwDwYDVR0RBAgwBocErAgICDATBgNVHSUEDDAKBggrBgEF
BQcDAjAKBggqhkjOPQQDBANpADBmAjEAzeol8elsRI2/52hDAOgimX7iFBRQkcvw
B1vnSQB4Rjg/A2G/COmRN58E2Qdk6rbLAjEAxuyTPctMQmh+QadODqh+xdveaV/r
lDUIcUDOvrflNYfWhKV+zX5wlUTU7MSu6wQl
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/cloudCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB9TCCAXugAwIBAgIIfwuh3aN5210wCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIzMDIwMzE0MzcwNVoXDTI1MDgwNDE0MzcwNVowQTELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxIDAeBgNVBAMTF0NTRTQzMDAgQ2xvdWQgMTcyLjcuNy43
MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEVfVy9lK8CYhki5BkZSvMpVSWr6BLOVYE
qRXPQsTpudJfQKk3mog3w9+muobZPG15EseHF2ztBCEwmCUdokwf+att23vGerca
pQF29DH9NaJRMLMeslKOnRxeq4D2Tfnxo0kwRzAfBgNVHSMEGDAWgBRysDV5B2CB
J7KkBcNk0uSfnRjrEzAPBgNVHREECDAGhwSsBwcHMBMGA1UdJQQMMAoGCCsGAQUF
BwMBMAoGCCqGSM49BAMEA2gAMGUCMBR4hKZp/niai5fHaz+Te7pRU8j/+Hbhn7vi
iUOZIbx1jV8/Y2TLSavtdZo/+YjSxgIxAPvaUB4xU0PyQFqGLshlVqxQafAm09Yg
8oYhRgiResS16EkCxHPbSdeOa1G1XG1qAw==
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/private/siteBKey.pem <<EOL
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDAhTPML8XnCEHaeBNfFixEojzajVhILcZs36hKVN0ykN7xdR8zrs7zf
49nAv/UkkLigBwYFK4EEACKhZANiAAQtINZlXpXC+iQEEII2KUtcWoG6lGRAVrZL
kaM0aWskUg3dfUlb8NzV89CthEeLiNEacJWeZE6WoMfLhKdDjIruk5+mB0DgQJE9
EgFeLKcmUTqxhqa7TAT7oob9+MvspnQ=
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
