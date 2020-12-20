#!/bin/bash
#VictorYnov

bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait
sed -i "/DISCORD_WEBHOOK_URL=/c\DISCORD_WEBHOOK_URL='https://discord.com/channels/760165742036516866/760165742620180502'" /usr/lib/netdata/conf.d/health_alarm_notify.conf

mkdir /saves

mkdir /saves/gitea
mkdir /saves/bdd
mkdir /saves/nginx

chmod 777 /saves

yum install -y nfs-utils nfs-utils-lib
systemctl enable --now rpcbind
systemctl enable --now nfs

echo -e "
/saves/gitea   192.168.4.11(rw,sync,no_root_squash)
/saves/bdd   192.168.4.12(rw,sync,no_root_squash)
/saves/nginx   192.168.4.13(rw,sync,no_root_squash)
" > /etc/exports

exportfs -a

iptables -A INPUT -p tcp -i eth1 --dport mountd -j ACCEPT
iptables -A INPUT -p tcp -i eth1 --dport nfs -j ACCEPT