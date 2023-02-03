#! /bin/bash
# This script is run on router when it boots up

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
