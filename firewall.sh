#!/bin/bash
# Load the connection tracker kernel module
modprobe ip_conntrack

# Drop old rules
iptables -F
iptables -X
iptables -Z

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
 
# Drop invalid packets
iptables -A INPUT  -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP

# Always accep loopback interface
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established, related packets
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Output chain
iptables -A OUTPUT -p tcp -m tcp --dport 22 -m comment --comment "SSH" -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 53 -m comment --comment "DNS-TCP" -j ACCEPT #Maybe not useful
iptables -A OUTPUT -p udp -m udp --dport 53 -m comment --comment "DNS-UDP" -j ACCEPT
iptables -A OUTPUT -p udp -m udp --dport 67:68 -m comment --comment "DHCP" -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 80 -m comment --comment "HTTP" -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 443 -m comment --comment "HTTPS" -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# Vpn
iptables -A OUTPUT -j ACCEPT -o wlp4s0 -p udp -m udp --dport 1194
iptables -A INPUT -j ACCEPT -i wlp4s0 -p udp -m udp --sport 1194
iptables -A OUTPUT -j ACCEPT -o ens9 -p udp -m udp --dport 1194
iptables -A INPUT -j ACCEPT -i ens9 -p udp -m udp --sport 1194
iptables -A INPUT -j ACCEPT -i tun0
iptables -A OUTPUT -j ACCEPT -o tun0
