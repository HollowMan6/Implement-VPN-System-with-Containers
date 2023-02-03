#! /bin/sh
# This script is run on server-s1 when it boots up

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

## Start docker
dockerd-entrypoint.sh &
wait-on socket:/var/run/docker.sock

## Start server
docker rm -f s1
docker rm -f s2
docker run -p 30000:8080 -d --name s1 -v $PWD:/app -w /app node:16 node server.js
docker run -p 30001:8080 -d --name s2 -v $PWD:/app -w /app node:16 node server.js

docker logs s1 --tail=0 --follow &
docker logs s2 --tail=0 --follow 
