#!/bin/bash
# Shut down all traffic
iptables -P FORWARD DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP

# Delete any existing chains
iptables -F
iptables -X

# Load any special kernel modules.
# Loading kernel modules.
modprobe ip_conntrack_ftp

# Setting kernel parameters.
# Turn on kernel IP spoof protection
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts 2> /dev/null
# Set the TCP timestamps config
echo 0 > /proc/sys/net/ipv4/tcp_timestamps 2> /dev/null
# Enable TCP SYN Cookie Protection if available
test -e /proc/sys/net/ipv4/tcp_syncookies && echo 1 > /proc/sys/net/ipv4/tcp_syncookies 2> /dev/null
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route 2> /dev/null
echo 0 > /proc/sys/net/ipv4/conf/default/accept_source_route 2> /dev/null
# Log truly weird packets.
echo 1 > /proc/sys/net/ipv4/conf/all/log_martians 2> /dev/null
echo 1 > /proc/sys/net/ipv4/conf/default/log_martians 2> /dev/null


# Configuring firewall rules.
# Set up our logging and packet 'executing' chains
iptables -N logdrop2
iptables -A logdrop2 -j LOG --log-prefix "DROPPED " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence 
iptables -A logdrop2 -j DROP
iptables -N logdrop
iptables -A logdrop -m limit --limit 1/second --limit-burst 10 -j logdrop2
iptables -A logdrop -m limit --limit 2/minute --limit-burst 1 -j LOG --log-prefix "LIMITED " --log-level 4
iptables -A logdrop -j DROP
iptables -N logreject2
iptables -A logreject2 -j LOG --log-prefix "REJECTED " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence 
iptables -A logreject2 -p tcp -j REJECT --reject-with tcp-reset
iptables -A logreject2 -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A logreject2 -j DROP
iptables -N logreject
iptables -A logreject -m limit --limit 1/second --limit-burst 10 -j logreject2
iptables -A logreject -m limit --limit 2/minute --limit-burst 1 -j LOG --log-prefix "LIMITED " --log-level 4
iptables -A logreject -p tcp -j REJECT --reject-with tcp-reset
iptables -A logreject -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A logreject -j DROP
iptables -N logaborted2
iptables -A logaborted2 -j LOG --log-prefix "ABORTED " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence 
iptables -A logaborted2 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -N logaborted
iptables -A logaborted -m limit --limit 1/second --limit-burst 10 -j logaborted2
iptables -A logaborted -m limit --limit 2/minute --limit-burst 1 -j LOG --log-prefix "LIMITED " --log-level 4

# Allow loopback traffic.
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Detect aborted TCP connections.
iptables -A INPUT -m state --state ESTABLISHED,RELATED -p tcp --tcp-flags RST RST -j logaborted
# Quickly allow anything that belongs to an already established connection.
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow certain critical ICMP types
iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT  # Dest unreachable
iptables -A OUTPUT -p icmp --icmp-type destination-unreachable -j ACCEPT # Dest unreachable
iptables -A FORWARD -p icmp --icmp-type destination-unreachable -j ACCEPT &> /dev/null  # Dest unreachable
iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT            # Time exceeded
iptables -A OUTPUT -p icmp --icmp-type time-exceeded -j ACCEPT           # Time exceeded
iptables -A FORWARD -p icmp --icmp-type time-exceeded -j ACCEPT &> /dev/null # Time exceeded
iptables -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT        # Parameter Problem
iptables -A OUTPUT -p icmp --icmp-type parameter-problem -j ACCEPT       # Parameter Problem
iptables -A FORWARD -p icmp --icmp-type parameter-problem -j ACCEPT &> /dev/null # Parameter Problem


# Create the filter chains
# Create chain to filter traffic going from 'Internet' to 'Local'
iptables -N f0to1
# Create chain to filter traffic going from 'Local' to 'Internet'
iptables -N f1to0
# Add rules to the filter chains

# Traffic from 'Internet' to 'Local'

# Rejected traffic from 'Internet' to 'Local'

# Traffic from 'Local' to 'Internet'
# Allow 'smtp'
iptables -A f1to0 -p tcp --sport 1024:5999 --dport 25:25 -m state --state NEW -j ACCEPT
# Allow 'ping'
# Echo Request
iptables -A f1to0 -p icmp --icmp-type echo-request -j ACCEPT
# Echo reply
iptables -A f0to1 -p icmp --icmp-type echo-reply -j ACCEPT
# Allow 'imaps'
iptables -A f1to0 -p tcp --sport 1024:5999 --dport 993:993 -m state --state NEW -j ACCEPT
# Allow 'microsoft-ds'
# SMB over TCP
iptables -A f1to0 -p tcp --sport 0:65535 --dport 445:445 -m state --state NEW -j ACCEPT
# Allow 'https'
iptables -A f1to0 -p tcp --sport 1024:5999 --dport 443:443 -m state --state NEW -j ACCEPT
# Allow 'http'
iptables -A f1to0 -p tcp --sport 1024:5999 --dport 80:80 -m state --state NEW -j ACCEPT
iptables -A f1to0 -p tcp --sport 1024:5999 --dport 8080:8080 -m state --state NEW -j ACCEPT
iptables -A f1to0 -p tcp --sport 1024:5999 --dport 8008:8008 -m state --state NEW -j ACCEPT
iptables -A f1to0 -p tcp --sport 1024:5999 --dport 8000:8000 -m state --state NEW -j ACCEPT
iptables -A f1to0 -p tcp --sport 1024:5999 --dport 8888:8888 -m state --state NEW -j ACCEPT
# Allow 'ssh'
# Normal connection
iptables -A f1to0 -p tcp --sport 1024:5999 --dport 22:22 -m state --state NEW -j ACCEPT
# privileged source port (rhosts compat.)
iptables -A f1to0 -p tcp --sport 0:1023 --dport 22:22 -m state --state NEW -j ACCEPT
# Allow 'imap'
iptables -A f1to0 -p tcp --sport 1024:5999 --dport 143:143 -m state --state NEW -j ACCEPT
iptables -A f1to0 -p udp --sport 0:65535 --dport 143:143 -j ACCEPT
# Allow 'ftp'
# Control connection
iptables -A f1to0 -p tcp --sport 1024:5999 --dport 21:21 -m state --state NEW -j ACCEPT
# Data connection
#  - Handled by netfilter state tracking
# Data connection passive mode
#  - Handled by netfilter state tracking
# Allow 'pop3s'
iptables -A f1to0 -p tcp --sport 1024:5999 --dport 995:995 -m state --state NEW -j ACCEPT
# Allow 'domain'
iptables -A f1to0 -p tcp --sport 0:65535 --dport 53:53 -m state --state NEW -j ACCEPT
iptables -A f1to0 -p udp --sport 0:65535 --dport 53:53 -j ACCEPT

# Place DROP and log rules at the end of our filter chains.
# Failing all the rules above, we log and DROP the packet.
iptables -A f0to1 -j logdrop
# Failing all the rules above, we log and DROP the packet.
iptables -A f1to0 -j logdrop

