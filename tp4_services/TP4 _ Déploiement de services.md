# TP4 : Déploiement de services

## 0. Prerequisites

Création de la box : 

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
  config.vm.hostname = "vm.tp4"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.name = "vm_tp4"
  end
  config.vm.provision "shell", path: "scripts/install.sh"
end
```

```install.sh``` : 

```
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
```

```Vagrantfile``` : 

```
Vagrant.configure("2")do|config|
  config.vm.box="box-tp4"
  ## Les 3 lignes suivantes permettent d'éviter certains bugs et/ou d'accélérer le déploiement. Gardez-les tout le temps sauf contre-indications.
  # Ajoutez cette ligne afin d'accélérer le démarrage de la VM (si une erreur 'vbguest' est levée, voir la note un peu plus bas)
  config.vbguest.auto_update = true
  # Désactive les updates auto qui peuvent ralentir le lancement de la machine
  config.vm.box_check_update = false 
  # La ligne suivante permet de désactiver le montage d'un dossier partagé (ne marche pas tout le temps directement suivant vos OS, versions d'OS, etc.)
  config.vm.synced_folder ".", "/vagrant"
  config.vm.define "vmnfs" do |nfs|
    nfs.vm.network "private_network", ip: "192.168.4.14"
    nfs.vm.hostname = "vm.nfs"
    nfs.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
      vb.name = "tp4_nfs"
    end
    nfs.vm.provision "shell", path: "scripts/nfs.sh"
  end

  config.vm.define "vmgitea" do |gitea|
    gitea.vm.network "private_network", ip: "192.168.4.11"
    gitea.vm.hostname = "vm.gitea"
    gitea.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
      vb.name = "tp4_gitea"
    end
    gitea.vm.provision "shell", path: "scripts/gitea.sh"
  end
  
  config.vm.define "vmbdd" do |bdd|
    bdd.vm.network "private_network", ip: "192.168.4.12"
    bdd.vm.hostname = "vm.bdd"
    bdd.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
      vb.name = "tp4_bdd"
    end
    bdd.vm.provision "shell", path: "scripts/bdd.sh"
  end

  config.vm.define "vmnginx" do |nginx|
    nginx.vm.network "private_network", ip: "192.168.4.13"
    nginx.vm.hostname = "vm.nginx"
    nginx.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
      vb.name = "tp4_nginx"
    end
    nginx.vm.provision "shell", path: "scripts/nginx.sh"
  end
end
```
Bien monter la vm nfs en premier sinon il y a une erreur au moment des mounts sur les autres vm parce qu'elles trouvent pas le serveur nfs :/

## I. Consignes générales

Adressage des machines

| Nom | IP   | Rôle |
| ---- | ---- | ---- |
| vmgitea|192.168.4.11|Serveur qui héberge Gitea|
| vmbdd|192.168.4.12|Serveur qui héberge la bdd|
| vmnginx|192.168.4.13|Serveur Nginx qui agit comme reverse-proxy|
| vmnfs|192.168.4.14|Serveur pour lier les fichiers entre les vm sur celle-ci|