#! /bin/bash
# This script is run on router when it boots up

## NAT traffic going to the internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

# Prevent the container from exiting
while true; do
    sleep 60
done
