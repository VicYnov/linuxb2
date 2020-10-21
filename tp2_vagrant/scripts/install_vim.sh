#!/bin/bash

sudo yum update

sudo yum install -y vim

sudo yum remove -y firewalld

sudo yum install -y iptables iptables-services

sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

sudo iptables -A INPUT -p tcp -i eth0 --dport ssh -j ACCEPT

sudo iptables -P INPUT DROP

sudo service iptables save

sudo systemctl enable iptables
