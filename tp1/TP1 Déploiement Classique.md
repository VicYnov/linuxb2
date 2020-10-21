# TP1 Déploiement Classique

## 0. Prérequis

VM1 : 

```
[root@node1 ~]# cat /etc/hostname 
node1.tp1.b2
```

Hostname configuré

```
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:6f:1f:30 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.11/24 brd 192.168.1.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe6f:1f30/64 scope link
       valid_lft forever preferred_lft forever
```

IP configurée

```
[root@node1 ~]# sudo cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.1.12 node2.tp1.b2
```

Fichier hosts édité

```
[root@node1 ~]# ping node2.tp1.b2
PING node2.tp1.b2 (192.168.1.12) 56(84) bytes of data.
64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=1 ttl=64 time=0.873 ms
64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=2 ttl=64 time=0.941 ms
64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=3 ttl=64 time=1.04 ms
64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=4 ttl=64 time=1.09 ms
^C
--- node2.tp1.b2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3006ms
rtt min/avg/max/mdev = 0.873/0.989/1.097/0.090 ms
```


Node1 peut ping Node2

```
[root@node1 ~]# sudo iptables -vnL
Chain INPUT (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
11561  803K ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate ESTABLISHED
    7   420 ACCEPT     tcp  --  enp0s8 *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
    2   104 ACCEPT     tcp  --  enp0s8 *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
    1    84 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0
    6   360 ACCEPT     tcp  --  enp0s8 *       0.0.0.0/0            0.0.0.0/0            tcp dpt:443

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 597 packets, 69687 bytes)
 pkts bytes target     prot opt in     out     source               destination
   31  2604 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW,RELATED,ESTABLISHED
```

Pare-feu configuré

```
admin1 ALL= (root) ALL
```

Utilisateur avec droit sudo créé

```
sdb                   8:16   0    5G  0 disk
├─data-ma_data_frer 253:2    0    3G  0 lvm  /srv/site1
└─data-ta_data_frer 253:3    0    2G  0 lvm  /srv/site2
```

Partitions créées et montées

VM2 : 

```
[root@node2 ~]# cat /etc/hostname 
node2.tp1.b2
```

Hostname configuré

```
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:3f:12:ba brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.12/24 brd 192.168.1.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe3f:12ba/64 scope link
       valid_lft forever preferred_lft forever
```

IP configurée

```
[root@node2 ~]# sudo cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.1.11 node1.tp1.b2
```

Fichier hosts édité

```
[root@node2 ~]# ping node1.tp1.b2
PING node1.tp1.b2 (192.168.1.11) 56(84) bytes of data.
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=1 ttl=64 time=1.13 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=2 ttl=64 time=1.06 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=3 ttl=64 time=0.737 ms
64 bytes from node1.tp1.b2 (192.168.1.11): icmp_seq=4 ttl=64 time=1.06 ms
^C
--- node1.tp1.b2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3006ms
rtt min/avg/max/mdev = 0.737/1.000/1.132/0.155 ms
```

Node2 peut ping Node1


```
[root@node2 ~]# sudo iptables -vnL
Chain INPUT (policy DROP 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
 1635  120K ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate ESTABLISHED
    2   104 ACCEPT     tcp  --  enp0s8 *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
    0     0 ACCEPT     tcp  --  enp0s8 *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
    3   252 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 822 packets, 78063 bytes)
 pkts bytes target     prot opt in     out     source               destination
   26  2184 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW,RELATED,ESTABLISHED
```
Pare-feu configuré

```
admin2 ALL= (root) ALL
```
Utilisateur avec droits sudo créé

```
sdb                   8:16   0    5G  0 disk
├─data-ma_data_frer 253:2    0    3G  0 lvm  /srv/site1
└─data-ta_data_frer 253:3    0    2G  0 lvm  /srv/site2
```
Partitions créées et montées


## I. Setup serveur Web

```
[root@node1 ~]# nginx -v
nginx version: nginx/1.16.1
```
Nginx installé

```
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user adminweb;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  node1.tp1.b2;
        root         /srv;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location /site1 {
                alias /srv/site1;
        }

        location /site2 {
                alias /srv/site2;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
    server {
        listen       443 ssl http2 default_server;
        listen       [::]:443 ssl http2 default_server;
        server_name  node1.tp1.b2;
        root         /srv;

        ssl_certificate "/etc/pki/nginx/server.crt";
        ssl_certificate_key "/etc/pki/nginx/private/server.key";
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout  10m;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location /site1 {
                alias /srv/site1;
        }

        location /site2 {
                alias /srv/site2;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
}
```

