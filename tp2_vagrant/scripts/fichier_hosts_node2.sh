#!/bin/bash

cp /vagrant/fichier_to_move/hosts /etc

cp /vagrant/fichier_to_move/server.crt /usr/share/pki/ca-trust-source/anchors/

update-ca-trust