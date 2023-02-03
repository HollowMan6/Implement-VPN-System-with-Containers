#! /bin/bash
# This script is run on router when it boots up

# Set up the network interface
# cloud_network_s
ifconfig eth0 10.1.0.2 netmask 255.255.0.0 broadcast 10.1.255.255

## Traffic going to the internet
route add default gw 10.1.0.1

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Install app
cp -r /apps/server_app /server_app
cd /server_app
npm install

node server.js

# Forget about the docker as then actually it is projecting the host machine network.
# ## Install docker
# apt install docker.io -y

# ## Start server
# docker run -p 8080:8080 -d -v $PWD:/app -w /app node:12.22.9 node server.js
# docker run -p 8080:8080 -d -v $PWD:/app -w /app node:12.22.9 node server.js
