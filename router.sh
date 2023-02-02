#! /bin/bash
# This script is run on router when it boots up

# Set up the network interface
# default: eth0
# isp_link_a
ifconfig eth1 172.16.16.1 netmask 255.255.255.0 broadcast 172.16.16.255
# isp_link_b
ifconfig eth2 172.18.18.1 netmask 255.255.255.0 broadcast 172.18.18.255
# isp_link_s
ifconfig eth3 172.30.30.1 netmask 255.255.255.0 broadcast 172.30.30.255

## NAT traffic going to the internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

## Route 172.30.0.0/16 all via gateway-s
route add -net 172.48.48.48 netmask 255.255.255.240 gw 172.30.30.30 eth3

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

# Prevent the container from exiting
while true; do
    sleep 60
done
