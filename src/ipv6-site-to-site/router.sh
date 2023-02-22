#! /bin/bash
# This script is run on router when it boots up

## Disable IPv4
# default: eth0
# isp_link_a
ip -4 addr flush dev eth1
# isp_link_b
ip -4 addr flush dev eth2
# isp_link_s
ip -4 addr flush dev eth3
ip addr add 172.30.30.1/24 dev eth3

## NAT traffic going to the internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

# Prevent the container from exiting
while true; do
    sleep 60
done
