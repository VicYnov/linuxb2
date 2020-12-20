#!/bin/bash
#VictorYnov

# date du jour
DATE=$(date +%Y-%m-%y-%H-%M-%S)
#USER_ID=1002
REP_SAVE="/partage/gitea"
NOM_DOSSIER="/etc/gitea"

#if [[ ${EUID} -ne ${USER_ID} ]]
#then
#    echo "Vous n'avez pas la permission pour éxécuter ce programme"
#    exit 1
#fi

sauvegarde() {
    tar zcfv "save_gitea_${DATE}.tar.gz" "${NOM_DOSSIER}"
}

max_sauvegarde() {
    find ${REP_SAVE} -maxdepth 1 -type f | wc -l | awk '{print $1}'
}
NBR_FICHIER=${max_sauvegarde}

if [ ${NBR_FICHIER} -gt 7]
then
    PLUSVIEUX_FICHIER=$(ls -t ${REP_SAVE} | tail -1)
    rm -f ${REP_SAVE}/${PLUSVIEUX_FICHIER}
    sauvegarde
    echo "La plus vieille sauvegarde a été supprimé et remplacé par la nouvelle"
else
    sauvegarde
    echo "La nouvelle sauvegarde a été effectué"
fi