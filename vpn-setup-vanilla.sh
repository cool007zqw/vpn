#!/bin/bash -x

#
# drewsymo/VPN
#
# Installs a PPTP VPN-only system for CentOS
#
# @package VPN 2.0
# @since VPN 1.0
# @author Drew Morris
# @mod by ZENO

(

VPN_IP=`curl ipv4.icanhazip.com>/dev/null 2>&1`

VPN_USER="test"
VPN_PASS="test"

VPN_LOCAL="192.168.0.150"
VPN_REMOTE="192.168.0.151-200"
PUB_IP="27.255.66.50"

rpm -i http://poptop.sourceforge.net/yum/stable/rhel6/pptp-release-current.noarch.rpm
yum -y install ppp pptpd


echo "localip $VPN_LOCAL" >> /etc/pptpd.conf # Local IP address of your VPN server
echo "remoteip $VPN_REMOTE" >> /etc/pptpd.conf # Scope for your home network

echo "$VPN_USER pptpd $VPN_PASS *" >> /etc/ppp/chap-secrets

echo "1" > /proc/sys/net/ipv4/ip_forward

echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd # Google DNS Primary
echo "ms-dns 209.244.0.3" >> /etc/ppp/options.pptpd # Level3 Primary
echo "ms-dns 208.67.222.222" >> /etc/ppp/options.pptpd # OpenDNS Primary

sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf

sysctl -p

iptables -A INPUT -i venet0 -p tcp --dport 1723 -j ACCEPT
iptables -A INPUT -i venet0 -p gre -j ACCEPT
iptables -t nat -A POSTROUTING -j SNAT --to-source $VPN_LOCAL
iptables -A FORWARD -i ppp0 -o venet0 -j ACCEPT
iptables -A FORWARD -i venet0 -o ppp0 -j ACCEPT
service iptables save
service iptables restart

iptables -t nat -I PREROUTING -d $PUB_IP -p 47 -j DNAT --to $VPN_LOCAL
iptables -I FORWARD -d $VPN_LOCAL -p 47 -j ACCEPT
service pptpd restart
chkconfig pptpd on

echo -e '\E[37;44m'"\033[1m Installation Log: /var/log/vpn-installer.log \033[0m"
echo -e '\E[37;44m'"\033[1m You can now connect to your VPN via your external IP ($VPN_IP)\033[0m"

echo -e '\E[37;44m'"\033[1m Username: $VPN_USER\033[0m"
echo -e '\E[37;44m'"\033[1m Password: $VPN_PASS\033[0m"

) 2>&1 | tee /var/log/vpn-installer.log
