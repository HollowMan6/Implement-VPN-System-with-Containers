#! /bin/bash
# This script is run on server-s1 when it boots up

## Traffic going to the internet
route add default gw 10.3.0.2

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Install app
cp -r /apps/server_app /server_app
cd /server_app
npm install

node server.js
