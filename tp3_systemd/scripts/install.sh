#!/bin/bash

yum update

yum install -y vim

yum install -y epel-release

yum install -y nginx

yum remove -y firewalld

yum install -y iptables iptables-services

iptables -A INPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

iptables -A INPUT -p tcp -i eth0 --dport ssh -j ACCEPT

iptables -P INPUT DROP

service iptables save

systemctl enable iptables