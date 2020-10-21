# TP3 : systemd

## 0. Prérequis

```Vagrantfile``` : 

```
Vagrant.configure("2")do|config|
  config.vm.box="centos/7"
  ## Les 3 lignes suivantes permettent d'éviter certains bugs et/ou d'accélérer le déploiement. Gardez-les tout le temps sauf contre-indications.
  # Ajoutez cette ligne afin d'accélérer le démarrage de la VM (si une erreur 'vbguest' est levée, voir la note un peu plus bas)
  config.vbguest.auto_update = true
  # Désactive les updates auto qui peuvent ralentir le lancement de la machine
  config.vm.box_check_update = false 
  # La ligne suivante permet de désactiver le montage d'un dossier partagé (ne marche pas tout le temps directement suivant vos OS, versions d'OS, etc.)
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.network "private_network", ip: "192.168.2.11"
  config.vm.hostname = "vm.tp3"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.name = "vm_tp3"
  end
  config.vm.provision "shell", path: "scripts/install.sh"
end
```

```install.sh``` pour faire ma box : 

```
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
```

## I. Services systemd

### 1. Intro

Lister les services dispos sur la machine : 

```
systemctl list-units --all --type=service | grep "units listed" | cut -d' ' -f1
```

Lister les services actifs sur la machine : 

```
systemctl list-units --all --type=service --state=running | grep "units listed" | cut -d' ' -f1
```

Lister les services failed ou exited sur la machine : 

```
systemctl list-units --all --type=service --state=failed --state=exited | grep "units listed" | cut -d' ' -f1
```

Lister les services qui démarre automatiquement au boot : 

```
sudo systemctl list-unit-files --all --type=service | grep "enabled"
```

### 2. Analyse d'un service

Déterminer le path de nginx.service : 

```
[vagrant@vm ~]$ sudo find / -name "nginx.service"
/usr/lib/systemd/system/nginx.service
```

```ExecStart``` Commande (avec ses arguments) à exécuter pour démarrer le service

```ExecStartPre``` Commandes additionelles à éxécuter avant ou après ```ExecStart```

```PIDFile``` désigne le chemin où le fichier de PID du service sera enregistré.

```Type``` décrit le mode de démarrage du processus.

```ExecReload``` Commande à éxécuter pour déclencher une
relecture de la configuration du service.

```Description``` permet de donner une description du service qui apparaîtra lors de l'utilisation de la commande ```systemctl status <nom_du_service>```.

```After``` permet d'indiquer quel pré-requis est nécessaire pour le fonctionnement du service.

Listez tous les services qui contiennent la ligne ```WantedBy=multi-user.target``` : 

Se rendre dans ```/usr/lib/systemd/system``` et éxécuter cette commande : 

```sudo grep -r WantedBy=multi-user.target . | cut -d ':' -f1 | cut -d '/' -f2```

### 3. Création d'un service

#### A. Serveur web

Le service tourne : 

```
[tp3@vm system]$ sudo systemctl status serverpython
● serverpython.service - Lance un serveur web et ouvre les ports appropriés
   Loaded: loaded (/etc/systemd/system/serverpython.service; static; vendor preset: disabled)
   Active: active (running) since Wed 2020-10-07 09:33:56 UTC; 2s ago
  Process: 24459 ExecStartPre=/usr/bin/sudo iptables -A INPUT -p tcp -i eth1 --dport 50 -j ACCEPT (code=exited, status=0/SUCCESS)
 Main PID: 24464 (sudo)
   CGroup: /system.slice/serverpython.service
           ‣ 24464 /usr/bin/sudo python2 -m SimpleHTTPServer 50

Oct 07 09:33:55 vm.tp3 systemd[1]: Starting Lance un serveur web et ouvre les ports appropriés...
Oct 07 09:33:55 vm.tp3 sudo[24459]:      tp3 : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/sbin/iptables -A INPU...ACCEPT
Oct 07 09:33:56 vm.tp3 systemd[1]: Started Lance un serveur web et ouvre les ports appropriés.
Oct 07 09:33:56 vm.tp3 sudo[24464]:      tp3 : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/bin/python2 -m Simple...ver 50
Hint: Some lines were ellipsized, use -l to show in full.
```

Le server est joignable : 

