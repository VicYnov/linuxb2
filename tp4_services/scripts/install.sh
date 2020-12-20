#!/bin/bash
#VictorYnov

yum update

yum install -y vim

yum remove -y firewalld

yum install -y iptables iptables-services

iptables -A INPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

iptables -A INPUT -p tcp -i eth0 --dport ssh -j ACCEPT

iptables -P INPUT DROP

service iptables save

systemctl enable iptables

echo -e "
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=minimum
" > /etc/selinux/conf