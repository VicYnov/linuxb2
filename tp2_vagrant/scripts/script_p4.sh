#!/bin/bash

## Firewall
iptables -A INPUT -p tcp -i eth1 --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -i eth1 --dport 443 -j ACCEPT
iptables -P INPUT DROP
service iptables save
systemctl enable iptables

## User
useradd web -M -s /sbin/nologin

## Certificat

cp /vagrant/fichier_to_move/server.key /etc/pki/tls/private/node1.tp2.b2.key
chmod 400 /etc/pki/tls/private/node1.tp2.b2.key
chown web:web /etc/pki/tls/private/node1.tp2.b2.key

cp /vagrant/fichier_to_move/server.crt /etc/pki/tls/certs/node1.tp2.b2.crt
chmod 444 /etc/pki/tls/certs/node1.tp2.b2.crt
chown web:web /etc/pki/tls/certs/node1.tp2.b2.crt

## Les sites
mkdir /srv/site1
mkdir /srv/site2

echo '<h1>Hello from site 1</h1>' | tee /srv/site1/index.html
echo '<h1>Hello from site 2</h1>' | tee /srv/site2/index.html
chown web:web /srv/site1 -R
chown web:web /srv/site2 -R
chmod 700 /srv/site1 /srv/site2
chmod 400 /srv/site1/index.html /srv/site2/index.html

## Backup
yum install -y dos2unix
useradd backup -M -s /sbin/nologin

mkdir /srv/save_web
cp /vagrant/fichier_to_move/tp2_backup.sh /srv
cp /vagrant/fichier_to_move/backup /var/spool/cron

dos2unix /srv/tp2_backup.sh

chown backup /srv/save_web
chown backup /srv/tp2_backup.sh

chmod 755 /srv/save_web
chmod 755 /srv/tp2_backup.sh

cp /vagrant/fichier_to_move/nginx.conf /etc/nginx
systemctl start nginx