fichier nginx.conf

```
[root@node2 ~]# curl -L node1.tp1.b2/site1/index.html
<h1>Hello from site 1</h1>
[root@node2 ~]# curl -L node1.tp1.b2/site2/index.html
<h1>Hello from site 2</h1>
[root@node2 ~]# curl -kL https://node1.tp1.b2:443/site1/index.html
<h1>Hello from site 1</h1>
[root@node2 ~]# curl -kL https://node1.tp1.b2:443/site2/index.html
<h1>Hello from site 2</h1>
```

Les curl pour vérifier que ça fonctionne.

## II. Script de sauvegarde

Voici mon super script de sauvegarde :) 

```
#!/bin/bash

# date du jour
DATE=$(date +%Y-%m-%d-%H-%M-%S)
USER_ID=1003
REP_SAVE="/srv/save_web"
REP_SITE="$1"
NOM_SITE=${REP_SITE:5}

if [[ ${EUID} -ne ${USER_ID} ]]
then
        echo "Vous n'avez pas la permission pour éxécuter ce programme"
        exit 1
fi

sauvegarde() {
        tar zcfv "${REP_SAVE}/${NOM_SITE}_${DATE}.tar.gz" "${NOM_SITE}"
}

max_sauvegarde() {
        find ${REP_SAVE} -maxdepth 1 -type f | wc -l | awk '{print $1}'
}
NBR_FICHIER=$(max_sauvegarde)

if [ ${NBR_FICHIER} -gt 7 ]
then
        PLUSVIEUX_FICHIER=$(ls -t ${REP_SAVE} | tail -1)
        rm -f ${REP_SAVE}/${PLUSVIEUX_FICHIER}
        sauvegarde
        echo "La plus vieille sauvegarde a été supprimé et remplacé par la nouvelle"
else
        sauvegarde
        echo "La nouvelle sauvegarde a été effectué"
fi
```

Et là, la preuve que j'arrive à restaurer mon dossier site1

```
[backup@node1 srv]$ cd site1
[backup@node1 site1]$ ls
index.html  lost+found  prout
[backup@node1 site1]$ cd ..
[backup@node1 srv]$ sh tp1_backup.sh /srv/site1
site1/
site1/prout
site1/lost+found/
site1/index.html
La nouvelle sauvegarde a été effectué
[backup@node1 srv]$ cd site1
[backup@node1 site1]$ rm prout
[backup@node1 site1]$ ls
index.html  lost+found
[backup@node1 site1]$ cd ..
[backup@node1 srv]$ cd save_web/
[backup@node1 save_web]$ ls
site1_2020-09-28-16-44-58.tar.gz
[backup@node1 save_web]$ tar -xzvf site1_2020-09-28-16-44-58.tar.gz -C /srv/
site1/
site1/prout
site1/lost+found/
site1/index.html
[backup@node1 save_web]$ cd ..
[backup@node1 srv]$ cd site1
[backup@node1 site1]$ ls
index.html  lost+found  prout
```

## III. Monitoring, alerting

Netdata est bien installé : 

```
[root@node1 ~]# netdata -v
netdata v1.25.0-75-nightly
```

Il faut ensuite configurer la partie 'Discord' dans ce fichier en l'éxécutant de la sorte : 

```
/etc/netdata/edit-config health_alarm_notify.conf
```

Comme ceci : 

```
#------------------------------------------------------------------------------
# discord (discordapp.com) global notification options

# multiple recipients can be given like this:
#                  "CHANNEL1 CHANNEL2 ..."

# enable/disable sending discord notifications
SEND_DISCORD="YES"

# Create a webhook by following the official documentation -
# https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL=""

# if a role's recipients are not configured, a notification will be send to
# this discord channel (empty = do not send a notification for unconfigured
# roles):
DEFAULT_RECIPIENT_DISCORD="alarms"
```

Ajouter l'adresse du serveur souhaité dans DISCORD_WEBHOOK_URL.

Ensuite, il faut éxécuter ces trois commandes à la suite : 

```
su -s /bin/bash netdata
export NETDATA_ALARM_NOTIFY_DEBUG=1
/usr/libexec/netdata/plugins.d/alarm-notify.sh test
```

Et on obtient ceci : 

![](https://i.imgur.com/NCdfNbh.png)




