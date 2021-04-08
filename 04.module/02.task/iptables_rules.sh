#!/bin/bash

# Define some variables
export IPT=iptables
export WAN=eth0
export LAN=eth1
export LAN_IP=$(hostname -I)

# Clear iptables chains 
$IPT -F
$IPT -F -t nat
$IPT -F -t mangle
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X

# Set up default policies for traffic that doesn't match any of the rules
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

# Allow local traffic for loopback
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

# Allow outgoing server connections
$IPT -A OUTPUT -o $WAN -j ACCEPT
$IPT -A OUTPUT -o $LAN -j ACCEPT

# Skip all already initiated ESTABLISHED connections, as well as their children for INPUT, OUTPUT, FORWARD
$IPT -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -p all -m state --state ESTABLISHED,RELATED -j ACCEPT

# Enable packet fragmentation. Required due to different MTU values
$IPT -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# Discard all packets that cannot be identified. Therefore cannot have a specific status.
$IPT -A INPUT -m state --state INVALID -j DROP
$IPT -A FORWARD -m state --state INVALID -j DROP

# Leads to the binding of system resources. The real data exchange becomes impossible, discard.
$IPT -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
$IPT -A OUTPUT -p tcp ! --syn -m state --state NEW -j DROP

# Allow pings
$IPT -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Open port for SSH
$IPT -A INPUT -i $WAN -p tcp --dport 22 -j ACCEPT
$IPT -A INPUT -i $LAN -p tcp --dport 22 -j ACCEPT

# Open port for DNS
$IPT -A INPUT -i $WAN -p udp --dport 53 -j ACCEPT
$IPT -A INPUT -i $WAN -p tcp --dport 53 -j ACCEPT
$IPT -A INPUT -i $LAN -p udp --dport 53 -j ACCEPT
$IPT -A INPUT -i $LAN -p tcp --dport 53 -j ACCEPT

# Save rules
/sbin/iptables-save > /etc/iptables.rules
