#! /bin/bash
# This script is run on gateway-s when it boots up

## Disable IPv4
# cloud_network_s
ip -4 addr flush dev eth0
ip addr add 10.1.0.1/16 dev eth0
# isp_link_s
ip -4 addr flush dev eth1
ip addr add 172.30.30.30/24 dev eth1

## Traffic going to the internet
route add default gw 172.30.30.1
route -6 add default gw fc00:4300:aaec::2

## NAT Masquerade for eth1
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
ip6tables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

## Iptables rules (strict firewall)
### Accept IKE and esp traffic from/to the clients
ip6tables -A INPUT -i eth1 -p udp -s fc00:4300:aaea::aaea --sport 500 -d fc00:4300:aaec::aaec --dport 500 -j ACCEPT
ip6tables -A INPUT -i eth1 -p udp -s fc00:4300:aaea::aaea --sport 4500 -d fc00:4300:aaec::aaec --dport 4500 -j ACCEPT
ip6tables -A INPUT -i eth1 -p esp -s fc00:4300:aaea::aaea -d fc00:4300:aaec::aaec -j ACCEPT
ip6tables -A INPUT -i eth1 -p udp -s fc00:4300:aaeb::aaeb --sport 500 -d fc00:4300:aaec::aaec --dport 500 -j ACCEPT
ip6tables -A INPUT -i eth1 -p udp -s fc00:4300:aaeb::aaeb --sport 4500 -d fc00:4300:aaec::aaec --dport 4500 -j ACCEPT
ip6tables -A INPUT -i eth1 -p esp -s fc00:4300:aaeb::aaeb -d fc00:4300:aaec::aaec -j ACCEPT
ip6tables -A INPUT -p icmpv6 -j ACCEPT
ip6tables -A OUTPUT -o eth1 -p udp -s fc00:4300:aaec::aaec --sport 500 -d fc00:4300:aaea::aaea --dport 500 -j ACCEPT
ip6tables -A OUTPUT -o eth1 -p udp -s fc00:4300:aaec::aaec --sport 4500 -d fc00:4300:aaea::aaea --dport 4500 -j ACCEPT
ip6tables -A OUTPUT -o eth1 -p esp -s fc00:4300:aaec::aaec -d fc00:4300:aaea::aaea -j ACCEPT
ip6tables -A OUTPUT -o eth1 -p udp -s fc00:4300:aaec::aaec --sport 500 -d fc00:4300:aaeb::aaeb --dport 500 -j ACCEPT
ip6tables -A OUTPUT -o eth1 -p udp -s fc00:4300:aaec::aaec --sport 4500 -d fc00:4300:aaeb::aaeb --dport 4500 -j ACCEPT
ip6tables -A OUTPUT -o eth1 -p esp -s fc00:4300:aaec::aaec -d fc00:4300:aaeb::aaeb -j ACCEPT
ip6tables -A OUTPUT -p icmpv6 -j ACCEPT
### Drop everything else (including Internet traffic)
ip6tables -A INPUT -j DROP
ip6tables -A OUTPUT -j DROP
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Certificates
cat > /etc/ipsec.d/cacerts/caCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIIB5zCCAW2gAwIBAgIIXB055tpFUOcwCgYIKoZIzj0EAwQwOTELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxGDAWBgNVBAMTD0NTRTQzMDAgUm9vdCBDQTAe
Fw0yMzAyMjIxMzQyMDlaFw0zMzAyMjExMzQyMDlaMDkxCzAJBgNVBAYTAkZJMRAw
DgYDVQQKEwdDU0U0MzAwMRgwFgYDVQQDEw9DU0U0MzAwIFJvb3QgQ0EwdjAQBgcq
hkjOPQIBBgUrgQQAIgNiAARn3jF7bBuslozXKPRyiI8So6O+IHz0BZX3WuRP7f3o
/RPmvUR+5FiCEy/2eByt1ap+2BUOIHnRMj64Oizdff5uyjZ+KCzH4rCnoZPDMsZ5
aRyXuzNZuKlzyMsURYyUHASjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/
BAQDAgEGMB0GA1UdDgQWBBS8UM7Zn1LTUWszgEWEmpsAnUjv5DAKBggqhkjOPQQD
BANoADBlAjEA9f7SSlvw/6r3hkDcIDgXKmzxcSQYmO9FZHMcrSO2IUUvBTFv3hu5
J7Yw92cvJsDeAjBxbx6WYacDIF6ymPXhie6BvqPR3ERuSlYvp8hPIGb7kvxEK6XG
5V0Ecdr1Xnaew2Y=
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/cacerts/intCaCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIICCzCCAZCgAwIBAgIIA68LLJ6yPj4wCgYIKoZIzj0EAwQwOTELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxGDAWBgNVBAMTD0NTRTQzMDAgUm9vdCBDQTAe
Fw0yMzAyMjIxMzQyMDlaFw0yODAyMjIxMzQyMDlaMDgxCzAJBgNVBAYTAkZJMRAw
DgYDVQQKEwdDU0U0MzAwMRcwFQYDVQQDEw5DU0U0MzAwIElOVCBDQTB2MBAGByqG
SM49AgEGBSuBBAAiA2IABDFUTOnLtctUbwTTfKtslAGJl4+MiKYJ/ySamQqRbr69
1IKfC2GIkDkezBojhapWnpsFDt5a8Ho/F/A0g7rJe2+sZ8dAOCfo8CMWCMg95phn
4k+Zni8lxSOvV+n2hlebZ6NmMGQwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8B
Af8EBAMCAQYwHQYDVR0OBBYEFIUBWe3BJh3pgFI/bC1QglS21/a5MB8GA1UdIwQY
MBaAFLxQztmfUtNRazOARYSamwCdSO/kMAoGCCqGSM49BAMEA2kAMGYCMQCwYsd/
bFmxBLt7s+3orDJcNxzuhVWD/f8I00wW2CXD6WqGk0owvYMBCmUmBpXJE4kCMQC3
z0XiP68tJxT3rDMOIJJjojDaXAF2tjmJTyiGVW/T/VYGLcgI2APf6T9y25xKAhg=
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/siteACert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIICDTCCAZOgAwIBAgIIOclv6/pr4IIwCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIzMDIyMjEzNDIwOVoXDTI1MDgyMzEzNDIwOVowTTELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxLDAqBgNVBAMTI0NTRTQzMDAgU2l0ZSBBIGZjMDA6NDMw
MDphYWVhOjphYWVhMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEsvCTtu4t9sCchOdn
fRBea+ZON/Hr7hu/ePF1tscrVPuCBwbwDjKAsB4Mreuzk7v3Ra6Wuy/gGbhjvG//
zxNHK2HISs9ldsnrfEyvHJApQTV7e5KZAeetE21E3aMK2LENo1UwUzAfBgNVHSME
GDAWgBSFAVntwSYd6YBSP2wtUIJUttf2uTAbBgNVHREEFDAShxD8AEMAquoAAAAA
AAAAAKrqMBMGA1UdJQQMMAoGCCsGAQUFBwMCMAoGCCqGSM49BAMEA2gAMGUCME+L
0n8uqZfOlk3Kl+st0G356zE8JE9GTDp06kXc4rQGV0Z1d79k9fx+BSvV0YJ7qAIx
ALqNLXCeYlf2X48P214XpjfkDwvOkwzBpMJECCHPCjrFjE/BDiXtoqrHBAB9uIfo
AQ==
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/siteBCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIICDDCCAZOgAwIBAgIIGFFvyoSBE5cwCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIzMDIyMjEzNDIwOVoXDTI1MDgyMzEzNDIwOVowTTELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxLDAqBgNVBAMTI0NTRTQzMDAgU2l0ZSBCIGZjMDA6NDMw
MDphYWViOjphYWViMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAE+w9F4FoKyVPcb4d8
EzHY4CiFD5loOKrJmmKrWTdFD+J7uXusgN3LCE+hlhiYtSvGxYLaRoIoeGw3GG3H
wtvWkJS5ZtXQNMeXOZTO4q3vPs1WgdaF//paCfzT4pqKI5muo1UwUzAfBgNVHSME
GDAWgBSFAVntwSYd6YBSP2wtUIJUttf2uTAbBgNVHREEFDAShxD8AEMAqusAAAAA
AAAAAKrrMBMGA1UdJQQMMAoGCCsGAQUFBwMCMAoGCCqGSM49BAMEA2cAMGQCMGzj
mpEh3HdkBmHtc1TExw0zAtkt7XAkRa3lzkp8/7HhW5MRzSF3gkA7AsuUFHwI6AIw
BrWAzZNs/vup/Nl+tlDVMluLA7PRXkaLt2TrDm/G/TKDSgPGvAEeRF+pGQx1ltGA
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/certs/cloudCert.pem <<EOL
-----BEGIN CERTIFICATE-----
MIICCzCCAZKgAwIBAgIIZNZMfRFFcC0wCgYIKoZIzj0EAwQwODELMAkGA1UEBhMC
RkkxEDAOBgNVBAoTB0NTRTQzMDAxFzAVBgNVBAMTDkNTRTQzMDAgSU5UIENBMB4X
DTIzMDIyMjEzNDIwOVoXDTI1MDgyMzEzNDIwOVowTDELMAkGA1UEBhMCRkkxEDAO
BgNVBAoTB0NTRTQzMDAxKzApBgNVBAMTIkNTRTQzMDAgQ2xvdWQgZmMwMDo0MzAw
OmFhZWM6OmFhZWMwdjAQBgcqhkjOPQIBBgUrgQQAIgNiAAQ68VAEBBtJb01HzmvD
c03i8vEG9nil7+zW9tr2jSe/A3bj/oG+Tf0u10NufUw2mGdlNDrZdWMAae1XVwPg
4UhX1I+6/ueRyGiMYAUSmS5dxBlVjYjqMHt2pXwnVFLas8yjVTBTMB8GA1UdIwQY
MBaAFIUBWe3BJh3pgFI/bC1QglS21/a5MBsGA1UdEQQUMBKHEPwAQwCq7AAAAAAA
AAAAquwwEwYDVR0lBAwwCgYIKwYBBQUHAwEwCgYIKoZIzj0EAwQDZwAwZAIwZ2oD
s75hlLSZGeOZ4uQZR+k/n4STaHwthJD7qRiNqurUkUugaEp7rsdAgCrXPm15AjAN
n/LDsMoxjzt8bTJ/9Tulh6Pb0fuMb/bt/a/4poHRyRcu05Djy85fxFtMDJN+Gdc=
-----END CERTIFICATE-----
EOL

