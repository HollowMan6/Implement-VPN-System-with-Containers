#! /bin/bash
# This script is run on gateway-a when it boots up

## Disable IPv4
# intranet_a
ip -4 addr flush dev eth0
# isp_link_a
ip -4 addr flush dev eth1

## NAT traffic going to the internet
route -6 add default gw fc00:4300:aaea::2
ip6tables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

## Bind the IP address of original local server to the interface
ip -6 addr add fc00:4300:a::99/64 dev eth0

## Redirect to cloud with Destination NAT
ip6tables -t nat -A PREROUTING -p tcp -d fc00:4300:a::99 --dport 8080 -j DNAT --to [fc00:4300:c::3]:8080

## Allow VPN traffic to the cloud
ip6tables -t nat -I POSTROUTING -d fc00:4300:c::3 -j ACCEPT

## Iptables rules (strict firewall)
### Accept IKE and esp traffic from/to the cloud
ip6tables -A INPUT -i eth1 -p udp -s fc00:4300:aaec::aaec --sport 500 -d fc00:4300:aaea::aaea --dport 500 -j ACCEPT
ip6tables -A INPUT -i eth1 -p udp -s fc00:4300:aaec::aaec --sport 4500 -d fc00:4300:aaea::aaea --dport 4500 -j ACCEPT
ip6tables -A INPUT -i eth1 -p esp -s fc00:4300:aaec::aaec -d fc00:4300:aaea::aaea -j ACCEPT
ip6tables -A INPUT -p icmpv6 -j ACCEPT
ip6tables -A OUTPUT -o eth1 -p udp -s fc00:4300:aaea::aaea --sport 500 -d fc00:4300:aaec::aaec --dport 500 -j ACCEPT
ip6tables -A OUTPUT -o eth1 -p udp -s fc00:4300:aaea::aaea --sport 4500 -d fc00:4300:aaec::aaec --dport 4500 -j ACCEPT
ip6tables -A OUTPUT -o eth1 -p esp -s fc00:4300:aaea::aaea -d fc00:4300:aaec::aaec -j ACCEPT
ip6tables -A OUTPUT -p icmpv6 -j ACCEPT
### Drop everything else (including Internet traffic)
ip6tables -A INPUT -j DROP
ip6tables -A OUTPUT -j DROP
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

## Stop internet traffic
ip6tables -A FORWARD -j DROP
iptables -A FORWARD -j DROP

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

cat > /etc/ipsec.d/private/siteAKey.pem <<EOL
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDAqlQMKts+vo0t75pdlbsPGdO79IByXcIPNe4o+VM4RHP1GnVT5/e4q
RX5I/yCoVeSgBwYFK4EEACKhZANiAASy8JO27i32wJyE52d9EF5r5k438evuG794
8XW2xytU+4IHBvAOMoCwHgyt67OTu/dFrpa7L+AZuGO8b//PE0crYchKz2V2yet8
TK8ckClBNXt7kpkB560TbUTdowrYsQ0=
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
        left=fc00:4300:aaea::aaea
        leftsubnet=fc00:4300:a::/64
        leftid=fc00:4300:aaea::aaea
        leftcert=siteACert.pem
        leftid="C=FI, O=CSE4300, CN=CSE4300 Site A fc00:4300:aaea::aaea"
        leftca="C=FI, O=CSE4300, CN=CSE4300 Root CA"
        right=fc00:4300:aaec::aaec
        rightsubnet=fc00:4300:c::/64
        rightcert=cloudCert.pem
        rightid="C=FI, O=CSE4300, CN=CSE4300 Cloud fc00:4300:aaec::aaec"
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
