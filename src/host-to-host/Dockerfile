FROM ubuntu:22.04

# Set iptables-persistent
RUN echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
RUN echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections

# Install and upgrade
RUN apt-get update -y --fix-missing
RUN apt-get install -f
RUN apt-get -y dist-upgrade

# Install tools for networking
RUN apt-get install -y dialog debconf-utils apt-utils iputils-ping iptables iputils-tracepath traceroute netcat conntrack nmap wget rsync iptables-persistent > /dev/null

# Install IPsec tools
RUN apt-get install -y strongswan moreutils libstrongswan-extra-plugins > /dev/null

# Install libs
RUN apt-get install -y net-tools locate vim nano tcpdump dnsutils traceroute curl git-core bzip2 conntrack xz-utils > /dev/null

# Add node16 repository
RUN curl -s https://deb.nodesource.com/setup_16.x | bash
RUN apt-get install -y nodejs 

ENTRYPOINT [ "/start.sh" ]
