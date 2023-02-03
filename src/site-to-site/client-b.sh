#! /bin/bash
# This script is run on client-b* when it boots up

## Traffic going to the internet
route add default gw 10.2.0.2

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

cat > config.json <<EOL
{
  "server_ip": "10.2.0.99",
  "server_port": "8080",
  "log_file": "/var/log/client.log"
}
EOL

# Prevent the container from exiting
while true; do
    sleep 60
done
