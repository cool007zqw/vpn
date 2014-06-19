rpm -i http://poptop.sourceforge.net/yum/stable/rhel6/pptp-release-current.noarch.rpm
yum install -y pptpd

#echo "1" > /proc/sys/net/ipv4/ip_forward 
#sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf


echo "localip 10.224.43.15" >> /etc/pptpd.conf # Local IP address of your VPN server 
echo "remoteip 10.224.43.210-224" >> /etc/pptpd.conf # Scope for your home network

echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd # Google DNS Primary 
echo "ms-dns 209.244.0.3" >> /etc/ppp/options.pptpd # Level3 Primary 
echo "ms-dns 208.67.222.222" >> /etc/ppp/options.pptpd # OpenDNS Primary

echo "test * test *" >> /etc/ppp/chap-secrets
sysctl -p


 "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >> /etc/rc.local 
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE 
iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables save 

service pptpd restart
