#!/bin/sh
RED='\033[0;31m'
NC='\033[0m'
CUSER=juva6691

printf "${RED}Creating new authentication key pairs for SSH${NC}\n"

echo 
ssh-keygen

printf "${RED}Adding SSH private keys into the SSH authentication agent${NC}\n"

eval `ssh-agent` 
sudo chmod 400 .ssh/id_rsa.pub 
ssh-add
ssh-add -l

printf "${RED}Adding Public SSH key to profile${NC}\n"

echo -e "Copy and paste it to OpenNebula profile (60s): \n"
cat /root/.ssh/id_rsa.pub

sleep 60

printf "${RED}Installing latest debian updates${NC}\n"

sudo apt update

printf "${RED}Installing git${NC}\n"

sudo apt install git

printf "${RED}Cloning OpenNebula repository${NC}\n"

git clone https://github.com/OpenNebula/one.git

printf "${RED}Installing OpenNebula required libraries${NC}\n"

sudo apt install gnupg2
wget -q -O- https://downloads.opennebula.org/repo/repo.key | sudo apt-key add -
echo "deb https://downloads.opennebula.org/repo/5.6/Ubuntu/18.04 stable opennebula" | sudo tee /etc/apt/sources.list.d/opennebula.list
sudo apt update

printf "${RED}Installing ansible${NC}\n"

sudo apt install ansible -y
ansible --version

#sed -i 's/#host_key_checking = False/host_key_checking = False/g' /etc/ansible/ansible.cfg

printf "${RED}Installing OpenNebula tools${NC}\n"

sudo apt-get install opennebula-tools

printf "${RED}Adding scripts${NC}\n"

cat > create-vms.sh <<'endmsg1'
#!/bin/sh

#Hardcoded variables
CUSER=juva6691
CENDPOINT=https://grid5.mif.vu.lt/cloud3/RPC2
CUSER_WEB=gyjo7388
CPASS_WEB="Gytis123"
CUSER_DB=emse7696
CPASS_DB="Rituals330d?"
CUSER_CLIENT=debe7408
CPASS_CLIENT="E38f8w@!"

#Adding SSH private keys into the SSH authentication agent
echo "Please enter password for your SSH key:"
eval ssh-agent -s
ssh-add

#Instantiating virtual child machines
#Webserver
CVMREZ=$(onetemplate instantiate "debian11-5G" --name "WEBSERVER_VM"  --raw TCP_PORT_FORWARDING=80 --user $CUSER_WEB --password $CPASS_WEB --endpoint $CENDPOINT)
WEBSERVERID=$(echo $CVMREZ | cut -d ' ' -f 3)
echo -e "\n\nWebserver VM ID: ${WEBSERVERID}"

#Database
CVMREZ=$(onetemplate instantiate "debian11-5G" --name "DATABASE_VM" --user $CUSER_DB --password $CPASS_DB  --endpoint $CENDPOINT)
DBID=$(echo $CVMREZ |cut -d ' ' -f 3)
echo -e "Database VM ID: ${DBID}"

#Client
CVMREZ=$(onetemplate instantiate "debian11-5G" --name "CLIENT_VM" --user $CUSER_CLIENT --password $CPASS_CLIENT  --endpoint $CENDPOINT)
CLIENTID=$(echo $CVMREZ |cut -d ' ' -f 3)
echo -e "Client VM ID: ${CLIENTID}\n"

echo "Waiting for VM to RUN 30 sec."
sleep 30

#Getting virtual machines' information to file
$(onevm show $CLIENTID --user $CUSER_CLIENT --password $CPASS_CLIENT  --endpoint $CENDPOINT > /etc/ansible/client.txt)
$(onevm show $DBID --user $CUSER_DB --password $CPASS_DB  --endpoint $CENDPOINT > /etc/ansible/database.txt)
$(onevm show $WEBSERVERID --user $CUSER_WEB --password $CPASS_WEB  --endpoint $CENDPOINT > /etc/ansible/webserver.txt)

#Saving virtual machines' private IPs to variables
IPWEB=$(cat /etc/ansible/webserver.txt | grep PRIVATE\_IP| cut -d '=' -f 2 | tr -d '"')
IPDB=$(cat /etc/ansible/database.txt | grep PRIVATE\_IP| cut -d '=' -f 2 | tr -d '"')
IPCL=$(cat /etc/ansible/client.txt | grep PRIVATE\_IP| cut -d '=' -f 2 | tr -d '"')

#Creating new SSH authentication key pairs for each IP
ssh-keygen -R $IPWEB
ssh-keygen -R $IPDB
ssh-keygen -R $IPCL

#Adding SSH keys to known hosts
ssh-keyscan $IPWEB >> $HOME/.ssh/known_hosts
ssh-keyscan $IPDB >> $HOME/.ssh/known_hosts
ssh-keyscan $IPCL >> $HOME/.ssh/known_hosts

#Adding private IPs to ansible hosts file
echo -e "[webserver]\n$IPWEB\n\n[database]\n$IPDB\n\n[client]\n$IPCL" > /etc/ansible/hosts

#Ansible pinging to hosts
echo "Ansible pinging"
ansible all -m ping
echo "Done pinging!"

#Adding database IP to vars.php file

echo -e "<?php '$'ip=${IPDB} ?>" > vars.php

#Gathering newest data from web git

git clone https://github.com/gjonusys/virtualization.git

#Starting playbooks
echo -e "\nPlaying Database yaml"
ansible-playbook /root/virtualization/scripts/playbook-database-vm.yaml
echo -e "\nPlaying Webserver yaml"
ansible-playbook /root/virtualization/scripts/playbook-webserver-vm.yaml
echo -e "\nPlaying Client yaml"
ansible-playbook /root/virtualization/scripts/playbook-client-vm-1.yaml

#Rebooting child machines
onevm reboot ${CLIENTID} --user ${CUSER_CLIENT} --password ${CPASS_CLIENT} --endpoint ${CENDPOINT}
onevm reboot ${DBID} --user ${CUSER_DB} --password ${CPASS_DB} --endpoint ${CENDPOINT}
onevm reboot ${WEBSERVERID} --user ${CUSER_WEB} --password ${CPASS_WEB} --endpoint ${CENDPOINT}

echo -e "\nDone"
endmsg1

printf "${RED}Done${NC}\n"