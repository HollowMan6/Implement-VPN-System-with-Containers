FROM ubuntu:22.04

RUN apt-get update
# Install tools for networking
RUN apt-get -y install dialog debconf-utils apt-utils iputils-ping iptables\
  iputils-tracepath traceroute netcat conntrack nmap wget rsync

# Install IPsec tools
RUN apt-get -y install strongswan moreutils libstrongswan-extra-plugins

# Install iptables-persistent
RUN echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
RUN echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
RUN apt-get install -y iptables-persistent

# Install libs
RUN apt-get install -y net-tools locate vim nano tcpdump dnsutils traceroute\
  curl git-core bzip2 npm nodejs conntrack

ENTRYPOINT [ "/start.sh" ]
