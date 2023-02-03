#! /bin/bash
# This script is run on gateway-b when it boots up

## NAT traffic going to the internet
route add default gw 172.18.18.2
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

## Bind the IP address of original local server to the interface
ip addr add 10.2.0.99/16 dev eth0

## Redirect to cloud with Destination NAT
iptables -t nat -A PREROUTING -p tcp -d 10.2.0.99 --dport 8080 -j DNAT --to 10.3.0.3:8080

## Allow VPN traffic to the cloud
iptables -t nat -I POSTROUTING -d 10.3.0.3 -j ACCEPT

## Iptables rules (strict firewall)
### Accept IKE and esp traffic from/to the cloud
iptables -A INPUT -i eth1 -p udp -s 172.30.30.30 --sport 500 -d 172.18.18.18 --dport 500 -j ACCEPT
iptables -A INPUT -i eth1 -p udp -s 172.30.30.30 --sport 4500 -d 172.18.18.18 --dport 4500 -j ACCEPT
iptables -A INPUT -i eth1 -p esp -s 172.30.30.30 -d 172.18.18.18 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.18.18.18 --sport 500 -d 172.30.30.30 --dport 500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p udp -s 172.18.18.18 --sport 4500 -d 172.30.30.30 --dport 4500 -j ACCEPT
iptables -A OUTPUT -o eth1 -p esp -s 172.18.18.18 -d 172.30.30.30 -j ACCEPT
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
MIIB5jCCAW2gAwIBAgIIKN1tgkU2rL0wCgYIKoZIzj0EAwQwOTELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxGDAWBgNVBAMTD0NTRTQzMDAgUm9vdCBDQTAe
Fw0yMjEyMDUwMDU5MTNaFw0zMjEyMDQwMDU5MTNaMDkxCzAJBgNVBAYTAkZJMRAw
DgYDVQQKEwdDU0U0MzAwMRgwFgYDVQQDEw9DU0U0MzAwIFJvb3QgQ0EwdjAQBgcq
hkjOPQIBBgUrgQQAIgNiAASc8Q/7felpOdR7nLfnXkIz53Knq+AeVDn+TIa/9TbH
X2w7gHas+NClnEDHK1a5BgWOsF1m+MjU8BRe94Oa/MeR7xMT2qIIy/mlHIRpOTc/
B1Msa7CX6B4jIaJTXr8idgGjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/
BAQDAgEGMB0GA1UdDgQWBBSIXEjItP88lAV7Qtdq7pevRzNEdTAKBggqhkjOPQQD
BANnADBkAjAtZd2Rz0tIb31DS+17jkgFbIgvBf1XHA0e75/Cp3uSo68NsyXipGkB
uX8rhF0mB/oCMGC2SrUaBFX2znWd1tTzfoLTN+GnLoBAVkwdXDKy7Ci3IDHmEic1
RrZOG4C9MBBnOg==
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/cacerts/intCaCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIICCjCCAZCgAwIBAgIIBkryXpq6KXswCgYIKoZIzj0EAwQwOTELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxGDAWBgNVBAMTD0NTRTQzMDAgUm9vdCBDQTAe
Fw0yMjEyMDUwMDU5MTNaFw0yNzEyMDUwMDU5MTNaMDgxCzAJBgNVBAYTAkZJMRAw
DgYDVQQKEwdDU0U0MzAwMRcwFQYDVQQDEw5DU0U0MzAwIElOVCBDQTB2MBAGByqG
SM49AgEGBSuBBAAiA2IABHLlFzJI6UxPq5HiuYJOcXhhsO02gYw9ov6fOzNklRWF
kMPD00LkVlksZDCsCMAFaNMCikYyaZGV2PapFxHlnEA8PvH5Guh9w4WInhxbnzr5
S5BLHK3KNNpOaUvCZ4zj+6NmMGQwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8B
Af8EBAMCAQYwHQYDVR0OBBYEFFvWNjSXJ01k734Y6eDo/umGDpSPMB8GA1UdIwQY
MBaAFIhcSMi0/zyUBXtC12rul69HM0R1MAoGCCqGSM49BAMEA2gAMGUCMCCJKRBN
Ru12yPI+bY7MzZBwmbLOLelLH+QBlDqZ06rrcV/bbW+OKEEih5ZllpjQhwIxAKX7
gjvEr/bwKihlAcoT+3aRzHrLaxs1EhD25Qhq+tHg0zze8d1VucuQpdpOjjOOiA==
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/siteBCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB+TCCAX+gAwIBAgIIFJyrl+cYH5owCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIyMTIwNTAwNTkxM1oXDTI1MDYwNTAwNTkxM1owRTELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxJDAiBgNVBAMTG0NTRTQzMDAgU2l0ZSBCIDE3Mi4xOC4x
OC4xODB2MBAGByqGSM49AgEGBSuBBAAiA2IABB4L4zIqLSBByoyndHUp1YKkklcP
gjOVdzvON2ACTQ8OLeDTp6umjW3R978q964MyL8Rl9b7TlOPz3qZQCU5VX7AN0CX
ostgZ/O02K+1qktmbr+rkR2set2S0ks1O/UtdaNJMEcwHwYDVR0jBBgwFoAUW9Y2
NJcnTWTvfhjp4Oj+6YYOlI8wDwYDVR0RBAgwBocErBISEjATBgNVHSUEDDAKBggr
BgEFBQcDAjAKBggqhkjOPQQDBANoADBlAjEAqfuq1nxYOwbfGAvlrKr5i/D9hssd
JQPiJxtRmlHbLND6fbeLboCrnYDqSlP8f1jbAjBinPqhY5sbcM2DQhgqq18HjYXT
yEUHdDIXy/3oMGT3+uZViZq9FygdyXMYANwoolM=
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/cloudCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB+DCCAX6gAwIBAgIIfnHbZk6FFuMwCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIyMTIwNTAwNTkxM1oXDTI1MDYwNTAwNTkxM1owRDELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxIzAhBgNVBAMTGkNTRTQzMDAgQ2xvdWQgMTcyLjMwLjMw
LjMwMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEQAGyaIYhQAWim5Ebyd87gGx5dxIl
gk8aG8SlVftBU3O9jqleCiSZAtJutCstjKoUrUBrMyuJ5y6+15Qc3HASRXiDJFeJ
oovMLPG42J73InwpiFYPh8t1GVBBOWYf6psjo0kwRzAfBgNVHSMEGDAWgBRb1jY0
lydNZO9+GOng6P7phg6UjzAPBgNVHREECDAGhwSsHh4eMBMGA1UdJQQMMAoGCCsG
AQUFBwMBMAoGCCqGSM49BAMEA2gAMGUCMQDUlsq4yUYUmxCx9IO0bgkDTPTSI94B
q9xB/8GWRpGpOsBGoLxo8yTATk6yYZn4Z7sCMChlDqVxhd0LF6asyYr9lFJ5YZxk
N5c8LVn/1tuP6vr8rkUIDVi2ey4wN31nF+m0rw==
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/private/siteBKey.pem <<EOL
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDCCKXLyf3tj3zzcZBsm3woMICXx2qqFTrFE71EdqbrHkeMATw1DM2eR
omEcWYSSZkCgBwYFK4EEACKhZANiAAQeC+MyKi0gQcqMp3R1KdWCpJJXD4IzlXc7
zjdgAk0PDi3g06erpo1t0fe/KveuDMi/EZfW+05Tj896mUAlOVV+wDdAl6LLYGfz
tNivtapLZm6/q5EdrHrdktJLNTv1LXU=
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
        left=172.18.18.18
        leftsubnet=10.2.0.0/16
        leftid=172.18.18.18
        leftcert=siteBCert.pem
        leftid="C=FI, O=CSE4300, CN=CSE4300 Site B 172.18.18.18"
        leftca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        right=172.30.30.30
        rightsubnet=10.3.0.0/16
        rightcert=cloudCert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Cloud 172.30.30.30"
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
