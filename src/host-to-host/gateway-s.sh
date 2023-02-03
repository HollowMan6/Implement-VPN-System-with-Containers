#! /bin/bash
# This script is run on gateway-s when it boots up

# Set up the network interface
# cloud_network_s
ifconfig eth0 10.1.0.1 netmask 255.255.0.0 broadcast 10.1.255.255
# isp_link_s
ifconfig eth1 172.30.30.30 netmask 255.255.255.0 broadcast 172.30.30.255

## Traffic going to the internet
route add default gw 172.30.30.1

## NAT Masquerade for eth1
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

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

cat > /etc/ipsec.d/certs/siteACert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB+TCCAX+gAwIBAgIIOnvDkxgfobIwCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIyMTIwNTAwNTkxM1oXDTI1MDYwNTAwNTkxM1owRTELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxJDAiBgNVBAMTG0NTRTQzMDAgU2l0ZSBBIDE3Mi4xNi4x
Ni4xNjB2MBAGByqGSM49AgEGBSuBBAAiA2IABEjnLhPKue7JQGcgCmyj8hEriQFI
EaRq7vKkmKmev6AWGVnHGCvRFrfO3KRk+G03+gtDjSX/SWIgs6kcb2olEeQQWA6h
nxHMxxbLYu3bqk5Jb9tDR3zRXpa7oUROIP0Xz6NJMEcwHwYDVR0jBBgwFoAUW9Y2
NJcnTWTvfhjp4Oj+6YYOlI8wDwYDVR0RBAgwBocErBAQEDATBgNVHSUEDDAKBggr
BgEFBQcDAjAKBggqhkjOPQQDBANoADBlAjEA+glFd8LPloJfASITJ7qSX8yrO4ZT
hFpu5CU+fVgTjQ7F2jR7DmNWerrDoAI4Nh1xAjBHAUweTg/hZwndL0VbWDuYzdRh
Uum9LEia8lYuoU+VwMo9pKwPWfN3OepgCeK3Otw=
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

cat > /etc/ipsec.d/private/cloudKey.pem <<EOL
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDAxLt5tXh4sYn5OtW96vNlmIkk6TS3VdytHVwGfTuwZO+6DWEDG65nF
0K36QlKkp8KgBwYFK4EEACKhZANiAARAAbJohiFABaKbkRvJ3zuAbHl3EiWCTxob
xKVV+0FTc72OqV4KJJkC0m60Ky2MqhStQGszK4nnLr7XlBzccBJFeIMkV4mii8ws
8bjYnvcifCmIVg+Hy3UZUEE5Zh/qmyM=
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

## Destination NAT from client to server when using VPN, and remove the rule when disconnected
cat > /etc/ipsec_updown.sh <<EOL
#! /bin/sh
case "\$PLUTO_VERB:\$1" in
up-host:|up-client:)
  iptables -t nat -A PREROUTING -i eth1 -p tcp -s 172.16.16.16 --dport 8080 -j DNAT --to-destination 10.1.0.2:8080
  iptables -t nat -A PREROUTING -i eth1 -p tcp -s 172.18.18.18 --dport 8080 -j DNAT --to-destination 10.1.0.2:8080
  ;;
down-host:|down-client:)
  iptables -t nat -D PREROUTING -i eth1 -p tcp -s 172.16.16.16 --dport 8080 -j DNAT --to-destination 10.1.0.2:8080
  iptables -t nat -D PREROUTING -i eth1 -p tcp -s 172.18.18.18 --dport 8080 -j DNAT --to-destination 10.1.0.2:8080
  ;;
esac
EOL

chmod +x /etc/ipsec_updown.sh

cat > /etc/ipsec.conf <<EOL
conn %default
        keyexchange=ikev2
        left=172.30.30.30
        leftsubnet=172.30.30.30/32
        leftcert=cloudCert.pem
        leftid="C=FI, O=CSE4300, CN=CSE4300 Cloud 172.30.30.30"
        leftca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        leftupdown=/etc/ipsec_updown.sh
        rightca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        rightupdown=/etc/ipsec_updown.sh
        ike=aes256gcm16-prfsha384-ecp384!
        esp=aes256gcm16-ecp384!
        auto=start
        dpdaction=hold
conn cloud-to-a
        also=%default
        right=172.16.16.16
        rightsubnet=172.16.16.16/32
        rightcert=siteACert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Site A 172.16.16.16"
conn cloud-to-b
        also=%default
        right=172.18.18.18
        rightsubnet=172.18.18.18/32
        rightcert=siteBCert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Site B 172.18.18.18"
EOL

## Start ipsec for updates to take effect
ipsec start

# Prevent the container from exiting
while true; do
    sleep 60
done