cat > /etc/ipsec.d/private/cloudKey.pem <<EOL
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDA694N/v2ub5Y8mjm5eFYqrhmTB4dn3uSRVoRa/LeXGZcdtnHGRKzID
KOZWpM5Z94WgBwYFK4EEACKhZANiAAQ68VAEBBtJb01HzmvDc03i8vEG9nil7+zW
9tr2jSe/A3bj/oG+Tf0u10NufUw2mGdlNDrZdWMAae1XVwPg4UhX1I+6/ueRyGiM
YAUSmS5dxBlVjYjqMHt2pXwnVFLas8w=
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
        left=fc00:4300:aaec::aaec
        leftsubnet=fc00:4300:c::/64
        leftcert=cloudCert.pem
        leftid="C=FI, O=CSE4300, CN=CSE4300 Cloud fc00:4300:aaec::aaec"
        leftca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        rightca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        ike=aes256gcm16-prfsha384-ecp384!
        esp=aes256gcm16-ecp384!
        auto=route
        dpdaction=hold
conn cloud-to-a
        also=%default
        right=fc00:4300:aaea::aaea
        rightsubnet=fc00:4300:a::/64
        rightcert=siteACert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Site A fc00:4300:aaea::aaea"
conn cloud-to-b
        also=%default
        right=fc00:4300:aaeb::aaeb
        rightsubnet=fc00:4300:b::/64
        rightcert=siteBCert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Site B fc00:4300:aaeb::aaeb"
EOL

## Start ipsec for updates to take effect
ipsec start

# Prevent the container from exiting
while true; do
    sleep 60
done
