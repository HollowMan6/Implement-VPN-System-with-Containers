#! /bin/bash
# This script is run on gateway-a when it boots up

## NAT traffic going to the internet
route add default gw 172.26.26.2
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

## Bind the IP address of original local server to the interface
ip addr add 10.1.0.99/16 dev eth0

## Redirect to cloud with Destination NAT
iptables -t nat -A PREROUTING -p tcp -d 10.1.0.99 --dport 8080 -j DNAT --to 10.3.0.3:8080

## Allow VPN traffic to the cloud
iptables -t nat -I POSTROUTING -d 10.3.0.3 -j ACCEPT

## Iptables rules (strict firewall)
### Accept IKE and esp traffic from/to the cloud
iptables -A INPUT -i eth1 -p udp -s 172.28.28.28 --sport 500 -d 172.26.26.26 --dport 500 -j ACCEPT
iptables -A INPUT -i eth1 -p udp -s 172.28.28.28 --sport 4500 -d 172.26.26.26 --dport 4500 -j ACCEPT
iptables -A INPUT -i eth1 -p esp -s 172.28.28.28 -d 172.26.26.26 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.26.26.26 --sport 500 -d 172.28.28.28 --dport 500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.26.26.26 --sport 4500 -d 172.28.28.28 --dport 4500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p esp -s 172.26.26.26 -d 172.28.28.28 -j ACCEPT
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

cat > /etc/ipsec.d/private/siteAKey.pem <<EOL
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDBa8XPmHWpwBLXD0me8b0vd5TCJgJ/f/fGv19T5T/Yztp7svuuf3nZH
tvLilux2sfWgBwYFK4EEACKhZANiAARHw31O02dSApCAlR8mz27Z7HU/opFj6KBQ
WrEkle0WK9WAQQh9Hx5i/V7iCHz8z02YfGljvyxxpMjX7pBN1Obm2OxO1NBp/UOe
nTK5ao5lUhLYZiWqBOwrqKTorBp8ZpM=
-----END EC PRIVATE KEY-----
EOL

## Certificate revocation lists
cp /crls/* /etc/ipsec.d/crls/

## Ipsec config
FIND_FILE="/etc/ipsec.secrets"
FIND_STR=": ECDSA siteAKey.pem"
if [ `grep -c "$FIND_STR" $FIND_FILE` == '0' ];then
    echo "$FIND_STR" >> $FIND_FILE
fi

cat > /etc/ipsec.conf <<EOL
conn a-to-cloud
        keyexchange=ikev2
        leftfirewall=yes
        rightfirewall=yes
        left=172.26.26.26
        leftsubnet=10.1.0.0/16
        leftid=172.26.26.26
        leftcert=siteACert.pem
        leftid="C=FI, O=CSE4300, CN=CSE4300 Site A 172.26.26.26"
        leftca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        right=172.28.28.28
        rightsubnet=10.3.0.0/16
        rightcert=cloudCert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Cloud 172.28.28.28"
        rightca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        ike=aes256gcm16-prfsha384-ecp384!
        esp=aes256gcm16-ecp384!
        auto=route
        dpdaction=hold
EOL

## Start ipsec
ipsec start

# Prevent the container from exiting
while true; do
    sleep 60
done