```
PS C:\Users\victo\vagrant\tp3_systemd> curl 192.168.2.11:50


StatusCode        : 200
StatusDescription : OK
Content           : <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"><html>
                    <title>Directory listing for /</title>
                    <body>
                    <h2>Directory listing for /</h2>
                    <hr>
                    <ul>
                    <li><a href="bin/">bin@</a>
                    <li><a href="boot/">b...
RawContent        : HTTP/1.0 200 OK
                    Content-Length: 764
                    Content-Type: text/html; charset=UTF-8
                    Date: Wed, 07 Oct 2020 09:29:00 GMT
                    Server: SimpleHTTP/0.6 Python/2.7.5

                    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Fi...
Forms             : {}
Headers           : {[Content-Length, 764], [Content-Type, text/html; charset=UTF-8], [Date, Wed, 07 Oct 2020 09:29:00
                    GMT], [Server, SimpleHTTP/0.6 Python/2.7.5]}
Images            : {}
InputFields       : {}
Links             : {@{innerHTML=bin@; innerText=bin@; outerHTML=<A href="bin/">bin@</A>; outerText=bin@; tagName=A;
                    href=bin/}, @{innerHTML=boot/; innerText=boot/; outerHTML=<A href="boot/">boot/</A>;
                    outerText=boot/; tagName=A; href=boot/}, @{innerHTML=dev/; innerText=dev/; outerHTML=<A
                    href="dev/">dev/</A>; outerText=dev/; tagName=A; href=dev/}, @{innerHTML=etc/; innerText=etc/;
                    outerHTML=<A href="etc/">etc/</A>; outerText=etc/; tagName=A; href=etc/}...}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 764
```

#### B. Sauvegarde

Le script de sauvegarde découpé en 3 : 

```verifs.sh``` : 

```
#!/bin/bash

USER_ID=1002
REP_SAVE="/srv/save_web"

if [[ ! -d "${REP_SAVE}" ]]
then
        echo "No save directory existing" >&2
        exit 1
fi
```

```sauvegarde.sh``` : 

```
#!/bin/bash

echo $$ > /var/run/backup_tp3.pid

# date du jour
DATE=$(date +%Y-%m-%d-%H-%M-%S)
REP_SAVE="/srv/save_web"

REP_SITE1="/srv/site1"
NOM_SITE1="site1"

REP_SITE2="/srv/site2"                                                                                                  NOM_SITE2="site2"

sauvegarde1() {
        tar zcfv "${REP_SAVE}/${NOM_SITE1}_${DATE}.tar.gz" "${NOM_SITE1}"
}
sauvegarde1

sauvegarde2() {
        tar zcfv "${REP_SAVE}/${NOM_SITE2}_${DATE}.tar.gz" "${NOM_SITE2}"
}
sauvegarde2
```

```compteur.sh``` : 

```
#!/bin/bash

REP_SAVE="/srv/save_web"

max_sauvegarde() {
        find ${REP_SAVE} -maxdepth 1 -type f | wc -l | awk '{print $1}'
}
NBR_FICHIER=$(max_sauvegarde)

if [ ${NBR_FICHIER} -gt 7 ]
then
        PLUSVIEUX_FICHIER=$(ls -t ${REP_SAVE} | tail -1)
        rm -f ${REP_SAVE}/${PLUSVIEUX_FICHIER}
        echo "La plus vieille sauvegarde a été supprimé et remplacé par la nouvelle"
fi
```

Etat du timer : 

```
[backup@vm system]$ sudo systemctl status save.timer
● save.timer - sauvegarde horaire
   Loaded: loaded (/etc/systemd/system/save.timer; enabled; vendor preset: disabled)
   Active: active (waiting) since Fri 2020-10-09 09:43:47 UTC; 23s ago

Oct 09 09:43:47 vm.tp3 systemd[1]: Started sauvegarde horaire.
```

## II. Autres features

### 1. Gestion de boot

Les services les plus longs à démarrer sont : 

vboxadd.service (15.918s)
NetworkManager-wait-online.service (6.955s)
postfix.service (2.261s)

### 2. Gestion de l'heure

```
[vagrant@vm ~]$ timedatectl
      Local time: Fri 2020-10-09 14:12:50 UTC
  Universal time: Fri 2020-10-09 14:12:50 UTC
        RTC time: Wed 2020-10-07 15:59:23
       Time zone: UTC (UTC, +0000)
     NTP enabled: yes
NTP synchronized: no
 RTC in local TZ: no
      DST active: n/a
```

Mon fuseau horaire est le UTC.

La ligne ```NTP synchronized: no``` indique que je ne suis pas synchronysé avec un serveur NTP

Changement du fuseau horaire : 

```
[vagrant@vm ~]$ sudo timedatectl set-timezone Europe/Paris
```

### 3. Gestion des noms et de la résolution de noms

```
[vagrant@vm ~]$ hostnamectl
hostnamectl
   Static hostname: vm.tp3
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 438aa5aeda7f2348adabb0e54c6e5d2b
           Boot ID: 79b264197d514614beb5a616dc6a80d4
    Virtualization: kvm
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-1127.el7.x86_64
      Architecture: x86-64
```

Mon hostname actuel est vm.tp3

Changement de hostname : 

```
[vagrant@vm ~]$ sudo hostnamectl set-hostname oui
```
