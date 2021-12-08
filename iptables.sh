#!/bin/sh

IPTABLES=/sbin/iptables
MODPROBE=/sbin/modprobe
INT_NET=10.0.0.0/8
INT_NIC=enp0s3
EXT_NIC=enp0s8

echo '[+] Loading connection tracking modules...'
$MODPROBE ip_conntrack
$MODPROBE ip_conntrack_ftp
$MODPROBE ip_nat_ftp


echo '[+] Flushing existing iptables rules...'
$IPTABLES -F
$IPTABLES -F -t nat
$IPTABLES -X
$IPTABLES -P FORWARD DROP
$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT DROP

echo '[+] Setting up INPUT chain...'
### state tracking ###
$IPTABLES -A INPUT -m state --state INVALID -j LOG --log-prefix "(INPUT) DROP INVALID " \
  --log-ip-options --log-tcp-options
$IPTABLES -A INPUT -m state --state INVALID -j DROP
$IPTABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

### anti-spoofing rules ###
$IPTABLES -A INPUT -i $INT_NIC ! -s $INT_NET -j LOG --log-prefix "(INPUT) SPOOFED  " 
$IPTABLES -A INPUT -i $INT_NIC ! -s $INT_NET -j DROP

### ACCEPT rules ###
$IPTABLES -A INPUT -i $EXT_NIC -p tcp  --dport 22 -j ACCEPT

$IPTABLES -A INPUT -i $INT_NIC -p tcp -s $INT_NET --dport 22 --syn -m state \
  --state NEW -j ACCEPT
$IPTABLES -A INPUT -i $INT_NIC -p udp -s $INT_NET --dport 53 -m state --state NEW -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

### default INPUT LOG rule ###
$IPTABLES -A INPUT ! -i lo -j LOG --log-prefix "(INPUT) DROP  " --log-ip-options --log-tcp-options


echo '[+] Settting up OUTPUT chain....'
### state tracking ###
$IPTABLES -A OUTPUT -m state --state INVALID -j LOG --log-prefix \
  "(OUTPUT) DROP INVALID " --log-ip-options --log-tcp-options
$IPTABLES -A OUTPUT -m state --state INVALID -j DROP
$IPTABLES -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

### ACCEPT rules ###
# ftp:21,ssh:22,smtp:25,whois:43,http:80,https:443,dns:53
$IPTABLES -A OUTPUT -p tcp --dport 21 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 22 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 25 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 43 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 80 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 443 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

### default OUTPUT LOG rule ###
$IPTABLES -A OUTPUT -j LOG --log-prefix "(OUTPUT) DROP  " --log-ip-options --log-tcp-options


echo '[+] Setting up FORWARD chain...'
### state tracking ###
$IPTABLES -A FORWARD -m state --state INVALID -j LOG --log-prefix \
  "(FORWARD) DROP INVALID " --log-ip-options --log-tcp-options
$IPTABLES -A FORWARD -m state --state INVALID -j DROP
$IPTABLES -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

### anti-spoofing rules ###
$IPTABLES -A FORWARD -i $INT_NIC ! -s $INT_NET -j LOG --log-prefix "(FORWARD) SPOOFED " 
$IPTABLES -A FORWARD -i $INT_NIC ! -s $INT_NET -j DROP

### ACCEPT rules ###
# ftp:21,ssh:22,smtp:25,whois:43,http:80,https:443,dns:53
$IPTABLES -A FORWARD -p tcp -i $INT_NIC -s $INT_NET --dport 21 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp -i $INT_NIC -s $INT_NET --dport 22 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp -i $INT_NIC -s $INT_NET --dport 25 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp -i $INT_NIC -s $INT_NET --dport 43 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp -i $INT_NIC -s $INT_NET --dport 80 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp -i $INT_NIC -s $INT_NET --dport 443 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A FORWARD -p udp -i $INT_NIC -s $INT_NET --dport 53 -m state --state NEW -j ACCEPT
$IPTABLES -A FORWARD -p icmp --icmp-type echo-request -j ACCEPT

### default FORWARD LOG rule ###
$IPTABLES -A FORWARD -j LOG --log-prefix "(FORWARD) DROP  " --log-ip-options --log-tcp-options


### NAT rules ###
echo '[+] Setting up NAT rules...'
$IPTABLES -t nat -A POSTROUTING -s $INT_NET -o $EXT_NIC -j MASQUERADE


### forwarding ###
echo '[+] Enabling IP forwarding...'
echo 1 > /proc/sys/net/ipv4/ip_forward
