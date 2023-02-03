#! /bin/bash
# This script is run on client-*1 when it boots up

# Set up the network interface
# intranet_*
ifconfig eth0 10.1.0.2 netmask 255.255.0.0 broadcast 10.1.255.255

## Traffic going to the internet
route add default gw 10.1.0.1

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## The app is pre-installed
cp -r /apps/client_app /client_app
cd /client_app
FILE=node_modules.tar.xz
if test -f "$FILE"; then
    tar -xvf $FILE
    rm $FILE
fi

# Prevent the container from exiting
while true; do
    sleep 60
done
