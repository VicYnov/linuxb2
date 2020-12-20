#!/bin/bash
#VictorYnov

yum install -y git
yum install -y dos2unix

bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait
sed -i "/DISCORD_WEBHOOK_URL=/c\DISCORD_WEBHOOK_URL='https://discord.com/channels/760165742036516866/760165742620180502'" /usr/lib/netdata/conf.d/health_alarm_notify.conf


iptables -A INPUT -p tcp -i eth1 --dport 3000 -j ACCEPT

curl -SLs https://dl.gitea.io/gitea/1.12.5/gitea-1.12.5-linux-amd64 -o gitea
chmod +x gitea

useradd git

mkdir -p /var/lib/gitea/{custom,data,log}
chown -R git:git /var/lib/gitea/
chmod -R 750 /var/lib/gitea/
mkdir /etc/gitea
chown root:git /etc/gitea
chmod 770 /etc/gitea

export GITEA_WORK_DIR=/var/lib/gitea/

cp gitea /usr/local/bin/gitea
chmod +x /usr/local/bin/gitea

cp /vagrant/systemd/units/gitea.service /etc/systemd/system
cp /vagrant/fichier_to_move/hosts /etc

dos2unix /etc/systemd/system/gitea.service

systemctl enable gitea
systemctl start gitea

yum install -y nfs-utils nfs-utils-lib

mkdir /partage
mkdir /partage/gitea
mount -t nfs4 192.168.4.14:/saves/gitea /partage/gitea