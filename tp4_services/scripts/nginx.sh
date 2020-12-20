#!/bin/bash

yum install -y epel-release
yum install -y nginx

bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait
sed -i "/DISCORD_WEBHOOK_URL=/c\DISCORD_WEBHOOK_URL='https://discord.com/channels/760165742036516866/760165742620180502'" /usr/lib/netdata/conf.d/health_alarm_notify.conf

## Firewall
iptables -A INPUT -p tcp -i eth1 --dport 80 -j ACCEPT
iptables -P INPUT DROP
service iptables save
systemctl enable iptables

cp /vagrant/fichier_to_move/hosts /etc
cp /vagrant/systemd/confs/nginx.conf /etc/nginx

systemctl start nginx

yum install -y nfs-utils nfs-utils-lib

mkdir /partage
mkdir -p /partage/nginx
mount 192.168.4.14:/saves/nginx /partage/nginx