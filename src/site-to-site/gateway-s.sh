#! /bin/bash
# This script is run on gateway-s when it boots up

## Traffic going to the internet
route add default gw 172.28.28.2

## NAT Masquerade for eth1
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

## Iptables rules (strict firewall)
### Accept IKE and esp traffic from/to the clients
iptables -A INPUT -i eth1 -p udp -s 172.26.26.26 --sport 500 -d 172.28.28.28 --dport 500 -j ACCEPT
iptables -A INPUT -i eth1 -p udp -s 172.26.26.26 --sport 4500 -d 172.28.28.28 --dport 4500 -j ACCEPT
iptables -A INPUT -i eth1 -p esp -s 172.26.26.26 -d 172.28.28.28 -j ACCEPT
iptables -A INPUT -i eth1 -p udp -s 172.27.27.27 --sport 500 -d 172.28.28.28 --dport 500 -j ACCEPT
iptables -A INPUT -i eth1 -p udp -s 172.27.27.27 --sport 4500 -d 172.28.28.28 --dport 4500 -j ACCEPT
iptables -A INPUT -i eth1 -p esp -s 172.27.27.27 -d 172.28.28.28 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.28.28.28 --sport 500 -d 172.26.26.26 --dport 500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.28.28.28 --sport 4500 -d 172.26.26.26 --dport 4500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p esp -s 172.28.28.28 -d 172.26.26.26 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.28.28.28 --sport 500 -d 172.27.27.27 --dport 500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.28.28.28 --sport 4500 -d 172.27.27.27 --dport 4500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p esp -s 172.28.28.28 -d 172.27.27.27 -j ACCEPT
### Drop everything else (including Internet traffic)
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Certificates
cat > /etc/ipsec.d/cacerts/caCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB5zCCAW2gAwIBAgIIBlG08hASEO4wCgYIKoZIzj0EAwQwOTELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxGDAWBgNVBAMTD0NTRTQzMDAgUm9vdCBDQTAe
Fw0yMzAyMjMxMjI2MTBaFw0zMzAyMjIxMjI2MTBaMDkxCzAJBgNVBAYTAkZJMRAw
DgYDVQQKEwdDU0U0MzAwMRgwFgYDVQQDEw9DU0U0MzAwIFJvb3QgQ0EwdjAQBgcq
hkjOPQIBBgUrgQQAIgNiAASDDSTzphrQn9B8/8H7uoiiAqwxWFmOQ14lTpURalAA
dbBXOAXpwxEUtgHX/dib/IQZ93vSeGy+gm8q1SCHaK+eeyA77BpC2AtrjoORLr/y
Z3Hdq7h7SMiaDkC6o+HT9CKjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/
BAQDAgEGMB0GA1UdDgQWBBRlp9MBSEK91nUsXhhwB96FB+Dr5DAKBggqhkjOPQQD
BANoADBlAjEAoTv9yYXxSeujR6sjXV3lojJ6qkQ7eUC+TOB3ihxF4GeFwHszHcRK
V/oM2+ZFiLA3AjBVryE/e6T9dHXgPdWTQ3wLMErNAFrH2JVwvcnA5pFqPeXn+QqL
xoBbu57Wc0YzYsc=
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/cacerts/intCaCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIICCTCCAZCgAwIBAgIIQcGSlAdfWpEwCgYIKoZIzj0EAwQwOTELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxGDAWBgNVBAMTD0NTRTQzMDAgUm9vdCBDQTAe
Fw0yMzAyMjMxMjI2MTBaFw0yODAyMjMxMjI2MTBaMDgxCzAJBgNVBAYTAkZJMRAw
DgYDVQQKEwdDU0U0MzAwMRcwFQYDVQQDEw5DU0U0MzAwIElOVCBDQTB2MBAGByqG
SM49AgEGBSuBBAAiA2IABJvQl6p8rOsOTI25hnfhe6V5m7YIe6SA5/LfYkQrL0ow
EZFPQq/4k1IIe9KLTQFq1jF9vUVQhSbAMChlssokKwYc9uMhnWxnLDgNm14e+mNE
UW8qciWFNMx5UTqoPBzaMqNmMGQwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8B
Af8EBAMCAQYwHQYDVR0OBBYEFGUwv0Vx7b3qOwTkMuoRTB1EKLuFMB8GA1UdIwQY
MBaAFGWn0wFIQr3WdSxeGHAH3oUH4OvkMAoGCCqGSM49BAMEA2cAMGQCMEIg8LUh
jEo/AyQysXfuKOYtswRVYZOqNg5V2G3zi5Q52LppCgeYIqPY34HXTdkvlQIwJ+KV
4bw1b8NvJZqJCbtn6SOnxVhzs0p1kaKAwJuteIGDDgw0wfiREKa/4M5m2siF
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/siteACert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB+TCCAX+gAwIBAgIIUOn2G9KNl7EwCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIzMDIyMzEyMjYxMFoXDTI1MDgyNDEyMjYxMFowRTELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxJDAiBgNVBAMTG0NTRTQzMDAgU2l0ZSBBIDE3Mi4yNi4y
Ni4yNjB2MBAGByqGSM49AgEGBSuBBAAiA2IABEfDfU7TZ1ICkICVHybPbtnsdT+i
kWPooFBasSSV7RYr1YBBCH0fHmL9XuIIfPzPTZh8aWO/LHGkyNfukE3U5ubY7E7U
0Gn9Q56dMrlqjmVSEthmJaoE7CuopOisGnxmk6NJMEcwHwYDVR0jBBgwFoAUZTC/
RXHtveo7BOQy6hFMHUQou4UwDwYDVR0RBAgwBocErBoaGjATBgNVHSUEDDAKBggr
BgEFBQcDAjAKBggqhkjOPQQDBANoADBlAjEAlyrwjpjqst8bP+zBJ/wZydMIKak6
ghmlDg5eaBYxLwzUQMOpi8PDpCgxYheRjeAnAjA9f0Jbk5kpL/fuHprKorcj0IfF
kmsmWFVS9cIJafYGYLchF5XMfFNcjHYOWDAGs6k=
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/siteBCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB+TCCAX+gAwIBAgIIAojIKNtRwM4wCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIzMDIyMzEyMjYxMFoXDTI1MDgyNDEyMjYxMFowRTELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxJDAiBgNVBAMTG0NTRTQzMDAgU2l0ZSBCIDE3Mi4yNy4y
Ny4yNzB2MBAGByqGSM49AgEGBSuBBAAiA2IABJyWLo1MLeqHHSIrVuYqag67wKhk
/Fsktdm4d6cQQzwbAU9LXtQmSPxpv2EGcfkraz9BWtVSh+dG4MZN+HowSdL3bef2
WkAVRMIq373CUxui5vY8eRzuMczj2xw3vbDFHKNJMEcwHwYDVR0jBBgwFoAUZTC/
RXHtveo7BOQy6hFMHUQou4UwDwYDVR0RBAgwBocErBsbGzATBgNVHSUEDDAKBggr
BgEFBQcDAjAKBggqhkjOPQQDBANoADBlAjEA0ookn8ZCmleKNUR+bgXynvPVpz6F
9JG104Srw4ky36vJWUh/eLuVCQ6vihxB/G3ZAjBAekOK6invbFtLVqlQd6PPJzk+
1qYkRv6QWkYgpf/dox2cyFSHRrETa9FA02VmrIw=
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/cloudCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB9zCCAX6gAwIBAgIIUCQWCjMg1fowCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIzMDIyMzEyMjYxMFoXDTI1MDgyNDEyMjYxMFowRDELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxIzAhBgNVBAMTGkNTRTQzMDAgQ2xvdWQgMTcyLjIxLjIx
LjI0MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAE1cnLTpnPc01pKgVJuM9OF1Fg7Azf
Kxo16Tk8rqkHvq+MTzWLgtiibA/QSymfeqEQMjuax56ADeYpxfAeeav/thljIs28
MRrBMQfk/sTNCOSY5uUU5PHIgJUlrROnAjvco0kwRzAfBgNVHSMEGDAWgBRlML9F
ce296jsE5DLqEUwdRCi7hTAPBgNVHREECDAGhwSsFRUYMBMGA1UdJQQMMAoGCCsG
AQUFBwMBMAoGCCqGSM49BAMEA2cAMGQCMDCHQ3Ik0KbZ5m0okdklTQd5WLQeMang
h28yAYrv1+UWcMwebYK1U3pcsrI5l5G2qAIwRyHs9chqsT2tSPOCiwMQ0P+wF1yG
8KJL7VjyN+gjUFGu5LQwV4GFo4QgL/VI8mj9
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/private/cloudKey.pem <<EOL
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDAvz+Aatu/lpZlNX41QWn6IM3ws56l5R5iV280UedOZ4WB+75MMxuN7
K3V6t2wygvGgBwYFK4EEACKhZANiAATVyctOmc9zTWkqBUm4z04XUWDsDN8rGjXp
OTyuqQe+r4xPNYuC2KJsD9BLKZ96oRAyO5rHnoAN5inF8B55q/+2GWMizbwxGsEx
B+T+xM0I5Jjm5RTk8ciAlSWtE6cCO9w=
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
        left=172.28.28.28
        leftsubnet=10.3.0.0/16
        leftcert=cloudCert.pem
        leftid="C=FI, O=CSE4300, CN=CSE4300 Cloud 172.28.28.28"
        leftca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        rightca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        ike=aes256gcm16-prfsha384-ecp384!
        esp=aes256gcm16-ecp384!
        auto=route
        dpdaction=hold
conn cloud-to-a
        also=%default
        right=172.26.26.26
        rightsubnet=10.1.0.0/16
        rightcert=siteACert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Site A 172.26.26.26"
conn cloud-to-b
        also=%default
        right=172.27.27.27
        rightsubnet=10.2.0.0/16
        rightcert=siteBCert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Site B 172.27.27.27"
EOL

## Start ipsec for updates to take effect
ipsec start

# Prevent the container from exiting
while true; do
    sleep 60
done
