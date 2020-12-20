#!/bin/bash
#VictorYnov

bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait
sed -i "/DISCORD_WEBHOOK_URL=/c\DISCORD_WEBHOOK_URL='https://discord.com/channels/760165742036516866/760165742620180502'" /usr/lib/netdata/conf.d/health_alarm_notify.conf

# SETUP BDD
yum install -y mariadb-server

iptables -A INPUT -p tcp -i eth1 --dport 3306 -j ACCEPT

systemctl enable mariadb.service
systemctl start mariadb.service

echo "bind-address = 192.168.4.12" >> /etc/my.cnf
mysql -h "localhost" "--user=root" "--password=" -e \
	"SET old_passwords=0;" -e \
	"CREATE USER 'gitea'@'192.168.4.12' IDENTIFIED BY 'gitea';" -e \
	"SET PASSWORD FOR 'gitea'@'192.168.4.12' = PASSWORD('gitea');" -e \
	"CREATE DATABASE giteadb2 CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';" -e \
	"grant all privileges on giteadb2.* to 'gitea'@'192.168.4.%' identified by 'gitea' with grant option;" -e \
	"FLUSH PRIVILEGES;"

systemctl restart mariadb.service

# SETUP NFS
yum install -y nfs-utils nfs-utils-lib

sudo mkdir /partage
sudo mkdir /partage/bdd
mount 192.168.4.14:/saves/bdd /partage/bdd

cp /vagrant/fichier_to_move/hosts /etc