#! /bin/bash
# This script is run on server-s1 when it boots up

# Disable IPv4
# cloud_network_s
ip -4 addr flush dev eth0
ip addr add 10.1.0.2/16 dev eth0

## Traffic going to the internet
route add default gw 10.1.0.1
route -6 add default gw fc00:4300:c::2

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Install app
cp -r /apps/server_app /server_app
cd /server_app
npm install

node server.js
