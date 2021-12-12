#!/bin/sh
CUSER=juva6691

printf "CREATING NEW SSH KEY PAIRS SSH\n"

echo 
ssh-keygen

printf "ADDING SSH KEYS INTO THE SSH AUTHENTIFICATION AGENT\n"

eval `ssh-agent` 
sudo chmod 400 .ssh/id_rsa.pub 
ssh-add
ssh-add -l


echo -e "Copy this key to your OpenNebula profile. You have 60s: \n"
cat /root/.ssh/id_rsa.pub

sleep 60

printf "INSTALLING Debian UPDATES\n"

sudo apt update

printf "INSTALLING git\n"

sudo apt install git

printf "INSTALING OPEN NEBULA\n"

git clone https://github.com/OpenNebula/one.git
sudo apt install gnupg2
wget -q -O- https://downloads.opennebula.org/repo/repo.key | sudo apt-key add -
echo "deb https://downloads.opennebula.org/repo/5.6/Ubuntu/18.04 stable opennebula" | sudo tee /etc/apt/sources.list.d/opennebula.list
sudo apt update

printf "INSTALLING ANSIBLE\n"

sudo apt install ansible -y
ansible --version

printf "INSTALLING OPEN NEBULA TOOLS\n"

sudo apt-get install opennebula-tools

printf "CREATING VMS\n"

CUSER=juva6691
CENDPOINT=https://grid5.mif.vu.lt/cloud3/RPC2
CUSER_WEB=gyjo7388
CPASS_WEB="Gytis123"
CUSER_DB=emse7696
CPASS_DB="Rituals330d?"
CUSER_CLIENT=debe7408
CPASS_CLIENT="E38f8w@!"

#eval ssh-agent -s
#ssh-add

CVMREZ=$(onetemplate instantiate "debian11-5G" --name "WEBSERVER_VM"  --raw TCP_PORT_FORWARDING=80 --user $CUSER_WEB --password $CPASS_WEB --endpoint $CENDPOINT)
WEBSERVERID=$(echo $CVMREZ | cut -d ' ' -f 3)
echo -e "\n\nWEBSERVER ID: ${WEBSERVERID}"

CVMREZ=$(onetemplate instantiate "debian11-5G" --name "DATABASE_VM" --user $CUSER_DB --password $CPASS_DB  --endpoint $CENDPOINT)
DBID=$(echo $CVMREZ |cut -d ' ' -f 3)
echo -e "DATABASE ID: ${DBID}"

CVMREZ=$(onetemplate instantiate "debian11-5G" --name "CLIENT_VM" --user $CUSER_CLIENT --password $CPASS_CLIENT  --endpoint $CENDPOINT)
CLIENTID=$(echo $CVMREZ |cut -d ' ' -f 3)
echo -e "CLIENT ID: ${CLIENTID}\n"

echo "INITIALIZING VMS. Wait for 30s"
sleep 30

mkdir /etc/ansible

onevm show $CLIENTID --user $CUSER_CLIENT --password $CPASS_CLIENT  --endpoint $CENDPOINT > /etc/ansible/client.txt
onevm show $DBID --user $CUSER_DB --password $CPASS_DB  --endpoint $CENDPOINT > /etc/ansible/database.txt
onevm show $WEBSERVERID --user $CUSER_WEB --password $CPASS_WEB  --endpoint $CENDPOINT > /etc/ansible/webserver.txt

IPWEB=$(cat /etc/ansible/webserver.txt | grep PRIVATE\_IP| cut -d '=' -f 2 | tr -d '"')
IPDB=$(cat /etc/ansible/database.txt | grep PRIVATE\_IP| cut -d '=' -f 2 | tr -d '"')
IPCL=$(cat /etc/ansible/client.txt | grep PRIVATE\_IP| cut -d '=' -f 2 | tr -d '"')

ssh-keygen -R $IPWEB
ssh-keygen -R $IPDB
ssh-keygen -R $IPCL

ssh-keyscan $IPWEB >> $HOME/.ssh/known_hosts
ssh-keyscan $IPDB >> $HOME/.ssh/known_hosts
ssh-keyscan $IPCL >> $HOME/.ssh/known_hosts

echo -e "[webserver]\n$IPWEB\n\n[database]\n$IPDB\n\n[client]\n$IPCL" > /etc/ansible/hosts

echo "PINGING ALL MACHINES"
ansible all -m ping
echo "PINGED"


#Adding database IP to vars.php file
echo '<?php $ip="' > vars.php
echo $IPDB >> vars.php
echo '"; ?>' >> vars.php

git clone https://github.com/gjonusys/virtualization.git

echo -e "\nPlaying Database yaml"
ansible-playbook /root/virtualization/scripts/playbook-database-vm.yaml
echo -e "\nPlaying Webserver yaml"
ansible-playbook /root/virtualization/scripts/playbook-webserver-vm.yaml
echo -e "\nPlaying Client yaml"
ansible-playbook /root/virtualization/scripts/playbook-client-vm-1.yaml

onevm reboot ${CLIENTID} --user ${CUSER_CLIENT} --password ${CPASS_CLIENT} --endpoint ${CENDPOINT}
onevm reboot ${DBID} --user ${CUSER_DB} --password ${CPASS_DB} --endpoint ${CENDPOINT}
onevm reboot ${WEBSERVERID} --user ${CUSER_WEB} --password ${CPASS_WEB} --endpoint ${CENDPOINT}

echo "REBOOTING VMS. Wait for 30s"
sleep 30

printf "Done\n"